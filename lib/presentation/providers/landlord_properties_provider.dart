import 'package:flutter/foundation.dart';
import '../../domain/entities/property.dart';
import '../../domain/usecases/property/get_properties_by_landlord_usecase.dart';
import '../../domain/usecases/property/create_property_usecase.dart';
import '../../domain/usecases/property/update_property_usecase.dart';
import '../../domain/usecases/property/delete_property_usecase.dart';

class LandlordPropertiesProvider with ChangeNotifier {
  final GetPropertiesByLandlordUseCase getPropertiesByLandlordUseCase;
  final CreatePropertyUseCase createPropertyUseCase;
  final UpdatePropertyUseCase updatePropertyUseCase;
  final DeletePropertyUseCase deletePropertyUseCase;

  List<Property> _properties = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Property> get properties => _properties;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get activePropertiesCount => _properties.where((p) => p.publicado).length;
  int get inactivePropertiesCount =>
      _properties.where((p) => !p.publicado).length;

  LandlordPropertiesProvider({
    required this.getPropertiesByLandlordUseCase,
    required this.createPropertyUseCase,
    required this.updatePropertyUseCase,
    required this.deletePropertyUseCase,
  });

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

  Future<bool> createProperty(Map<String, dynamic> propertyData) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await createPropertyUseCase(propertyData);

      return result.fold(
        (failure) {
          _setError(failure.message);
          _setLoading(false);
          return false;
        },
        (property) {
          _properties.add(property);
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

  Future<bool> togglePropertyPublication(
    String propertyId,
    bool currentStatus,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await updatePropertyUseCase(propertyId, {
        'publicado': !currentStatus,
      });

      return result.fold(
        (failure) {
          _setError(failure.message);
          _setLoading(false);
          return false;
        },
        (updatedProperty) {
          final index = _properties.indexWhere((p) => p.id == propertyId);
          if (index != -1) {
            _properties[index] = updatedProperty;
          }
          _setLoading(false);
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteProperty(String id) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await deletePropertyUseCase(id);

      return result.fold(
        (failure) {
          _setError(failure.message);
          _setLoading(false);
          return false;
        },
        (_) {
          _properties.removeWhere((p) => p.id == id);
          _setLoading(false);
          notifyListeners();
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

  void clear() {
    _properties = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
