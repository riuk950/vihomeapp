import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/repositories/application_repository.dart';
import 'package:vihomeapp/presentation/pages/tenant/solicitudes_arrendatario_page.dart';
import 'package:vihomeapp/presentation/pages/tenant/widgets/application_card_tenant.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';
import 'package:vihomeapp/presentation/widgets/solicitudes_empty_state.dart';
import 'package:vihomeapp/presentation/widgets/solicitudes_filter_bar.dart';

class MockAppRepository implements ApplicationRepository {
  List<Application> landlordApps = [];
  List<Application> tenantApps = [];
  bool throwOnGet = false;

  @override
  Future<List<Application>> getLandlordApplications(String landlordId) async => landlordApps;

  @override
  Future<List<Application>> getTenantApplications(String tenantId) async {
    if (throwOnGet) throw Exception('Fallo de red en consulta de solicitudes');
    return tenantApps;
  }

  @override
  Future<bool> updateApplicationStatus(String applicationId, String status) async => true;

  @override
  Future<Application> createApplication(Application application) async => application;

  @override
  Future<bool> hasApplicationForProperty(String tenantId, String propertyId) async => false;

  @override
  Future<bool> hasAcceptedApplicationsForProperty(String propertyId) async => false;

  @override
  Future<bool> deleteApplicationsForProperty(String propertyId) async => true;

  @override
  Future<bool> deleteApplication(String applicationId) async => true;
}

void main() {
  late MockAppRepository mockRepo;
  late ApplicationProvider provider;

  final appPendiente = Application(
    id: 't-app-1',
    arrendatarioId: 'tenant-1',
    arrendadorId: 'landlord-1',
    propiedadId: 'prop-1',
    estado: 'pendiente',
    nombreArrendador: 'Beatriz Salazar',
    telefonoArrendador: '3009876543',
    tituloPropiedad: 'Apartamento en Laureles',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
  );

  final appAceptada = Application(
    id: 't-app-2',
    arrendatarioId: 'tenant-1',
    arrendadorId: 'landlord-2',
    propiedadId: 'prop-2',
    estado: 'aceptada',
    nombreArrendador: 'Carlos Restrepo',
    telefonoArrendador: '3124567890',
    tituloPropiedad: 'Casa Poblado Campestre',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
  );

  final appRechazada = Application(
    id: 't-app-3',
    arrendatarioId: 'tenant-1',
    arrendadorId: 'landlord-3',
    propiedadId: 'prop-3',
    estado: 'rechazada',
    nombreArrendador: 'Mauricio Gomez',
    telefonoArrendador: '3151234567',
    tituloPropiedad: 'Apartaestudio Chapinero',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    updatedAt: DateTime.now().subtract(const Duration(days: 2)),
  );

  Widget createTestWidget(ApplicationProvider appProvider) {
    return MaterialApp(
      home: ChangeNotifierProvider<ApplicationProvider>.value(
        value: appProvider,
        child: const SolicitudesArrendatarioPage(),
      ),
    );
  }

  setUp(() {
    mockRepo = MockAppRepository();
    provider = ApplicationProvider(mockRepo);
  });

  group('SolicitudesArrendatarioPage (Tarea 5.2 / RF-18.3, RF-19, RF-20, RF-21, RF-22, QA 1.6)', () {
    testWidgets('debe renderizar tarjetas con paso siguiente según el estado de cada postulación',
        (tester) async {
      mockRepo.tenantApps = [appPendiente, appAceptada, appRechazada];
      await provider.fetchTenantApplications('tenant-1');

      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      expect(find.byType(SolicitudesFilterBar), findsOneWidget);
      expect(find.byType(ApplicationCardTenant), findsNWidgets(3));

      // Verificamos Paso Siguiente para cada estado (RF-19.1, RF-19.2, RF-19.3)
      expect(find.text('Esperando respuesta del propietario'), findsOneWidget);
      expect(find.text('Contacto habilitado'), findsOneWidget);
      expect(find.text('Solicitud no aprobada'), findsOneWidget);

      // Verificamos que SOLO la solicitud aceptada tenga botones de contacto (RF-19.2, QA 1.6)
      expect(find.byKey(const Key('contact_call_button')), findsOneWidget);
      expect(find.byKey(const Key('contact_whatsapp_button')), findsOneWidget);
    });

    testWidgets('debe filtrar en vivo las postulaciones del arrendatario',
        (tester) async {
      mockRepo.tenantApps = [appPendiente, appAceptada, appRechazada];
      await provider.fetchTenantApplications('tenant-1');

      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Filtrar por 'Pendientes'
      await tester.tap(find.byKey(const Key('filter_chip_pendientes')));
      await tester.pumpAndSettle();

      expect(find.byType(ApplicationCardTenant), findsOneWidget);
      expect(find.text('Apartamento en Laureles'), findsOneWidget);
      expect(find.text('Esperando respuesta del propietario'), findsOneWidget);

      // Filtrar por 'Aceptadas'
      final chipAceptadas = find.byKey(const Key('filter_chip_aceptadas'));
      await tester.ensureVisible(chipAceptadas);
      await tester.tap(chipAceptadas);
      await tester.pumpAndSettle();

      expect(find.byType(ApplicationCardTenant), findsOneWidget);
      expect(find.text('Casa Poblado Campestre'), findsOneWidget);
      expect(find.text('Contacto habilitado'), findsOneWidget);
    });

    testWidgets('debe mostrar estado vacío con botón "Explorar inmuebles" si no hay postulaciones (RF-22.1)',
        (tester) async {
      mockRepo.tenantApps = [];
      await provider.fetchTenantApplications('tenant-1');

      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      expect(find.byType(SolicitudesEmptyState), findsOneWidget);
      expect(find.text('No tienes postulaciones'), findsOneWidget);
      expect(find.text('Explorar inmuebles'), findsOneWidget);
    });

    testWidgets('debe mostrar estado vacío contextual cuando un filtro seleccionado no tiene elementos (RF-22.2)',
        (tester) async {
      // Solo una postulación pendiente
      mockRepo.tenantApps = [appPendiente];
      await provider.fetchTenantApplications('tenant-1');

      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Filtrar por 'Rechazadas' (0 elementos)
      final chipRechazadas = find.byKey(const Key('filter_chip_rechazadas'));
      await tester.ensureVisible(chipRechazadas);
      await tester.tap(chipRechazadas);
      await tester.pumpAndSettle();

      expect(find.byType(ApplicationCardTenant), findsNothing);
      expect(find.byType(SolicitudesEmptyState), findsOneWidget);
      expect(find.textContaining('Rechazadas'), findsWidgets);
      expect(find.text('Ver todas'), findsOneWidget);
    });

    testWidgets('debe soportar pull-to-refresh y retener datos si falla la red (RF-22.3, QA 1.14)',
        (tester) async {
      mockRepo.tenantApps = [appPendiente];
      await provider.fetchTenantApplications('tenant-1');

      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      expect(find.text('Apartamento en Laureles'), findsOneWidget);

      // Simulamos fallo en el refresh
      mockRepo.throwOnGet = true;

      // Deslizamos hacia abajo
      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Los datos previos persisten
      expect(find.text('Apartamento en Laureles'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('No se pudo actualizar'), findsOneWidget);
    });
  });
}
