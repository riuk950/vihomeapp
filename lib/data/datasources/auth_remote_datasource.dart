import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/errors/failures.dart';
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

      return UserModel.fromSupabaseUser(response.user!).toEntity();
    } on AuthFailure {
      rethrow;
    } catch (e) {
      throw AuthFailure(e.toString().replaceAll('Exception: ', ''));
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

      return UserModel.fromSupabaseUser(response.user!).toEntity();
    } on AuthFailure {
      rethrow;
    } catch (e) {
      throw AuthFailure(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseService.client.auth.signOut();
    } catch (e) {
      throw AuthFailure(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await supabaseService.client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AuthFailure(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await supabaseService.client.auth.updateUser(
        supabase.UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw AuthFailure(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<entity.User?> getCurrentUser() async {
    try {
      final user = supabaseService.client.auth.currentUser;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user).toEntity();
    } catch (e) {
      throw AuthFailure(e.toString().replaceAll('Exception: ', ''));
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

      return UserModel.fromSupabaseUser(response.user!).toEntity();
    } on AuthFailure {
      rethrow;
    } catch (e) {
      throw AuthFailure(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Stream<entity.User?> authStateChanges() {
    try {
      return supabaseService.client.auth.onAuthStateChange.map((state) {
        final user = state.session?.user;
        if (user == null) return null;
        return UserModel.fromSupabaseUser(user).toEntity();
      });
    } catch (e) {
      throw AuthFailure(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
