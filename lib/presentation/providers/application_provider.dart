import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vihomeapp/core/utils/context_form_validator.dart';
import 'package:vihomeapp/core/utils/property_category_resolver.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/entities/application_context_data.dart';
import 'package:vihomeapp/domain/repositories/application_repository.dart';
import 'package:vihomeapp/domain/services/i_realtime_service.dart';
import 'package:vihomeapp/infrastructure/services/supabase_service.dart';

class ApplicationProvider extends ChangeNotifier {
  final ApplicationRepository repository;
  final IRealtimeService? realtimeService;
  RealtimeChannel? _subscription;
  StreamSubscription<dynamic>? _realtimeStreamSub;
  DateTime? _lastViewedAt;

  ApplicationProvider(this.repository, {this.realtimeService}) {
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getString('last_notifications_viewed');
      if (timestamp != null) {
        _lastViewedAt = DateTime.parse(timestamp);
        notifyListeners();
      }
    } catch (_) {
      // SharedPreferences depends on Flutter binding initialization.
      // Some tests and startup code create the provider before that happens.
    }
  }

  Future<void> markAsRead() async {
    _lastViewedAt = DateTime.now();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'last_notifications_viewed', _lastViewedAt!.toIso8601String());
    } catch (_) {
      // Ignore persistence errors until the Flutter binding is ready.
    }
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
    _realtimeStreamSub?.cancel();
    _realtimeStreamSub = null;
    _subscription?.unsubscribe();
    _subscription = null;

    if (realtimeService != null) {
      final stream = realtimeService!.subscribeToTable<Application>(
        table: 'solicitudes',
        filterColumn: 'arrendador_id',
        filterValue: landlordId,
        fromJson: (json) => Application(
          id: json['id']?.toString() ?? '',
          arrendatarioId: json['arrendatario_id']?.toString() ?? '',
          arrendadorId: json['arrendador_id']?.toString() ?? '',
          propiedadId: json['propiedad_id']?.toString() ?? '',
          estado: json['estado']?.toString() ?? 'Pendiente',
          createdAt: json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
          updatedAt: json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
        ),
      );

      _realtimeStreamSub = stream.listen((_) async {
        debugPrint('🔔 Nueva solicitud recibida en tiempo real via IRealtimeService!');
        final apps = await repository.getLandlordApplications(landlordId);
        _applications = List<Application>.from(apps);
        notifyListeners();
      });
      return;
    }

    try {
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
              final apps = await repository.getLandlordApplications(landlordId);
              _applications = List<Application>.from(apps);
              notifyListeners();
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('[ApplicationProvider] Error conectando a Supabase realtime: $e');
    }
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
    _realtimeStreamSub?.cancel();
    _realtimeStreamSub = null;
    _subscription?.unsubscribe();
    _subscription = null;

    if (realtimeService != null) {
      final stream = realtimeService!.subscribeToTable<Application>(
        table: 'solicitudes',
        filterColumn: 'arrendatario_id',
        filterValue: tenantId,
        fromJson: (json) => Application(
          id: json['id']?.toString() ?? '',
          arrendatarioId: json['arrendatario_id']?.toString() ?? '',
          arrendadorId: json['arrendador_id']?.toString() ?? '',
          propiedadId: json['propiedad_id']?.toString() ?? '',
          estado: json['estado']?.toString() ?? 'Pendiente',
          createdAt: json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
          updatedAt: json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
        ),
      );

      _realtimeStreamSub = stream.listen((_) async {
        debugPrint('🔔 Estado de solicitud actualizado via IRealtimeService!');
        final apps = await repository.getTenantApplications(tenantId);
        _applications = List<Application>.from(apps);
        notifyListeners();
      });
      return;
    }

    try {
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
              final apps = await repository.getTenantApplications(tenantId);
              _applications = List<Application>.from(apps);
              notifyListeners();
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('[ApplicationProvider] Error conectando a Supabase realtime: $e');
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

  // ==========================================
  // Soporte Contextual y Validación en Vivo [RF-13, RF-14, RF-15, RF-16, RNF-08, RNF-09]
  // ==========================================

  PropertyCategory _currentCategory = PropertyCategory.residential;
  PropertyCategory get currentCategory => _currentCategory;

  // Controladores Residenciales [RF-14]
  final TextEditingController occupantsController = TextEditingController();
  final TextEditingController familyDescriptionController = TextEditingController();
  bool _hasPets = false;
  bool get hasPets => _hasPets;
  final TextEditingController petDetailsController = TextEditingController();

  void setHasPets(bool value) {
    _hasPets = value;
    notifyListeners();
  }

  // Controladores Individual / Habitación [RF-15]
  String? _selectedOccupation = 'Estudiante';
  String? get selectedOccupation => _selectedOccupation;
  final TextEditingController workplaceOrSchoolController = TextEditingController();
  bool _isMinor = false;
  bool get isMinor => _isMinor;
  final TextEditingController guardianNameController = TextEditingController();
  final TextEditingController guardianPhoneController = TextEditingController();
  String? _guardianRelationship = 'Padre/Madre';
  String? get guardianRelationship => _guardianRelationship;

  void setSelectedOccupation(String? value) {
    _selectedOccupation = value;
    notifyListeners();
  }

  void setIsMinor(bool value) {
    _isMinor = value;
    notifyListeners();
  }

  void setGuardianRelationship(String? value) {
    _guardianRelationship = value;
    notifyListeners();
  }

  // Controladores Comercial [RF-16]
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController nitController = TextEditingController();
  final TextEditingController economicActivityController = TextEditingController();

  /// Inicializa la categoría contextual según el tipo de inmueble
  void initContextualForm(String? propertyType) {
    _currentCategory = PropertyCategoryResolver.resolve(propertyType);
    notifyListeners();
  }

  /// Notifica cambios en los campos de texto para actualizar la validación en vivo
  void notifyValidationChange() {
    notifyListeners();
  }

  /// Indica si el formulario contextual actual cumple todas las validaciones de negocio
  bool get isContextualFormValid {
    switch (_currentCategory) {
      case PropertyCategory.residential:
        final occErr = ContextualFormValidator.validateOccupants(occupantsController.text);
        final descErr = ContextualFormValidator.validateFamilyDescription(familyDescriptionController.text);
        final petErr = ContextualFormValidator.validatePetDetails(
          hasPets: _hasPets,
          details: petDetailsController.text,
        );
        return occErr == null && descErr == null && petErr == null;

      case PropertyCategory.individual:
        final occErr = ContextualFormValidator.validateOccupation(_selectedOccupation);
        final workErr = ContextualFormValidator.validateWorkplaceOrSchool(workplaceOrSchoolController.text);
        if (occErr != null || workErr != null) return false;

        if (_isMinor) {
          final nameErr = ContextualFormValidator.validateGuardianName(
            isMinor: true,
            name: guardianNameController.text,
          );
          final phoneErr = ContextualFormValidator.validateGuardianPhone(
            isMinor: true,
            phone: guardianPhoneController.text,
          );
          final relErr = ContextualFormValidator.validateGuardianRelationship(
            isMinor: true,
            relationship: _guardianRelationship,
          );
          return nameErr == null && phoneErr == null && relErr == null;
        }
        return true;

      case PropertyCategory.commercial:
        final bizErr = ContextualFormValidator.validateBusinessName(businessNameController.text);
        final nitErr = ContextualFormValidator.validateNit(nitController.text);
        final actErr = ContextualFormValidator.validateEconomicActivity(economicActivityController.text);
        return bizErr == null && nitErr == null && actErr == null;
    }
  }

  /// Construye la entidad de datos contextuales según la categoría y flags activos
  ApplicationContextData? buildContextData() {
    switch (_currentCategory) {
      case PropertyCategory.residential:
        return ResidentialContextData(
          numeroOcupantes: int.tryParse(occupantsController.text.trim()) ?? 1,
          descripcionFamiliar: familyDescriptionController.text.trim(),
          tieneMascotas: _hasPets,
          detalleMascotas: _hasPets ? petDetailsController.text.trim() : null,
        );

      case PropertyCategory.individual:
        GuardianInfo? guardian;
        if (_isMinor) {
          guardian = GuardianInfo(
            nombreCompleto: guardianNameController.text.trim(),
            telefono: guardianPhoneController.text.trim(),
            parentesco: _guardianRelationship ?? 'Padre/Madre',
          );
        }
        return IndividualContextData(
          ocupacion: _selectedOccupation ?? 'Estudiante',
          entidadLaboralEducativa: workplaceOrSchoolController.text.trim(),
          esMenorDeEdad: _isMinor,
          acudiente: guardian,
        );

      case PropertyCategory.commercial:
        return CommercialContextData(
          razonSocial: businessNameController.text.trim(),
          nit: nitController.text.trim(),
          actividadEconomica: economicActivityController.text.trim(),
        );
    }
  }

  /// Envía la solicitud incorporando los datos contextuales y previniendo duplicados [CL-10, CL-13]
  Future<bool> submitContextualApplication({
    required String tenantId,
    required String landlordId,
    required String propertyId,
    required String ingresosMensuales,
    String? documentoUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final hasActive = await hasApplicationForProperty(tenantId, propertyId);
      if (hasActive) {
        _errorMessage = 'Ya tienes una solicitud en proceso para esta propiedad.';
        return false;
      }

      final contextData = buildContextData();
      final newApp = Application(
        id: '',
        arrendatarioId: tenantId,
        arrendadorId: landlordId,
        propiedadId: propertyId,
        estado: 'Pendiente',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ingresosMensuales: ingresosMensuales,
        documentoUrl: documentoUrl,
        datosContextuales: contextData,
      );

      final created = await repository.createApplication(newApp);
      _applications.insert(0, created);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reinicia los valores y controladores del formulario contextual
  void resetContextualForm() {
    occupantsController.clear();
    familyDescriptionController.clear();
    _hasPets = false;
    petDetailsController.clear();

    _selectedOccupation = 'Estudiante';
    workplaceOrSchoolController.clear();
    _isMinor = false;
    guardianNameController.clear();
    guardianPhoneController.clear();
    _guardianRelationship = 'Padre/Madre';

    businessNameController.clear();
    nitController.clear();
    economicActivityController.clear();
    notifyListeners();
  }

  void clear() {
    _realtimeStreamSub?.cancel();
    _realtimeStreamSub = null;
    realtimeService?.unsubscribeAll();
    _subscription?.unsubscribe();
    _subscription = null;
    _applications = [];
    _errorMessage = null;
    _isLoading = false;
    _currentFilter = 'Todas';
    resetContextualForm();
    notifyListeners();
  }

  @override
  void dispose() {
    _realtimeStreamSub?.cancel();
    _realtimeStreamSub = null;
    realtimeService?.unsubscribeAll();
    _subscription?.unsubscribe();
    _subscription = null;

    occupantsController.dispose();
    familyDescriptionController.dispose();
    petDetailsController.dispose();
    workplaceOrSchoolController.dispose();
    guardianNameController.dispose();
    guardianPhoneController.dispose();
    businessNameController.dispose();
    nitController.dispose();
    economicActivityController.dispose();

    super.dispose();
  }
}
