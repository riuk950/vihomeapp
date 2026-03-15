import 'package:flutter/foundation.dart';
import '../../domain/entities/landlord.dart';
import '../../domain/usecases/landlord/get_landlord_profile_usecase.dart';
import '../../domain/usecases/landlord/save_landlord_profile_usecase.dart';

class LandlordProvider with ChangeNotifier {
  final GetLandlordProfileUseCase getLandlordProfileUseCase;
  final SaveLandlordProfileUseCase saveLandlordProfileUseCase;

  Landlord? _landlord;
  bool _isLoading = false;
  String? _errorMessage;

  Landlord? get landlord => _landlord;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isVerified => _landlord != null;

  LandlordProvider({
    required this.getLandlordProfileUseCase,
    required this.saveLandlordProfileUseCase,
  });

  Future<void> loadLandlordProfile(String userId) async {
    _setLoading(true);
    _clearError();

    final result = await getLandlordProfileUseCase(userId);

    result.fold(
      (failure) {
        _setError(failure.message);
        _setLoading(false);
      },
      (landlord) {
        _landlord = landlord;
        _setLoading(false);
      },
    );
  }

  Future<bool> saveLandlordProfile(Landlord landlord) async {
    _setLoading(true);
    _clearError();

    final result = await saveLandlordProfileUseCase(landlord);

    return result.fold(
      (failure) {
        _setError(failure.message);
        _setLoading(false);
        return false;
      },
      (_) {
        _landlord = landlord;
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

  void clear() {
    _landlord = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
