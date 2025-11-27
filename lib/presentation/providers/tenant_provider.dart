import 'package:flutter/foundation.dart';
import '../../domain/entities/tenant.dart';
import '../../domain/usecases/tenant/get_tenant_profile_usecase.dart';
import '../../domain/usecases/tenant/save_tenant_profile_usecase.dart';

class TenantProvider with ChangeNotifier {
  final GetTenantProfileUseCase getTenantProfileUseCase;
  final SaveTenantProfileUseCase saveTenantProfileUseCase;

  Tenant? _tenant;
  bool _isLoading = false;
  String? _errorMessage;

  Tenant? get tenant => _tenant;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isVerified => _tenant != null;

  TenantProvider({
    required this.getTenantProfileUseCase,
    required this.saveTenantProfileUseCase,
  });

  Future<void> loadTenantProfile(String userId) async {
    _setLoading(true);
    _clearError();

    final result = await getTenantProfileUseCase(userId);

    result.fold(
      (failure) {
        _setError(failure.message);
        _setLoading(false);
      },
      (tenant) {
        _tenant = tenant;
        _setLoading(false);
      },
    );
  }

  Future<bool> saveTenantProfile(Tenant tenant) async {
    _setLoading(true);
    _clearError();

    final result = await saveTenantProfileUseCase(tenant);

    return result.fold(
      (failure) {
        _setError(failure.message);
        _setLoading(false);
        return false;
      },
      (_) {
        _tenant = tenant;
        _setLoading(false);
        return true;
      },
    );
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
}
