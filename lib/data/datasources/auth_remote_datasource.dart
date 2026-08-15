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
      final bool exists = await supabaseService.client.rpc<bool>(
        'check_email_exists',
        params: {'email_to_check': email.trim()},
      );

      if (!exists) {
        throw const AuthFailure('El correo electrónico no está registrado.');
      }

      await supabaseService.client.auth.resetPasswordForEmail(email);
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
