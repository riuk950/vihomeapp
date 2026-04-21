import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../network/network_info.dart';

//Data sources
import '../../data/datasources/datasources.dart';
import '../../data/datasources/property_local_datasource.dart';
import '../../data/datasources/application_datasource.dart';

//Repositorios
import '../../domain/repositories/repositories.dart';
import '../../domain/repositories/application_repository.dart';

//Casos de uso
import '../../domain/usecases/usecases.dart';
import '../../domain/usecases/property/get_property_types_usecase.dart';
import '../../domain/usecases/property/delete_property_usecase.dart';

//Servicios
import '../../infrastructure/services/supabase_service.dart';

//Providers
import '../../presentation/providers/providers.dart';

//Repositorios Data
import '../../data/repositories/repositories.dart';
import '../../data/repositories/application_repository_impl.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  getIt.registerLazySingleton(() => Connectivity());

  // Core
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt<Connectivity>()),
  );

  // Infrastructure
  getIt.registerSingleton<SupabaseService>(SupabaseService.instance);
  await getIt<SupabaseService>().initialize();

  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<SupabaseService>()),
  );
  getIt.registerLazySingleton<PropertyRemoteDataSource>(
    () => PropertyRemoteDataSourceImpl(getIt<SupabaseService>()),
  );
  getIt.registerLazySingleton<PropertyLocalDataSource>(
    () => PropertyLocalDataSourceImpl(
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );
  getIt.registerLazySingleton<TenantRemoteDataSource>(
    () => TenantRemoteDataSourceImpl(getIt<SupabaseService>()),
  );
  getIt.registerLazySingleton<ApplicationDatasource>(
    () => ApplicationDatasourceImpl(getIt<SupabaseService>().client),
  );
  getIt.registerLazySingleton<ProjectRemoteDataSource>(
    () => ProjectRemoteDataSourceImpl(getIt<SupabaseService>()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );
  getIt.registerLazySingleton<PropertyRepository>(
    () => PropertyRepositoryImpl(
      remoteDataSource: getIt<PropertyRemoteDataSource>(),
      localDataSource: getIt<PropertyLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );
  getIt.registerLazySingleton<TenantRepository>(
    () => TenantRepositoryImpl(getIt<TenantRemoteDataSource>()),
  );
  getIt.registerLazySingleton<LandlordRepository>(
    () => LandlordRepositoryImpl(getIt<SupabaseService>()),
  );
  getIt.registerLazySingleton<ApplicationRepository>(
    () => ApplicationRepositoryImpl(getIt<ApplicationDatasource>()),
  );
  getIt.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(getIt<ProjectRemoteDataSource>()),
  );

  // Use cases
  getIt.registerLazySingleton(
    () => GetCurrentUserUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(() => SignInUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
    () => SignInWithGoogleUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(() => SignUpUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SignOutUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
    () => ResetPasswordUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetPropertiesUseCase(getIt<PropertyRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetPropertiesByLandlordUseCase(getIt<PropertyRepository>()),
  );
  getIt.registerLazySingleton(
    () => CreatePropertyUseCase(getIt<PropertyRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdatePropertyUseCase(getIt<PropertyRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeletePropertyUseCase(getIt<PropertyRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetTenantProfileUseCase(getIt<TenantRepository>()),
  );
  getIt.registerLazySingleton(
    () => SaveTenantProfileUseCase(getIt<TenantRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetLandlordProfileUseCase(getIt<LandlordRepository>()),
  );
  getIt.registerLazySingleton(
    () => SaveLandlordProfileUseCase(getIt<LandlordRepository>()),
  );

  getIt.registerLazySingleton(
    () => GetPropertyTypesUseCase(getIt<PropertyRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetProjectsUseCase(getIt<ProjectRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetConstructoraUseCase(getIt<ProjectRepository>()),
  );

  // Providers
  getIt.registerFactory(
    () => AuthProvider(
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      signInUseCase: getIt<SignInUseCase>(),
      signInWithGoogleUseCase: getIt<SignInWithGoogleUseCase>(),
      signUpUseCase: getIt<SignUpUseCase>(),
      signOutUseCase: getIt<SignOutUseCase>(),
      resetPasswordUseCase: getIt<ResetPasswordUseCase>(),
    ),
  );
  getIt.registerFactory(
    () => PropertyProvider(
      getPropertiesUseCase: getIt<GetPropertiesUseCase>(),
      getPropertyTypesUseCase: getIt<GetPropertyTypesUseCase>(),
    ),
  );
  getIt.registerFactory(
    () => LandlordPropertiesProvider(
      getPropertiesByLandlordUseCase: getIt<GetPropertiesByLandlordUseCase>(),
      createPropertyUseCase: getIt<CreatePropertyUseCase>(),
      updatePropertyUseCase: getIt<UpdatePropertyUseCase>(),
      deletePropertyUseCase: getIt<DeletePropertyUseCase>(),
    ),
  );
  getIt.registerFactory(
    () => TenantProvider(
      getTenantProfileUseCase: getIt<GetTenantProfileUseCase>(),
      saveTenantProfileUseCase: getIt<SaveTenantProfileUseCase>(),
    ),
  );
  getIt.registerFactory(
    () => LandlordProvider(
      getLandlordProfileUseCase: getIt<GetLandlordProfileUseCase>(),
      saveLandlordProfileUseCase: getIt<SaveLandlordProfileUseCase>(),
    ),
  );
  getIt.registerFactory(
    () => ApplicationProvider(getIt<ApplicationRepository>()),
  );
  getIt.registerFactory(
    () => ProjectProvider(getProjectsUseCase: getIt<GetProjectsUseCase>()),
  );
}
