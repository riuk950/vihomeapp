import 'package:flutter/foundation.dart';
import '../../domain/entities/property.dart';
import '../../domain/usecases/property/get_properties_usecase.dart';
import '../../domain/usecases/property/get_property_types_usecase.dart';
import '../../domain/entities/property_type.dart';

class PropertyProvider with ChangeNotifier {
  final GetPropertiesUseCase getPropertiesUseCase;
  final GetPropertyTypesUseCase getPropertyTypesUseCase;

  List<Property> _allProperties = [];
  List<Property> _filteredProperties = [];
  List<PropertyType> _propertyTypes = [];
  PropertyType? _selectedType;
  bool _isLoading = false;
  String? _errorMessage;

  List<Property> get properties => _filteredProperties;
  List<PropertyType> get propertyTypes => _propertyTypes;
  PropertyType? get selectedType => _selectedType;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PropertyProvider({
    required this.getPropertiesUseCase,
    required this.getPropertyTypesUseCase,
  }) {
    fetchProperties();
    fetchPropertyTypes();
  }

  Future<void> fetchProperties() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await getPropertiesUseCase();

      result.fold(
        (failure) {
          _setError(failure.message);
          _setLoading(false);
        },
        (properties) {
          _allProperties = properties;
          _applyFilter();
          _setLoading(false);
        },
      );
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  Future<void> fetchPropertyTypes() async {
    final result = await getPropertyTypesUseCase();
    result.fold(
      (failure) => _setError(failure.message),
      (types) {
        _propertyTypes = types;
        notifyListeners();
      },
    );
  }

  void selectType(PropertyType? type) {
    _selectedType = type;
    _applyFilter();
  }

  void _applyFilter() {
    if (_selectedType == null) {
      _filteredProperties = List.from(_allProperties);
    } else {
      _filteredProperties = _allProperties
          .where((p) => p.tipoPropiedad == _selectedType!.nombre)
          .toList();
    }
    notifyListeners();
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
