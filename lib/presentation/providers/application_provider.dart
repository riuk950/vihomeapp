import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/repositories/application_repository.dart';
import 'package:vihomeapp/infrastructure/services/supabase_service.dart';

class ApplicationProvider extends ChangeNotifier {
  final ApplicationRepository repository;
  RealtimeChannel? _subscription;
  DateTime? _lastViewedAt;

  ApplicationProvider(this.repository) {
    loadLastViewed();
  }

  List<Application> _applications = [];
  List<Application> get applications => _applications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Contador inteligente para Arrendatario (Tenant)
  int get unreadTenantCount {
    if (_lastViewedAt == null) {
      // Si nunca ha entrado, contamos todas las que no están pendientes
      return _applications
          .where((a) => a.estado.toLowerCase() != 'pendiente')
          .length;
    }
    return _applications
        .where((a) =>
            a.estado.toLowerCase() != 'pendiente' &&
            a.updatedAt.isAfter(_lastViewedAt!))
        .length;
  }

  // Contador inteligente para Arrendador (Landlord)
  int get unreadLandlordCount {
    // Para el arrendador es más simple: las que están pendientes
    return _applications
        .where((a) => a.estado.toLowerCase() == 'pendiente')
        .length;
  }

  Future<void> loadLastViewed() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString('last_notifications_viewed');
    if (timestamp != null) {
      _lastViewedAt = DateTime.parse(timestamp);
      notifyListeners();
    }
  }

  Future<void> markAsRead() async {
    _lastViewedAt = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'last_notifications_viewed', _lastViewedAt!.toIso8601String());
    notifyListeners();
  }

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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchLandlordApplications(String landlordId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final apps = await repository.getLandlordApplications(landlordId);
      _applications = List<Application>.from(apps);

      // Iniciar escucha en tiempo real después de la carga inicial
      _subscribeToLandlordApplications(landlordId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _subscribeToLandlordApplications(String landlordId) {
    // Cancelar suscripción previa si existe
    _subscription?.unsubscribe();

    final client = SupabaseService.instance.client;

    _subscription = client
        .channel('public:solicitudes:arrendador:$landlordId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'solicitudes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'arrendador_id',
            value: landlordId,
          ),
          callback: (payload) async {
            debugPrint('🔔 Nueva solicitud recibida en tiempo real!');
            // Al recibir una inserción, volvemos a cargar para traer datos relacionados
            final apps = await repository.getLandlordApplications(landlordId);
            _applications = List<Application>.from(apps);
            notifyListeners();
          },
        )
        .subscribe();
  }

  Future<void> fetchTenantApplications(String tenantId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final apps = await repository.getTenantApplications(tenantId);
      _applications = List<Application>.from(apps);

      // Iniciar escucha en tiempo real para el arrendatario (cambios de estado)
      _subscribeToTenantApplications(tenantId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _subscribeToTenantApplications(String tenantId) {
    // Cancelar suscripción previa si existe
    _subscription?.unsubscribe();

    final client = SupabaseService.instance.client;

    _subscription = client
        .channel('public:solicitudes:arrendatario:$tenantId')
        .onPostgresChanges(
          event:
              PostgresChangeEvent.update, // Escuchar actualizaciones de estado
          schema: 'public',
          table: 'solicitudes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'arrendatario_id',
            value: tenantId,
          ),
          callback: (payload) async {
            debugPrint(
                '🔔 Estado de solicitud actualizado para el arrendatario!');
            // Recargamos para obtener los datos actualizados con joins (nombre propiedad, etc)
            final apps = await repository.getTenantApplications(tenantId);
            _applications = List<Application>.from(apps);
            notifyListeners();
          },
        )
        .subscribe();
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

  Future<bool> hasAcceptedApplicationsForProperty(String propertyId) async {
    try {
      return await repository.hasAcceptedApplicationsForProperty(propertyId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteApplication(String applicationId) async {
    try {
      final success = await repository.deleteApplication(applicationId);
      if (success) {
        _applications.removeWhere((a) => a.id == applicationId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteApplicationsForProperty(String propertyId) async {
    try {
      final success =
          await repository.deleteApplicationsForProperty(propertyId);
      if (success) {
        _applications.removeWhere((a) => a.propiedadId == propertyId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clear() {
    _subscription?.unsubscribe();
    _subscription = null;
    _applications = [];
    _errorMessage = null;
    _isLoading = false;
    _currentFilter = 'Todas';
    notifyListeners();
  }
}
