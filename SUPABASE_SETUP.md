# Configuración de Autenticación con Supabase usando Provider

Este documento explica cómo está configurada la autenticación con Supabase usando Provider para la gestión de estado.

## 📦 Dependencias Instaladas

- `supabase_flutter: ^2.0.0` - Cliente oficial de Supabase para Flutter
- `provider: ^6.1.1` - Gestión de estado reactiva

## 🔧 Configuración

### 1. Variables de Entorno

Agrega las siguientes variables a tus archivos `.env.dev` y `.env.prod`:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-clave-anonima-aqui
```

### 2. Obtener Credenciales de Supabase

1. Ve a [https://supabase.com](https://supabase.com)
2. Crea un proyecto o selecciona uno existente
3. Ve a **Settings** > **API**
4. Copia:
   - **Project URL** → `SUPABASE_URL`
   - **anon/public key** → `SUPABASE_ANON_KEY`

### 3. Configurar Supabase Auth

En el dashboard de Supabase:
1. Ve a **Authentication** > **Providers**
2. Habilita **Email** provider
3. Configura las opciones según tus necesidades

## 🏗️ Estructura del Proyecto

```
lib/
├── services/
│   └── supabase_service.dart      # Servicio de inicialización de Supabase
├── providers/
│   └── auth_provider.dart         # Provider de autenticación con ChangeNotifier
├── Ui/
│   └── pages/
│       ├── login_page.dart        # Página de inicio de sesión
│       ├── register_page.dart     # Página de registro
│       ├── splash_screen.dart     # Pantalla de inicio con verificación de auth
│       └── perfil_page.dart       # Perfil del usuario con cerrar sesión
└── config/
    └── router/
        └── app_router.dart        # Router con protección de rutas
```

## 🎯 Funcionalidades Implementadas

### AuthProvider
- ✅ Gestión de estado con `ChangeNotifier`
- ✅ Registro de usuarios
- ✅ Inicio de sesión
- ✅ Cerrar sesión
- ✅ Estado de carga y manejo de errores
- ✅ Escucha de cambios de autenticación
- ✅ Stream de cambios de estado de auth

### Páginas
- ✅ Login con validación de formulario
- ✅ Registro con confirmación de contraseña
- ✅ Perfil del usuario con información
- ✅ Cerrar sesión con confirmación
- ✅ Splash screen con verificación de sesión

### Router
- ✅ Protección de rutas
- ✅ Redirección automática según estado de autenticación
- ✅ Rutas públicas y protegidas

## 📝 Uso del AuthProvider

### En un Widget

```dart
// Usar Consumer para escuchar cambios
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    if (authProvider.isAuthenticated) {
      return Text('Usuario: ${authProvider.user?.email}');
    }
    return Text('No autenticado');
  },
)

// O usar Provider.of para acceder sin escuchar
final authProvider = Provider.of<AuthProvider>(context, listen: false);
await authProvider.signInWithEmail(
  email: 'usuario@example.com',
  password: 'contraseña123',
);
```

### Registro de Usuario

```dart
final authProvider = Provider.of<AuthProvider>(context, listen: false);
final success = await authProvider.signUp(
  email: 'usuario@example.com',
  password: 'contraseña123',
  metadata: {'name': 'Nombre del usuario'},
);
```

### Inicio de Sesión

```dart
final authProvider = Provider.of<AuthProvider>(context, listen: false);
final success = await authProvider.signInWithEmail(
  email: 'usuario@example.com',
  password: 'contraseña123',
);
```

### Cerrar Sesión

```dart
final authProvider = Provider.of<AuthProvider>(context, listen: false);
await authProvider.signOut();
```

### Verificar Estado de Autenticación

```dart
final authProvider = Provider.of<AuthProvider>(context, listen: false);
if (authProvider.isAuthenticated) {
  final user = authProvider.user;
  print('Usuario autenticado: ${user?.email}');
}
```

## 🔐 Protección de Rutas

El router está configurado para proteger automáticamente las rutas:

- **Rutas públicas**: `/`, `/login`, `/register`
- **Rutas protegidas**: `/home`, y cualquier otra ruta (redirige a `/login`)

Si un usuario autenticado intenta acceder a `/login` o `/register`, será redirigido a `/home`.

## 🚀 Próximos Pasos

- [ ] Implementar recuperación de contraseña
- [ ] Agregar autenticación social (Google, Apple, etc.)
- [ ] Implementar verificación de email
- [ ] Agregar autenticación biométrica
- [ ] Mejorar manejo de errores
- [ ] Agregar refresh token automático

## 🐛 Solución de Problemas

### Error: "Invalid API key"
- Verifica que las credenciales en `.env.dev` y `.env.prod` sean correctas
- Asegúrate de usar la clave **anon/public**, no la clave **service_role**

### Error: "Email not confirmed"
- En desarrollo, puedes desactivar la confirmación de email en Supabase Dashboard
- Ve a **Authentication** > **Settings** > **Email Auth** y desactiva "Enable email confirmations"

### El Provider no se encuentra
- Asegúrate de que `ChangeNotifierProvider` esté envolviendo tu `MaterialApp.router`
- Verifica que estés usando `Consumer` o `Provider.of` dentro del árbol de widgets

## 📚 Recursos

- [Documentación de Supabase Auth](https://supabase.com/docs/guides/auth)
- [Flutter Supabase](https://supabase.com/docs/reference/dart/introduction)
- [Provider Package](https://pub.dev/packages/provider)
- [GoRouter](https://pub.dev/packages/go_router)

