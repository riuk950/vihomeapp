# Plan de Tareas: Aseguramiento de Calidad y Estabilidad para iOS (Flutter)

## Fase 1: Configuración Nativa de Plataforma y Permisos en iOS
- [x] **Tarea 1.1:** Actualizar `ios/Runner/Info.plist` agregando `NSPhotoLibraryUsageDescription` y `NSCameraUsageDescription` para selector de imágenes/documentos. [RF-47, CA-1, DT-1]
- [x] **Tarea 1.2:** Configurar `GADApplicationIdentifier` y redes publicitarias `SKAdNetworkItems` en `ios/Runner/Info.plist` para prevenir caídas de arranque de AdMob en iOS. [RF-51, CA-4, DT-1]
- [x] **Tarea 1.3:** Agregar esquemas de consulta de aplicaciones (`tel`, `mailto`, `sms`) en `LSApplicationQueriesSchemes` en `ios/Runner/Info.plist`. [RF-50, DT-1]
- [x] **Tarea 1.4:** Fijar `platform :ios, '15.0'` y configurar macros de preprocesador en `ios/Podfile` para `permission_handler` y compatibilidad con `mapbox_maps_flutter` y SDK iOS 26+. [RF-47, DT-2]
- [x] **Tarea 1.5:** Resolver conflicto de dependencias SPM vs CocoaPods (`google_mobile_ads` vs `webview_flutter_wkwebview`): configurar `enable-swift-package-manager: false` en `pubspec.yaml`, limpiar referencias SPM de `project.pbxproj` / schemes y soportar copia dinámica de `GoogleService-Info.plist` por flavor (`dev`/`prod`). [RF-51, DT-2]

## Fase 2: Ergonomía Visual y Áreas Seguras en Modales y Vistas
- [x] **Tarea 2.1:** Modificar `_showProjectDetails` y `_showPropertyDetails` en `lib/presentation/pages/navegation/mapa_page.dart` habilitando `useSafeArea: true` y envolviendo en `SafeArea(top: false, ...)` para aislar el Home Indicator. [RF-48, CA-2, DT-3]
- [x] **Tarea 2.2:** Validar que los botones de acción inferior en `_buildTenantActionBar` de `detalles_propiedades_page.dart` y `home_page.dart` mantengan padding seguro con respecto a la barra de gestos inferior. [RF-48, CA-2, DT-3]

## Fase 3: Fluidez e Interacción Táctil del Teclado
- [x] **Tarea 3.1:** Agregar `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag` en los formularios de publicación y edición (`crear_propiedad_page.dart`, `editar_propiedades_page.dart`). [RF-49, CA-3, DT-4]
- [x] **Tarea 3.2:** Agregar `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag` en los formularios de arrendatario y arrendador (`solicitud_de_arriendo_page.dart`, `complete_tenant_profile_page.dart`, `complete_landlord_profile_page.dart`). [RF-49, CA-3, DT-4]
- [x] **Tarea 3.3:** Añadir detección táctil de desenfoque (`GestureDetector` con `FocusScope.of(context).unfocus()`) en pantallas de autenticación (`login_page.dart`, `register_page.dart`). [RF-49, CA-3, DT-4]

## Fase 4: Pruebas Automatizadas de Compatibilidad y No Regresión
- [x] **Tarea 4.1:** Crear prueba unitaria/de integración de configuración que valide que el archivo `Info.plist` contenga todas las claves requeridas para iOS (`NSPhotoLibraryUsageDescription`, `NSCameraUsageDescription`, `GADApplicationIdentifier`, esquemas de consulta). [CA-1, CA-4, DT-6]
- [x] **Tarea 4.2:** Crear pruebas de widget simulando `TargetPlatform.iOS` y márgenes de pantalla de iPhone con Home Indicator (`viewPadding.bottom = 34.0`) para los modales de mapas y formularios. [CA-2, CA-3, DT-6]
- [x] **Tarea 4.3:** Ejecutar la suite completa de pruebas del proyecto asegurando 0 regresiones. [RNF-31]

## Fase 5: Validación, Análisis Estático y Cierre
- [x] **Tarea 5.1:** Ejecutar análisis estático para garantizar 0 errores y 0 advertencias. [RNF-31]
- [x] **Tarea 5.2:** Presentar resumen para revisión del usuario antes de commit y cierre en Notion.
