import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/sign_in_usecase.dart';
import '../../domain/usecases/auth/sign_in_with_google_usecase.dart';
import '../../domain/usecases/auth/sign_out_usecase.dart';
import '../../domain/usecases/auth/delete_account_usecase.dart';
import '../../domain/usecases/auth/sign_up_usecase.dart';
import '../../domain/usecases/auth/reset_password_usecase.dart';
import '../../domain/usecases/auth/update_user_role_usecase.dart';
import '../../infrastructure/services/push_notification_service.dart';
import '../../infrastructure/services/supabase_service.dart';
import '../../core/network/network_info.dart';
import '../../core/constants/storage_keys.dart';

class AuthProvider with ChangeNotifier {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SignInUseCase signInUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final UpdateUserRoleUseCase updateUserRoleUseCase;
  final DeleteAccountUseCase? deleteAccountUseCase;
  final NetworkInfo? networkInfo;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;
  bool _isManualSignOut = false;
  bool _sessionExpired = false;
  StreamSubscription<dynamic>? _authStateSubscription;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isGuest => !isAuthenticated;
  bool get isInitialized => _isInitialized;
  bool get hasExpiredSession => _sessionExpired;

  AuthProvider({
    required this.getCurrentUserUseCase,
    required this.signInUseCase,
    required this.signInWithGoogleUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.resetPasswordUseCase,
    required this.updateUserRoleUseCase,
    this.deleteAccountUseCase,
    this.networkInfo,
  }) {
    _initializeAuth();
    _listenToAuthStateChanges();
  }

  void _initializeAuth() async {
    try {
      final result = await getCurrentUserUseCase();
      result.fold(
        (failure) {
          _user = null;
          _setError(failure.message);
          _isInitialized = true;
          notifyListeners();
        },
        (user) {
          _user = user;
          if (user != null) {
            _syncToken(user);
          }
          _isInitialized = true;
          notifyListeners();
        },
      );
    } catch (e) {
      // Respaldo seguro (RF-1.5 / RF-1.6): continuar en modo invitado sin bloquear el arranque
      _user = null;
      _errorMessage = e.toString();
      _isInitialized = true;
      notifyListeners();
    }
  }

  void _listenToAuthStateChanges() {
    try {
      _authStateSubscription =
          SupabaseService.instance.client.auth.onAuthStateChange.listen((data) {
        if (data.event == AuthChangeEvent.signedOut &&
            _user != null &&
            !_isManualSignOut) {
          handleSessionExpired();
        }
      });
    } catch (_) {
      // En pruebas unitarias sin Supabase inicializado se omite de forma segura
    }
  }

  /// Gestiona la expiración o revocación remota de una sesión activa (RF-1.7).
  void handleSessionExpired() {
    if (_user == null) return;
    _user = null;
    _sessionExpired = true;
    notifyListeners();
  }

  /// Consume la bandera temporal de sesión expirada tras evaluar el enrutamiento.
  void consumeSessionExpiredFlag() {
    _sessionExpired = false;
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> reloadUser() async {
    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) {
        _setError(failure.message);
      },
      (user) {
        _user = user;
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

      final bool success = result.fold(
        (failure) {
          _setError(failure.message);
          _setLoading(false);
          return false;
        },
        (user) {
          _user = user;
          _sessionExpired = false;
          _syncToken(user);
          _setLoading(false);
          return true;
        },
      );
      return success;
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

      final bool success = result.fold(
        (failure) {
          _setError(failure.message);
          _setLoading(false);
          return false;
        },
        (user) {
          _user = user;
          _sessionExpired = false;
          _syncToken(user);
          _setLoading(false);
          return true;
        },
      );
      return success;
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

      final bool success = result.fold(
        (failure) {
          _setError(failure.message);
          _setLoading(false);
          return false;
        },
        (user) {
          _user = user;
          _sessionExpired = false;
          _syncToken(user);
          _setLoading(false);
          return true;
        },
      );
      return success;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _isManualSignOut = true;
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
        final onboardingBackup = prefs.getString(kOnboardingStateKey);
        await prefs.clear();
        if (onboardingBackup != null) {
          await prefs.setString(kOnboardingStateKey, onboardingBackup);
        }
      } catch (e) {
        debugPrint('Error al limpiar caché: $e');
      }

      _user = null;
      _sessionExpired = false;
      _isManualSignOut = false;
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Elimina de forma permanente la cuenta del usuario en Supabase,
  /// limpia la caché local y cierra la sesión.
  Future<bool> deleteAccount() async {
    _isManualSignOut = true;
    try {
      _setLoading(true);
      _clearError();

      if (deleteAccountUseCase != null) {
        final result = await deleteAccountUseCase!();
        final success = result.fold(
          (failure) {
            _setError(failure.message);
            _setLoading(false);
            return false;
          },
          (_) => true,
        );

        if (!success) {
          return false;
        }
      }

      // Limpieza de almacenamiento local (SharedPreferences) preservando estado de onboarding
      try {
        final prefs = await SharedPreferences.getInstance();
        final onboardingBackup = prefs.getString(kOnboardingStateKey);
        await prefs.clear();
        if (onboardingBackup != null) {
          await prefs.setString(kOnboardingStateKey, onboardingBackup);
        }
      } catch (e) {
        debugPrint('Error al limpiar caché local tras eliminar cuenta: $e');
      }

      // Cerrar sesión a nivel de cliente Supabase si aún persistiese
      try {
        await SupabaseService.instance.client.auth.signOut();
      } catch (e) {
        debugPrint('Error al cerrar sesión remota tras eliminar cuenta: $e');
      }

      _user = null;
      _sessionExpired = false;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    } finally {
      _isManualSignOut = false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await resetPasswordUseCase(email);

      final bool success = result.fold(
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
      return success;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> switchRole(String newRole) async {
    if (_user?.role == newRole) {
      return true;
    }

    try {
      _setLoading(true);
      _clearError();

      final result = await updateUserRoleUseCase(newRole);

      final bool success = result.fold(
        (failure) {
          _setError(failure.message);
          _setLoading(false);
          return false;
        },
        (_) {
          if (_user != null) {
            _user = _user!.copyWith(role: newRole);
          }
          _setLoading(false);
          notifyListeners();
          return true;
        },
      );
      return success;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> becomeLandlord() async {
    return switchRole('arrendador');
  }

  Future<bool> becomeTenant() async {
    return switchRole('arrendatario');
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    if (message != null) {
      debugPrint('🔔 [AuthProvider] Error establecido: $message');
    }
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
      // Verificar conexión antes de intentar sincronizar
      if (networkInfo != null && !await networkInfo!.isConnected) {
        debugPrint("Sincronización omitida: No hay conexión a internet");
        return;
      }

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
      debugPrint("✅ Datos de usuario sincronizados correctamente");
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        debugPrint(
            "⚠️ Error de red al sincronizar datos (posible DNS o falta de internet): $e");
      } else {
        debugPrint("❌ Error al sincronizar datos de usuario: $e");
      }
    }
  }
}
