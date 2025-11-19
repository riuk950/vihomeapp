import 'package:get_it/get_it.dart';
import 'package:vihomeapp/presentation/providers/property_provider.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/property_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/property_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/property_repository.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/reset_password_usecase.dart';
import '../../domain/usecases/auth/sign_in_usecase.dart';
import '../../domain/usecases/auth/sign_out_usecase.dart';
import '../../domain/usecases/auth/sign_up_usecase.dart';
import '../../domain/usecases/property/get_properties_usecase.dart';
import '../../infrastructure/services/supabase_service.dart';
import '../../presentation/providers/auth_provider.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
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

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );
  getIt.registerLazySingleton<PropertyRepository>(
    () => PropertyRepositoryImpl(getIt<PropertyRemoteDataSource>()),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetCurrentUserUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SignInUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SignUpUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SignOutUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => ResetPasswordUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GetPropertiesUseCase(getIt<PropertyRepository>()));

  // Providers
  getIt.registerFactory(
    () => AuthProvider(
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      signInUseCase: getIt<SignInUseCase>(),
      signUpUseCase: getIt<SignUpUseCase>(),
      signOutUseCase: getIt<SignOutUseCase>(),
      resetPasswordUseCase: getIt<ResetPasswordUseCase>(),
    ),
  );
  getIt.registerFactory(
    () => PropertyProvider(
      getPropertiesUseCase: getIt<GetPropertiesUseCase>(),
    ),
  );
}

