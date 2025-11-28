import 'package:flutter/foundation.dart';
import '../../domain/entities/property.dart';
import '../../domain/usecases/property/get_properties_by_landlord_usecase.dart';

class LandlordPropertiesProvider with ChangeNotifier {
  final GetPropertiesByLandlordUseCase getPropertiesByLandlordUseCase;

  List<Property> _properties = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Property> get properties => _properties;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get activePropertiesCount => _properties.where((p) => p.publicado).length;
  int get inactivePropertiesCount =>
      _properties.where((p) => !p.publicado).length;

  LandlordPropertiesProvider({required this.getPropertiesByLandlordUseCase});

  Future<void> fetchPropertiesByLandlord(String landlordId) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await getPropertiesByLandlordUseCase(landlordId);

      result.fold(
        (failure) {
          _setError(failure.message);
          _setLoading(false);
        },
        (properties) {
          _properties = properties;
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
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
}
