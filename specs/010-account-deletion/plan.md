# Plan de Implementación: Eliminación de Cuenta y Limpieza Integral de Datos

## 1. Decisiones Técnicas (DT)

* **DT-1 (Función Almacenada en Supabase con Seguridad a Nivel de Servidor):**
  - Implementar una función PostgreSQL con `SECURITY DEFINER` denominada `delete_user_account()`.
  - La función verificará estrictamente la sesión del llamante mediante `auth.uid()`. Si el identificador es nulo, abortará la ejecución con una excepción.
  - La función ejecutará un borrado en cascada integral sobre las tablas vinculadas (`reviews`, `solicitudes`, `propiedades`, `info_arrendatarios`, `info_arrendadores`, `profiles`) y finalmente sobre `auth.users`.
  - Se restringirá la ejecución: revocada para el rol `public` y otorgada exclusivamente al rol `authenticated`.
  - El script SQL se versionará en el repositorio en `supabase/delete_user_account.sql`.

* **DT-2 (Integración en la Capa de Datos y Dominio - Clean Architecture):**
  - **Datasource:** Agregar `Future<void> deleteAccount();` en `AuthRemoteDataSource` y `AuthRemoteDataSourceImpl`, invocando `await supabaseService.client.rpc('delete_user_account');`.
  - **Repositorio:** Declarar `Future<Either<Failure, void>> deleteAccount();` en `AuthRepository` e implementarlo en `AuthRepositoryImpl` capturando fallos mediante `SupabaseErrorHandler.handle(e)`.
  - **Caso de Uso:** Crear `DeleteAccountUseCase` en `lib/domain/usecases/auth/delete_account_usecase.dart` siguiendo el patrón estándar de `UseCase<void, NoParams>`.
  - **Inyección de Dependencias:** Registrar `DeleteAccountUseCase` como `lazySingleton` en `lib/core/di/injection_container.dart` e inyectarlo en `AuthProvider`.

* **DT-3 (Gestión de Estado y Ciclo de Vida en AuthProvider):**
  - Incorporar el caso de uso `DeleteAccountUseCase` en `AuthProvider`.
  - Implementar el método `Future<bool> deleteAccount()`.
  - En caso de éxito:
    1. Limpiar el almacenamiento local (`SharedPreferences`).
    2. Ejecutar `signOut()` a nivel de cliente para invalidar tokens remanentes.
    3. Restablecer el estado del usuario en memoria (`_user = null`).
    4. Limpiar los estados de los demás proveedores (`TenantProvider`, `LandlordProvider`, `ReviewProvider`).
    5. Retornar `true` y notificar a los oyentes.
  - En caso de error, capturar el mensaje de fallo, actualizar `_errorMessage`, mantener la sesión y retornar `false`.

* **DT-4 (Interfaz de Usuario y Prevención de Errores):**
  - **`perfil_page.dart` (Arrendatario):**
    - Agregar una opción de lista con icono `Icons.delete_forever`, texto "Eliminar cuenta" en color rojo antes o después del cierre de sesión.
  - **`panel_page.dart` (Arrendador):**
    - Agregar un `ListTile` con icono `Icons.delete_forever`, texto "Eliminar cuenta" en color rojo dentro de la sección de ajustes.
  - **Diálogo Modal de Confirmación:**
    - Al tocar "Eliminar cuenta", mostrar un diálogo modal de advertencia (`AlertDialog` destructivo) con:
      - Título: "Eliminar cuenta".
      - Mensaje: "¿Estás seguro? Esta acción eliminará permanentemente tu cuenta, todas tus propiedades publicadas, solicitudes y datos personales. Esta acción no se puede deshacer."
      - Botón secundario: "Cancelar" (color neutral).
      - Botón destructivo principal: "Eliminar definitivamente" (estilo rojo).
    - Mostrar un diálogo de carga no cancelable (`CircularProgressIndicator`) mientras la operación asíncrona se ejecuta.
    - Al culminar, mostrar notificación de confirmación (`SnackBar` informativo) y redirigir con `context.go('/login')`.

* **DT-5 (Estrategia de Pruebas Automatizadas):**
  - Pruebas unitarias para `DeleteAccountUseCase`, `AuthRepositoryImpl` y `AuthRemoteDataSourceImpl` con mocks de Supabase.
  - Pruebas de integración de widget en `perfil_page_test.dart` y `panel_page_test.dart` validando:
    1. Renderizado y accesibilidad de la opción "Eliminar cuenta".
    2. Apertura del diálogo de confirmación y cancelación sin efectos secundarios.
    3. Confirmación de eliminación e invocación del método en `AuthProvider`.
    4. Redirección y retroalimentación ante éxito o fallo.

---

## 2. Mapeo Arquitectónico

```text
Capas del Proyecto:
├── supabase/
│   └── delete_user_account.sql       -> Función RPC PostgreSQL SECURITY DEFINER con borrado en cascada [DT-1]
├── lib/core/
│   └── di/injection_container.dart   -> Registro de DeleteAccountUseCase en GetIt [DT-2]
├── lib/domain/
│   ├── repositories/auth_repository.dart -> Contrato deleteAccount() [DT-2]
│   └── usecases/auth/delete_account_usecase.dart -> Caso de uso DeleteAccountUseCase [DT-2]
├── lib/data/
│   ├── datasources/auth_remote_datasource.dart -> Invocación RPC supabase.rpc('delete_user_account') [DT-2]
│   └── repositories/auth_repository_impl.dart  -> Manejo de Either<Failure, void> [DT-2]
├── lib/presentation/
│   ├── providers/auth_provider.dart  -> Método deleteAccount() y reseteo de estado [DT-3]
│   ├── pages/navegation/perfil_page.dart -> Botón destructivo y modal en perfil de arrendatario [DT-4]
│   └── pages/navegation/panel_page.dart  -> Botón destructivo y modal en panel de arrendador [DT-4]
└── test/
    ├── domain/usecases/auth/delete_account_usecase_test.dart -> Pruebas unitarias del caso de uso [DT-5]
    ├── data/repositories/auth_repository_impl_test.dart      -> Pruebas de repositorio [DT-5]
    └── presentation/pages/profile/delete_account_ui_test.dart -> Pruebas de widget y flujo de confirmación [DT-5]
```

---

## 3. Diagrama de Secuencia: Flujo Integral de Eliminación de Cuenta

```mermaid
sequenceDiagram
    autonumber
    actor Usuario
    participant UI as PerfilPage / PanelPage
    participant Modal as ConfirmDialog
    participant AuthProv as AuthProvider
    participant UseCase as DeleteAccountUseCase
    participant Repo as AuthRepositoryImpl
    participant RemoteDS as AuthRemoteDataSourceImpl
    participant Supa as Supabase (RPC PostgreSQL)
    participant LocalCache as SharedPreferences

    Usuario->>UI: Toca en "Eliminar cuenta"
    UI->>Modal: Muestra diálogo de advertencia destructiva
    Usuario->>Modal: Confirma "Eliminar definitivamente"
    Modal->>UI: Retorna confirmación positiva
    UI->>UI: Despliega indicador de progreso bloqueante
    UI->>AuthProv: deleteAccount()
    AuthProv->>UseCase: call(NoParams())
    UseCase->>Repo: deleteAccount()
    Repo->>RemoteDS: deleteAccount()
    RemoteDS->>Supa: rpc('delete_user_account')
    Note over Supa: Verifica auth.uid(), borra en cascada<br/>reviews, solicitudes, propiedades,<br/>perfiles y auth.users
    Supa-->>RemoteDS: Retorna éxito (void)
    RemoteDS-->>Repo: Retorna éxito
    Repo-->>UseCase: Right(void)
    UseCase-->>AuthProv: Right(void)
    AuthProv->>LocalCache: clear()
    AuthProv->>Supa: auth.signOut()
    AuthProv->>AuthProv: _user = null; notifyListeners()
    AuthProv-->>UI: Retorna true
    UI->>UI: Cierra indicador de carga
    UI->>Usuario: Muestra SnackBar "Cuenta eliminada con éxito"
    UI->>Usuario: Redirige a pantalla de login (context.go('/login'))
```
