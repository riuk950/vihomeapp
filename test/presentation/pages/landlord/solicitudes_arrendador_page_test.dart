import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/domain/entities/application.dart';
import 'package:vihomeapp/domain/repositories/application_repository.dart';
import 'package:vihomeapp/presentation/pages/landlord/solicitudes_arrendador_page.dart';
import 'package:vihomeapp/presentation/pages/landlord/widgets/application_card_landlord.dart';
import 'package:vihomeapp/presentation/providers/application_provider.dart';
import 'package:vihomeapp/presentation/widgets/solicitudes_empty_state.dart';
import 'package:vihomeapp/presentation/widgets/solicitudes_filter_bar.dart';

class MockAppRepository implements ApplicationRepository {
  List<Application> landlordApps = [];
  List<Application> tenantApps = [];
  bool throwOnGet = false;

  @override
  Future<List<Application>> getLandlordApplications(String landlordId) async {
    if (throwOnGet) throw Exception('Error de conexión con el servidor');
    return landlordApps;
  }

  @override
  Future<List<Application>> getTenantApplications(String tenantId) async => tenantApps;

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
    id: 'app-pend-1',
    arrendatarioId: 't-1',
    arrendadorId: 'l-1',
    propiedadId: 'p-1',
    estado: 'pendiente',
    nombreArrendatario: 'Carlos Restrepo',
    telefonoArrendatario: '3124567890',
    tituloPropiedad: 'Apartamento 402 Los Sauces',
    createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
  );

  final appAceptada = Application(
    id: 'app-acep-2',
    arrendatarioId: 't-2',
    arrendadorId: 'l-1',
    propiedadId: 'p-2',
    estado: 'aceptada',
    nombreArrendatario: 'Laura Morales',
    telefonoArrendatario: '3151112233',
    tituloPropiedad: 'Casa Campestre El Retiro',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
  );

  final appRechazada = Application(
    id: 'app-rech-3',
    arrendatarioId: 't-3',
    arrendadorId: 'l-1',
    propiedadId: 'p-3',
    estado: 'rechazada',
    nombreArrendatario: 'Juan Duque',
    telefonoArrendatario: '3009876543',
    tituloPropiedad: 'Habitación Universitaria',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
  );

  Widget createTestWidget(ApplicationProvider appProvider) {
    return MaterialApp(
      home: ChangeNotifierProvider<ApplicationProvider>.value(
        value: appProvider,
        child: const SolicitudesArrendadorPage(),
      ),
    );
  }

  setUp(() {
    mockRepo = MockAppRepository();
    provider = ApplicationProvider(mockRepo);
  });

  group('SolicitudesArrendadorPage (Tarea 5.1 / RF-18.1, RF-18.2, RF-20, RF-21, RF-22, QA 1.5, QA 1.7)', () {
    testWidgets('debe renderizar la barra de filtros con conteos y las tarjetas recibidas',
        (tester) async {
      mockRepo.landlordApps = [appPendiente, appAceptada, appRechazada];
      await provider.fetchLandlordApplications('l-1');

      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Barra de filtros con sus conteos dinámicos
      expect(find.byType(SolicitudesFilterBar), findsOneWidget);
      expect(find.text('Todas (3)'), findsOneWidget);
      expect(find.text('Pendientes (1)'), findsOneWidget);
      expect(find.text('Aceptadas (1)'), findsOneWidget);
      expect(find.text('Rechazadas (1)'), findsOneWidget);

      // Tarjetas de solicitudes renderizadas
      expect(find.byType(ApplicationCardLandlord), findsNWidgets(3));
      expect(find.text('Carlos Restrepo'), findsOneWidget);
      expect(find.text('Laura Morales'), findsOneWidget);
      expect(find.text('Juan Duque'), findsOneWidget);
    });

    testWidgets('debe permitir filtrar por estado de forma reactiva al presionar los chips',
        (tester) async {
      mockRepo.landlordApps = [appPendiente, appAceptada, appRechazada];
      await provider.fetchLandlordApplications('l-1');

      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Inicialmente en 'Todas'
      expect(find.byType(ApplicationCardLandlord), findsNWidgets(3));

      // Seleccionar 'Pendientes'
      await tester.tap(find.byKey(const Key('filter_chip_pendientes')));
      await tester.pumpAndSettle();

      expect(find.byType(ApplicationCardLandlord), findsOneWidget);
      expect(find.text('Carlos Restrepo'), findsOneWidget);
      expect(find.text('Laura Morales'), findsNothing);

      // Seleccionar 'Aceptadas'
      final chipAceptadas = find.byKey(const Key('filter_chip_aceptadas'));
      await tester.ensureVisible(chipAceptadas);
      await tester.tap(chipAceptadas);
      await tester.pumpAndSettle();

      expect(find.byType(ApplicationCardLandlord), findsOneWidget);
      expect(find.text('Laura Morales'), findsOneWidget);

      // Seleccionar 'Rechazadas'
      final chipRechazadas = find.byKey(const Key('filter_chip_rechazadas'));
      await tester.ensureVisible(chipRechazadas);
      await tester.tap(chipRechazadas);
      await tester.pumpAndSettle();

      expect(find.byType(ApplicationCardLandlord), findsOneWidget);
      expect(find.text('Juan Duque'), findsOneWidget);
    });

    testWidgets('debe mostrar botones de llamada y WhatsApp en pendientes y aceptadas, y omitir en rechazadas (QA 1.7)',
        (tester) async {
      mockRepo.landlordApps = [appPendiente, appAceptada, appRechazada];
      await provider.fetchLandlordApplications('l-1');

      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Debe haber botones de contacto para pendiente y aceptada (2 pares = 2 llamadas, 2 whatsapps)
      expect(find.byKey(const Key('contact_call_button')), findsNWidgets(2));
      expect(find.byKey(const Key('contact_whatsapp_button')), findsNWidgets(2));
    });

    testWidgets('debe mostrar estado vacío global cuando el arrendador no tiene solicitudes (RF-22.1)',
        (tester) async {
      mockRepo.landlordApps = [];
      await provider.fetchLandlordApplications('l-1');

      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      expect(find.byType(SolicitudesEmptyState), findsOneWidget);
      expect(find.text('No tienes solicitudes recibidas'), findsOneWidget);
      expect(find.text('Ver mis propiedades'), findsOneWidget);
    });

    testWidgets('debe mostrar estado vacío de filtro cuando una categoría no tiene elementos (RF-22.2)',
        (tester) async {
      // Solo una solicitud pendiente
      mockRepo.landlordApps = [appPendiente];
      await provider.fetchLandlordApplications('l-1');

      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      // Filtrar por 'Aceptadas' (con 0 elementos)
      final chipAceptadas = find.byKey(const Key('filter_chip_aceptadas'));
      await tester.ensureVisible(chipAceptadas);
      await tester.tap(chipAceptadas);
      await tester.pumpAndSettle();

      expect(find.byType(ApplicationCardLandlord), findsNothing);
      expect(find.byType(SolicitudesEmptyState), findsOneWidget);
      expect(find.textContaining('Aceptadas'), findsWidgets);
      expect(find.text('Ver todas'), findsOneWidget);

      // Presionar 'Ver todas' restaura el filtro
      await tester.tap(find.text('Ver todas'));
      await tester.pumpAndSettle();

      expect(find.byType(ApplicationCardLandlord), findsOneWidget);
      expect(find.text('Carlos Restrepo'), findsOneWidget);
    });

    testWidgets('debe tolerar pull-to-refresh y retener datos si falla la red (RF-22.3, QA 1.14)',
        (tester) async {
      mockRepo.landlordApps = [appPendiente];
      await provider.fetchLandlordApplications('l-1');

      await tester.pumpWidget(createTestWidget(provider));
      await tester.pumpAndSettle();

      expect(find.text('Carlos Restrepo'), findsOneWidget);

      // Ahora simulamos que la red falla durante el refresh
      mockRepo.throwOnGet = true;

      // Disparamos refresh gesture
      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Los datos anteriores deben conservarse en pantalla (resiliencia)
      expect(find.text('Carlos Restrepo'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('No se pudo actualizar'), findsOneWidget);
    });
  });
}
