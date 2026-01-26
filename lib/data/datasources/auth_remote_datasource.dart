import 'package:supabase_flutter/supabase_flutter.dart' as supabase_flutter;
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../models/user_model.dart';
import '../../infrastructure/services/supabase_service.dart';

/// Interfaz del datasource remoto de autenticación
abstract class AuthRemoteDataSource {
  Future<User> signInWithEmail({
    required String email,
    required String password,
  });
  
  Future<User> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  });
  
  Future<void> signOut();
  
  Future<void> resetPassword(String email);
  
  Future<void> updatePassword(String newPassword);
  
  Future<User?> getCurrentUser();
  
  Stream<User?> authStateChanges();
}

/// Implementación del datasource remoto de autenticación usando Supabase
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseService supabaseService;

  AuthRemoteDataSourceImpl(this.supabaseService);

  @override
  Future<User> signInWithEmail({
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
  Future<User> signUp({
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
        supabase_flutter.UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw AuthFailure(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final user = supabaseService.client.auth.currentUser;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user).toEntity();
    } catch (e) {
      throw AuthFailure(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Stream<User?> authStateChanges() {
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

