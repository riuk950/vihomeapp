import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/sign_in_usecase.dart';
import '../../domain/usecases/auth/sign_in_with_google_usecase.dart';
import '../../domain/usecases/auth/sign_out_usecase.dart';
import '../../domain/usecases/auth/sign_up_usecase.dart';
import '../../domain/usecases/auth/reset_password_usecase.dart';
import '../../infrastructure/services/push_notification_service.dart';
import '../../infrastructure/services/supabase_service.dart';

class AuthProvider with ChangeNotifier {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SignInUseCase signInUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider({
    required this.getCurrentUserUseCase,
    required this.signInUseCase,
    required this.signInWithGoogleUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.resetPasswordUseCase,
  }) {
    _initializeAuth();
  }

  void _initializeAuth() async {
    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) => _setError(failure.message),
      (user) {
        _user = user;
        if (user != null) {
          _syncToken(user);
        }
        notifyListeners();
      },
    );
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await signInUseCase(
        email: email,
        password: password,
      );

      return result.fold(
        (failure) {
          _setError(failure.message);
          _setLoading(false);
          return false;
        },
        (user) {
          _user = user;
          _syncToken(user);
          _setLoading(false);
          return true;
        },
      );
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await signInWithGoogleUseCase();

      return result.fold(
        (failure) {
          _setError(failure.message);
          _setLoading(false);
          return false;
        },
        (user) {
          _user = user;
          _syncToken(user);
          _setLoading(false);
          return true;
        },
      );
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await signUpUseCase(
        email: email,
        password: password,
        metadata: metadata,
      );

      return result.fold(
        (failure) {
          _setError(failure.message);
          _setLoading(false);
          return false;
        },
        (user) {
          _user = user;
          _syncToken(user);
          _setLoading(false);
          return true;
        },
      );
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await signOutUseCase();

      result.fold(
        (failure) {
          _setError(failure.message);
        },
        (_) {},
      );
    } catch (e) {
      _setError(e.toString());
    } finally {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      } catch (e) {
        debugPrint('Error al limpiar caché: $e');
      }

      _user = null;
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await resetPasswordUseCase(email);

      return result.fold(
        (failure) {
          _setError(failure.message);
          _setLoading(false);
          return false;
        },
        (_) {
          _setLoading(false);
          return true;
        },
      );
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  Future<void> _syncToken(User user) async {
    try {
      final token = await PushNotificationService.getToken();
      final client = SupabaseService.instance.client;
      final userId = user.id;

      // Crear el mapa de datos a sincronizar
      final Map<String, dynamic> updateData = {
        'id': userId,
        'email': user.email,
        'full_name': user.name,
        'role': user.role ?? 'arrendatario',
      };

      // Agregar el fcm_token solo si no es nulo
      if (token != null) {
        updateData['fcm_token'] = token;
      }

      // Sincronizar en la tabla general 'profiles' con los campos correctos
      await client.from('profiles').upsert(updateData);
    } catch (e) {
      debugPrint("Error al sincronizar datos de usuario: $e");
    }
  }
}
