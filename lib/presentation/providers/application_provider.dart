import 'package:flutter/material.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/repositories/application_repository.dart';

class ApplicationProvider extends ChangeNotifier {
  final ApplicationRepository repository;

  ApplicationProvider(this.repository);

  List<Application> _applications = [];
  List<Application> get applications => _applications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Filtros UI
  String _currentFilter = 'Todas';
  String get currentFilter => _currentFilter;

  List<Application> get filteredApplications {
    if (_currentFilter == 'Todas') return _applications;
    if (_currentFilter == 'Pendientes') {
      return _applications
          .where((a) => a.estado.toLowerCase() == 'pendiente')
          .toList();
    }
    if (_currentFilter == 'Revisadas') {
      return _applications
          .where((a) => a.estado.toLowerCase() != 'pendiente')
          .toList();
    }
    if (_currentFilter == 'Aceptadas') {
      return _applications
          .where((a) => a.estado.toLowerCase() == 'aceptada')
          .toList();
    }
    return _applications;
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<void> fetchLandlordApplications(String landlordId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final apps = await repository.getLandlordApplications(landlordId);
      _applications = List<Application>.from(apps);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTenantApplications(String tenantId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final apps = await repository.getTenantApplications(tenantId);
      _applications = List<Application>.from(apps);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus(String applicationId, String newStatus) async {
    try {
      final success = await repository.updateApplicationStatus(
        applicationId,
        newStatus,
      );
      if (success) {
        final index = _applications.indexWhere((a) => a.id == applicationId);
        if (index != -1) {
          _applications[index] = _applications[index].copyWith(
            estado: newStatus,
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<Application?> createApplication(Application application) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newApplication = await repository.createApplication(application);
      // Agregar la nueva aplicación a la lista local
      _applications.insert(0, newApplication);
      return newApplication;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> hasApplicationForProperty(
    String tenantId,
    String propertyId,
  ) async {
    try {
      return await repository.hasApplicationForProperty(tenantId, propertyId);
    } catch (e) {
      return false;
    }
  }

  void clear() {
    _applications = [];
    _errorMessage = null;
    _isLoading = false;
    _currentFilter = 'Todas';
    notifyListeners();
  }
}
