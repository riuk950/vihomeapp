# Arquitectura Limpia (Clean Architecture)

Este proyecto está implementado siguiendo los principios de Clean Architecture, separando el código en capas bien definidas con dependencias unidireccionales.

## Estructura de Capas

### 🎯 Domain Layer (`lib/domain/`)
Capa más interna, independiente de frameworks y librerías externas.

- **Entities** (`entities/`): Objetos de dominio puros
  - `user.dart`: Entidad User

- **Repositories** (`repositories/`): Interfaces de repositorios
  - `auth_repository.dart`: Interfaz para operaciones de autenticación

- **Use Cases** (`usecases/`): Lógica de negocio
  - `auth/`: Casos de uso de autenticación
    - `get_current_user_usecase.dart`
    - `sign_in_usecase.dart`
    - `sign_up_usecase.dart`
    - `sign_out_usecase.dart`
    - `reset_password_usecase.dart`

### 📦 Data Layer (`lib/data/`)
Implementación de repositorios y manejo de datos.

- **Models** (`models/`): Modelos de datos (DTOs)
  - `user_model.dart`: Modelo de datos de usuario

- **Repositories** (`repositories/`): Implementaciones de repositorios
  - `auth_repository_impl.dart`: Implementación del repositorio de autenticación

- **Data Sources** (`datasources/`): Fuentes de datos
  - `auth_remote_datasource.dart`: Datasource remoto para autenticación (Supabase)

### 🎨 Presentation Layer (`lib/presentation/`)
Capa de interfaz de usuario.

- **Pages** (`pages/`): Pantallas de la aplicación
  - `login_page.dart`
  - `register_page.dart`
  - `home_page.dart`
  - `splash_screen.dart`
  - Y más...

- **Providers** (`providers/`): ViewModels/State Management
  - `auth_provider.dart`: Provider de autenticación usando casos de uso

- **Widgets** (`widgets/`): Widgets reutilizables
  - Componentes UI compartidos

### 🔧 Core Layer (`lib/core/`)
Utilidades y configuraciones compartidas.

- **Errors** (`errors/`): Manejo de errores
  - `failures.dart`: Clases de error personalizadas

- **Utils** (`utils/`): Utilidades
  - `either.dart`: Tipo funcional Either para manejo de errores
  - `constants.dart`: Constantes de la aplicación

- **Router** (`router/`): Configuración de rutas
  - `app_router.dart`: Configuración de GoRouter

- **Theme** (`theme/`): Tema de la aplicación
  - `app_theme.dart`: Configuración del tema

- **DI** (`di/`): Inyección de dependencias
  - `injection_container.dart`: Configuración de GetIt

### 🏗️ Infrastructure Layer (`lib/infrastructure/`)
Servicios externos y configuración.

- **Services** (`services/`): Servicios externos
  - `supabase_service.dart`: Cliente de Supabase

## Flujo de Datos

```
Presentation → Domain ← Data
     ↓           ↓        ↓
  Providers  Use Cases  Repositories
                ↓        ↓
              Entities  Data Sources
```

1. **Presentation Layer** llama a **Use Cases** a través de **Providers**
2. **Use Cases** usan **Repository Interfaces** (Domain)
3. **Repository Implementations** (Data) implementan las interfaces
4. **Data Sources** obtienen datos de fuentes externas (API, BD, etc.)
5. Los datos se mapean de **Models** a **Entities** y viceversa

## Principios Aplicados

### ✅ Separación de Responsabilidades
Cada capa tiene una responsabilidad única y bien definida.

### ✅ Inversión de Dependencias
Las capas externas dependen de las internas, no al revés.

### ✅ Independencia de Frameworks
El Domain Layer no depende de Flutter ni de librerías externas.

### ✅ Testabilidad
Cada capa puede ser testeada de forma independiente.

### ✅ Mantenibilidad
Cambios en una capa no afectan directamente a otras.

## Inyección de Dependencias

Se utiliza **GetIt** para la inyección de dependencias. La configuración se encuentra en:
- `lib/core/di/injection_container.dart`

### Configuración de Dependencias

```dart
// Infrastructure
SupabaseService → Singleton

// Data Sources
AuthRemoteDataSource → Lazy Singleton

// Repositories
AuthRepository → Lazy Singleton

// Use Cases
SignInUseCase, SignUpUseCase, etc. → Lazy Singleton

// Providers
AuthProvider → Factory (se crea nueva instancia cada vez)
```

## Uso de Either para Manejo de Errores

Se utiliza el tipo funcional `Either<Failure, T>` para manejar errores de forma explícita:

```dart
Future<Either<Failure, User>> signInWithEmail({
  required String email,
  required String password,
}) async {
  // Si hay error: Left(Failure)
  // Si es exitoso: Right(User)
}
```

## Ventajas de esta Arquitectura

1. **Escalabilidad**: Fácil agregar nuevas funcionalidades
2. **Testabilidad**: Cada componente es testeable de forma aislada
3. **Mantenibilidad**: Código organizado y fácil de entender
4. **Reutilización**: Use cases pueden ser reutilizados en diferentes contextos
5. **Independencia**: Cambios en frameworks externos no afectan el dominio

## Próximos Pasos

- [ ] Agregar tests unitarios para Use Cases
- [ ] Agregar tests de integración para Repositories
- [ ] Agregar tests de widgets para Presentation Layer
- [ ] Implementar caché local (Data Layer)
- [ ] Agregar más casos de uso según necesidades
- [ ] Implementar manejo de estado global (si es necesario)

