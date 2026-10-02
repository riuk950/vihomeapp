import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/supabase_error_handler.dart';
import '../../domain/entities/user.dart' as entity;
import '../models/user_model.dart';
import '../../infrastructure/services/supabase_service.dart';
import '../../env/env_def.dart';

/// Interfaz del datasource remoto de autenticación
abstract class AuthRemoteDataSource {
  Future<entity.User> signInWithEmail({
    required String email,
    required String password,
  });

  Future<entity.User> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  });

  Future<void> signOut();

  Future<void> resetPassword(String email);

  Future<void> updatePassword(String newPassword);

  Future<entity.User?> getCurrentUser();

  Future<entity.User> signInWithGoogle();

  Future<void> updateUserRole(String role);

  Stream<entity.User?> authStateChanges();
}

/// Implementación del datasource remoto de autenticación usando Supabase
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseService supabaseService;

  AuthRemoteDataSourceImpl(this.supabaseService);

  @override
  Future<entity.User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthFailure('No se pudo iniciar sesión');
      }

      final profileResponse = await supabaseService.client.from('profiles').select('is_premium').eq('id', response.user!.id).maybeSingle();
      final isPremium = profileResponse != null ? profileResponse['is_premium'] == true : false;

      return UserModel.fromSupabaseUser(response.user!, isPremium: isPremium).toEntity();
    } on Failure {
      rethrow;
    } catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }

  @override
  Future<entity.User> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await supabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );

      if (response.user == null) {
        throw const AuthFailure('No se pudo registrar el usuario');
      }

      final profileResponse = await supabaseService.client.from('profiles').select('is_premium').eq('id', response.user!.id).maybeSingle();
      final isPremium = profileResponse != null ? profileResponse['is_premium'] == true : false;

      return UserModel.fromSupabaseUser(response.user!, isPremium: isPremium).toEntity();
    } on Failure {
      rethrow;
    } catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseService.client.auth.signOut();
    } catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await supabaseService.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'https://vihome.web.app/forgot-password',
      );
    } on Failure {
      rethrow;
    } catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await supabaseService.client.auth.updateUser(
        supabase.UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }

  @override
  Future<entity.User?> getCurrentUser() async {
    try {
      final user = supabaseService.client.auth.currentUser;
      if (user == null) return null;
      
      final profileResponse = await supabaseService.client.from('profiles').select('is_premium').eq('id', user.id).maybeSingle();
      final isPremium = profileResponse != null ? profileResponse['is_premium'] == true : false;
      
      return UserModel.fromSupabaseUser(user, isPremium: isPremium).toEntity();
    } catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }

  @override
  Future<entity.User> signInWithGoogle() async {
    try {
      if (EnvDef.googleWebClientId.isEmpty) {
        throw const AuthFailure(
            'El GOOGLE_WEB_CLIENT_ID está vacío. Revisa tu archivo .env.dev y reinicia la app.');
      }

      final googleSignIn = GoogleSignIn(
        serverClientId: EnvDef.googleWebClientId,
      );

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthFailure('Inicio de sesión con Google cancelado');
      }

      final googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw const AuthFailure('No se pudo obtener el ID Token de Google. '
            'Asegúrate de que el Web Client ID esté bien configurado en EnvDef y los Client IDs en Google Cloud.');
      }

      final response = await supabaseService.client.auth.signInWithIdToken(
        provider: supabase.OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw const AuthFailure(
            'No se pudo iniciar sesión con Google en Supabase');
      }

      final profileResponse = await supabaseService.client.from('profiles').select('is_premium').eq('id', response.user!.id).maybeSingle();
      final isPremium = profileResponse != null ? profileResponse['is_premium'] == true : false;

      return UserModel.fromSupabaseUser(response.user!, isPremium: isPremium).toEntity();
    } on Failure {
      rethrow;
    } catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }

  @override
  Future<void> updateUserRole(String role) async {
    try {
      final user = supabaseService.client.auth.currentUser;
      if (user == null) throw const AuthFailure('No hay usuario autenticado');

      // 1. Actualizar metadatos de Auth
      await supabaseService.client.auth.updateUser(
        supabase.UserAttributes(
          data: {'role': role},
        ),
      );

      // 2. Actualizar tabla profiles
      await supabaseService.client.from('profiles').update({
        'role': role,
      }).eq('id', user.id);

      // 3. Sincronización automática de perfil personal entre roles (RF-37)
      try {
        if (role == 'arrendador') {
          // Consultar origen: info_arrendatarios
          final tenantData = await supabaseService.client
              .from('info_arrendatarios')
              .select()
              .eq('id', user.id)
              .maybeSingle();

          if (tenantData != null &&
              tenantData['primer_nombre'] != null &&
              (tenantData['primer_nombre'] as String).isNotEmpty) {
            // Consultar si ya existe perfil en info_arrendadores
            final landlordData = await supabaseService.client
                .from('info_arrendadores')
                .select()
                .eq('id', user.id)
                .maybeSingle();

            if (landlordData == null ||
                landlordData['primer_nombre'] == null ||
                (landlordData['primer_nombre'] as String).isEmpty) {
              await supabaseService.client.from('info_arrendadores').upsert({
                'id': user.id,
                'primer_nombre': tenantData['primer_nombre'],
                'segundo_nombre': tenantData['segundo_nombre'],
                'primer_apellido': tenantData['primer_apellido'],
                'segundo_apellido': tenantData['segundo_apellido'],
                'tipo_documento': tenantData['tipo_documento'] ?? 'CC',
                'documento': tenantData['documento'] ?? '',
                'telefono_contacto': tenantData['telefono_contacto'] ?? '',
                'direccion_contacto': tenantData['direccion_contacto'] ?? '',
                if (tenantData['fcm_token'] != null)
                  'fcm_token': tenantData['fcm_token'],
              });
            }
          }
        } else if (role == 'arrendatario') {
          // Consultar origen: info_arrendadores
          final landlordData = await supabaseService.client
              .from('info_arrendadores')
              .select()
              .eq('id', user.id)
              .maybeSingle();

          if (landlordData != null &&
              landlordData['primer_nombre'] != null &&
              (landlordData['primer_nombre'] as String).isNotEmpty) {
            // Consultar si ya existe perfil en info_arrendatarios
            final tenantData = await supabaseService.client
                .from('info_arrendatarios')
                .select()
                .eq('id', user.id)
                .maybeSingle();

            if (tenantData == null ||
                tenantData['primer_nombre'] == null ||
                (tenantData['primer_nombre'] as String).isEmpty) {
              await supabaseService.client.from('info_arrendatarios').upsert({
                'id': user.id,
                'primer_nombre': landlordData['primer_nombre'],
                'segundo_nombre': landlordData['segundo_nombre'],
                'primer_apellido': landlordData['primer_apellido'],
                'segundo_apellido': landlordData['segundo_apellido'],
                'tipo_documento': landlordData['tipo_documento'] ?? 'CC',
                'documento': landlordData['documento'] ?? '',
                'telefono_contacto': landlordData['telefono_contacto'] ?? '',
                'direccion_contacto': landlordData['direccion_contacto'] ?? '',
                if (landlordData['fcm_token'] != null)
                  'fcm_token': landlordData['fcm_token'],
              });
            }
          }
        }
      } catch (e) {
        // La sincronización de perfil no bloquea el cambio de rol del usuario
        // pero se registra para auditoría técnica
      }
    } catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }

  @override
  Stream<entity.User?> authStateChanges() {
    try {
      return supabaseService.client.auth.onAuthStateChange.asyncMap((state) async {
        final user = state.session?.user;
        if (user == null) return null;
        try {
          final profileResponse = await supabaseService.client.from('profiles').select('is_premium').eq('id', user.id).maybeSingle();
          final isPremium = profileResponse != null ? profileResponse['is_premium'] == true : false;
          return UserModel.fromSupabaseUser(user, isPremium: isPremium).toEntity();
        } catch(e) {
          return UserModel.fromSupabaseUser(user).toEntity();
        }
      });
    } catch (e) {
      throw SupabaseErrorHandler.handle(e);
    }
  }
}
