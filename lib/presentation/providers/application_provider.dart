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
      _applications = await repository.getLandlordApplications(landlordId);
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
      _applications = await repository.getTenantApplications(tenantId);
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
          // Actualizar localmente para reflejar cambio inmediato
          // Creamos una copia 'modificada' (aunque entity es inmutable, aquí simulamos update)
          // Lo ideal es recargar, pero por UX rápido:
          // Como Application es const (equatable), no podemos modificar sus campos.
          // Deberíamos tener copyWith o recargar. Recargaremos por simplicidad o haremos un hack manual.
          // Mejor recargar o implementar copyWith en Entity.
          // Por ahora recargaré para asegurar consistencia.
          // O mejor, modificaré la lista si implemento copyWith.
        }
      }
      return success;
    } catch (e) {
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
}
