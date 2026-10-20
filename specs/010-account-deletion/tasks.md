# Plan de Tareas: Eliminación de Cuenta y Limpieza Integral de Datos

## Fase 1: Base de Datos y Backend (RPC en Supabase)
- [x] **Tarea 1.1:** Crear script SQL `supabase/delete_user_account.sql` con la función `delete_user_account()` en PostgreSQL con `SECURITY DEFINER`. [RF-55, RNF-35, RNF-36, DT-1]
- [x] **Tarea 1.2:** Configurar verificación estricta de `auth.uid()`, eliminación en cascada (`reviews`, `solicitudes`, `propiedades`, `info_arrendatarios`, `info_arrendadores`, `profiles`, `auth.users`) y control de permisos (`REVOKE EXECUTE ON FUNCTION delete_user_account() FROM public; GRANT EXECUTE ON FUNCTION delete_user_account() FROM authenticated;`). [RF-55, RNF-35, RNF-36, DT-1]

## Fase 2: Capa de Datos y Dominio (Clean Architecture)
- [x] **Tarea 2.1:** Modificar `AuthRemoteDataSource` y `AuthRemoteDataSourceImpl` (`lib/data/datasources/auth_remote_datasource.dart`) para añadir el método `Future<void> deleteAccount();` que invoque el RPC `delete_user_account`. [RF-55, DT-2]
- [x] **Tarea 2.2:** Declarar `Future<Either<Failure, void>> deleteAccount();` en `AuthRepository` (`lib/domain/repositories/auth_repository.dart`) e implementarlo en `AuthRepositoryImpl` (`lib/data/repositories/auth_repository_impl.dart`) con manejo de excepciones `SupabaseErrorHandler`. [RF-55, RF-57, DT-2]
- [x] **Tarea 2.3:** Crear el caso de uso `DeleteAccountUseCase` en `lib/domain/usecases/auth/delete_account_usecase.dart` implementando el contrato `UseCase<void, NoParams>`. [RF-55, DT-2]
- [x] **Tarea 2.4:** Registrar `DeleteAccountUseCase` en el contenedor de inyección de dependencias `lib/core/di/injection_container.dart` e inyectarlo en `AuthProvider`. [DT-2]

## Fase 3: Capa de Presentación y Estado (AuthProvider y UI)
- [x] **Tarea 3.1:** Actualizar `AuthProvider` (`lib/presentation/providers/auth_provider.dart`) incorporando `deleteAccount()`: ejecución del caso de uso, reseteo de Providers, limpieza de `SharedPreferences` y cierre de sesión seguro. [RF-56, RF-57, RNF-38, DT-3]
- [x] **Tarea 3.2:** Integrar opción "Eliminar cuenta" con estilo destructivo y diálogo modal de confirmación en el perfil de arrendatario (`lib/presentation/pages/navegation/perfil_page.dart`). [RF-52, RF-54, CA-1, CA-2, CA-4, CA-5, DT-4]
- [x] **Tarea 3.3:** Integrar opción "Eliminar cuenta" con estilo destructivo y diálogo modal de confirmación en el panel de arrendador (`lib/presentation/pages/navegation/panel_page.dart`). [RF-53, RF-54, CA-1, CA-2, CA-4, CA-5, DT-4]

## Fase 4: Pruebas Automatizadas de Unidad y Widget
- [x] **Tarea 4.1:** Crear pruebas unitarias para `DeleteAccountUseCase` y `AuthRepositoryImpl` cubriendo casos de éxito y fallo en `test/domain/usecases/auth/delete_account_usecase_test.dart` y `test/data/repositories/auth_repository_impl_test.dart`. [DT-5, CA-3, CA-5]
- [x] **Tarea 4.2:** Crear pruebas de widget / interacción para el flujo de diálogo de confirmación y eliminación de cuenta en `test/presentation/pages/profile/delete_account_dialog_test.dart`. [DT-5, CA-1, CA-2, CA-4, CA-5]
- [x] **Tarea 4.3:** Ejecutar la suite completa de pruebas unitarias y de widgets (`flutter test`) asegurando 0 regresiones (346/346 superadas). [RNF-38]

## Fase 5: Validación, Análisis Estático y Presentación para Aprobación
- [x] **Tarea 5.1:** Ejecutar análisis estático (`flutter analyze`) garantizando 0 errores y 0 advertencias.
- [ ] **Tarea 5.2:** Presentar resumen técnico de cambios y pruebas para revisión del usuario (sin commit ni cierre en Notion hasta aprobación explícita).
