import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vihomeapp/domain/entities/project.dart';
import 'package:vihomeapp/domain/entities/property_type.dart';
import 'package:vihomeapp/domain/repositories/project_repository.dart';
import 'package:vihomeapp/domain/repositories/property_repository.dart';
import 'package:vihomeapp/domain/usecases/project/get_projects_usecase.dart';
import 'package:vihomeapp/domain/usecases/property/get_properties_usecase.dart';
import 'package:vihomeapp/domain/usecases/property/get_property_types_usecase.dart';
import 'package:vihomeapp/presentation/pages/navegation/mapa_page.dart';
import 'package:vihomeapp/presentation/providers/project_provider.dart';
import 'package:vihomeapp/presentation/providers/property_provider.dart';
import 'package:vihomeapp/core/utils/either.dart';
import 'package:vihomeapp/core/errors/failures.dart';
import 'package:vihomeapp/domain/entities/property.dart';
import 'package:vihomeapp/domain/entities/constructora.dart';

class MockProjectRepository implements ProjectRepository {
  List<Project> projects = [];
  int callCount = 0;

  @override
  Future<List<Project>> getProjects() async {
    callCount++;
    return projects;
  }

  @override
  Future<Constructora> getConstructora(String id) async => const Constructora(
        id: 'const-1',
        nombre: 'Constructora Test',
        nit: '900123456',
      );
}

class MockPropertyRepository implements PropertyRepository {
  List<Property> properties = [];
  int callCount = 0;

  @override
  Future<Either<Failure, List<Property>>> getProperties() async {
    callCount++;
    return Right(properties);
  }

  @override
  Future<Either<Failure, List<PropertyType>>> getPropertyTypes() async =>
      const Right([]);

  @override
  Future<Either<Failure, List<Property>>> getPropertiesByLandlord(
          String landlordId) async =>
      Right(properties);

  @override
  Future<Either<Failure, Property>> createProperty(
          Map<String, dynamic> propertyData) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Property>> updateProperty(
          String id, Map<String, dynamic> data) async =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> deleteProperty(String id) async =>
      const Right(null);
}

void main() {
  late MockProjectRepository mockProjectRepo;
  late MockPropertyRepository mockPropertyRepo;
  late ProjectProvider projectProvider;
  late PropertyProvider propertyProvider;

  final sampleProject = Project(
    id: 'proj-1',
    constructoraId: 'const-1',
    tipoPropiedad: 'Apartamentos',
    precioDesde: 150000000.0,
    precioHasta: 250000000.0,
    habitaciones: 3,
    banos: 2,
    area: 68.5,
    descripcion: 'Hermoso conjunto residencial con piscina y zonas verdes',
    ubicacionPrincipal: 'Torres del Parque',
    lat: 5.715,
    lng: -72.933,
    estrato: 4,
    estado: 'En Construcción',
    parqueaderos: 1,
    financiacion: true,
    coutaInicial: 45000000.0,
    cantidadPisos: 12,
    aplicaSubsidio: false,
    fotos: const ['https://example.com/foto1.jpg'],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    mockProjectRepo = MockProjectRepository();
    mockPropertyRepo = MockPropertyRepository();

    projectProvider = ProjectProvider(
      getProjectsUseCase: GetProjectsUseCase(mockProjectRepo),
    );
    propertyProvider = PropertyProvider(
      getPropertiesUseCase: GetPropertiesUseCase(mockPropertyRepo),
      getPropertyTypesUseCase: GetPropertyTypesUseCase(mockPropertyRepo),
    );
  });

  Widget createWidgetUnderTest({String? tipo}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProjectProvider>.value(value: projectProvider),
        ChangeNotifierProvider<PropertyProvider>.value(value: propertyProvider),
      ],
      child: MaterialApp(
        home: MapaPage(tipo: tipo),
      ),
    );
  }

  group('MapaPage Multimodal & Projects Mode Tests [RF-43, RF-44, RF-45, DT-2, DT-4]', () {
    testWidgets('displays "Mapa de Proyectos" in AppBar when tipo="proyectos"',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(tipo: 'proyectos'));
      await tester.pump();

      expect(find.text('Mapa de Proyectos'), findsOneWidget);
      expect(find.text('Mapa Propiedades'), findsNothing);
    });

    testWidgets('displays "Mapa Propiedades" in AppBar when tipo=null',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(tipo: null));
      await tester.pump();

      expect(find.text('Mapa Propiedades'), findsOneWidget);
      expect(find.text('Mapa de Proyectos'), findsNothing);
    });

    testWidgets('invokes fetchProjects on ProjectProvider when tipo="proyectos"',
        (tester) async {
      mockProjectRepo.projects = [sampleProject];

      await tester.pumpWidget(createWidgetUnderTest(tipo: 'proyectos'));
      await tester.pump();

      expect(mockProjectRepo.callCount, equals(1));
    });

    testWidgets('invokes fetchProperties on PropertyProvider when tipo=null',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(tipo: null));
      await tester.pump();

      expect(mockPropertyRepo.callCount, greaterThanOrEqualTo(1));
    });

    testWidgets('Modal bottom sheet renders project details correctly',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (sheetContext) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(sampleProject.ubicacionPrincipal),
                          Text(sampleProject.estado),
                          Text('${sampleProject.habitaciones} Hab'),
                          Text('${sampleProject.banos} Baños'),
                          Text('${sampleProject.area} m²'),
                          const Text('Precio Desde'),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Ver Detalles'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Torres del Parque'), findsOneWidget);
      expect(find.text('En Construcción'), findsOneWidget);
      expect(find.text('3 Hab'), findsOneWidget);
      expect(find.text('2 Baños'), findsOneWidget);
      expect(find.text('68.5 m²'), findsOneWidget);
      expect(find.text('Precio Desde'), findsOneWidget);
      expect(find.text('Ver Detalles'), findsOneWidget);
    });
  });
}
