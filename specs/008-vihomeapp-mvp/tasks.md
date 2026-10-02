# Tareas de Implementación: Navegación a Mapa Exclusivo de Proyectos (008-vihomeapp-mvp)

Este documento desglosa el plan técnico en tareas atómicas y secuenciales (máximo 20 a 30 minutos cada una), organizadas según la arquitectura del proyecto. Cada tarea especifica los Requisitos Funcionales (RF), Requisitos No Funcionales (RNF), Casos Límite (CL) y Decisiones Técnicas (DT) cubiertos, junto con un criterio de aceptación medible ("Hecho cuando:").

---

## Fase 1: Capa de Enrutamiento (`app_router.dart`)

- [x] **Tarea 1.1: Soporte de parámetro de consulta `tipo` en la ruta `/mapa`**
  - **RF Cubiertos:** RF-42.3, RF-43.1, DT-1
  - **Descripción:** Modificar la definición de la ruta `/mapa` en `lib/core/router/app_router.dart` para extraer el valor de `tipo` desde `state.uri.queryParameters['tipo']` (o como alternativa `(state.extra as Map?)?['tipo']`) e instanciar `MapaPage(tipo: tipo)`.
  - **Hecho cuando:** La navegación a `/mapa?tipo=proyectos` inyecte correctamente el string `'proyectos'` al widget `MapaPage`, y la navegación regular a `/mapa` continúe inyectando `null`.

---

## Fase 2: Capa de Presentación - Pantalla de Proyectos (`proyectos_page.dart`)

- [x] **Tarea 2.1: Botón interactivo de acceso al mapa en la AppBar de `ProyectosPage`**
  - **RF Cubiertos:** RF-42.1, RF-42.2, RF-42.3, RNF-28, DT-5
  - **Descripción:** Modificar `lib/presentation/pages/proyectos/proyectos_page.dart`:
    - En el array `actions` del `AppBar`, antes del botón de notificaciones, agregar un `IconButton` con el icono `Icons.map_outlined` (o `Icons.map`), tooltip accesible `"Ver Proyectos en Mapa"` y acción `context.push('/mapa?tipo=proyectos')`.
  - **Hecho cuando:** En la vista de proyectos se renderice el icono de mapa en la posición correcta y al ser pulsado ejecute la navegación a `/mapa?tipo=proyectos`.

---

## Fase 3: Capa de Presentación - Mapa Multimodal (`mapa_page.dart`)

- [x] **Tarea 3.1: Constructor multimodal, getter `isProjectsMode` y AppBar dinámica**
  - **RF Cubiertos:** RF-43.1, RF-43.3, DT-2
  - **Descripción:** Modificar `lib/presentation/pages/navegation/mapa_page.dart`:
    - Añadir el atributo `final String? tipo;` al constructor de `MapaPage({super.key, this.tipo})`.
    - Crear el getter `bool get isProjectsMode => widget.tipo?.toLowerCase() == 'proyectos';`.
    - Ajustar el título de la `AppBar`: `Text(isProjectsMode ? 'Mapa de Proyectos' : 'Mapa Propiedades')`.
  - **Hecho cuando:** Al instanciar `MapaPage(tipo: 'proyectos')`, la barra de navegación muestre el título "Mapa de Proyectos".

- [x] **Tarea 3.2: Carga y georreferenciación exclusiva de proyectos (`_loadProjectMarkers`)**
  - **RF Cubiertos:** RF-43.1, RF-43.2, RF-44.1, RF-44.2, RF-44.3, CL-38, CL-39, DT-2, DT-3, DT-6
  - **Descripción:** En `mapa_page.dart`:
    - En `initState`, si `isProjectsMode == true`: obtener `ProjectProvider` y llamar a `fetchProjects()` si `provider.projects.isEmpty`.
    - Si `isProjectsMode == false`: mantener el comportamiento actual con `PropertyProvider`.
    - Implementar `Future<void> _loadProjectMarkers()`:
      - Limpiar anotaciones previas en `pointAnnotationManager`.
      - Iterar sobre `projectProvider.projects`.
      - Filtrar y omitir proyectos con `lat == 0 || lng == 0`.
      - Generar marcador con icono de proyecto (`Icons.domain` / `Icons.apartment`), estilo Mapbox y etiqueta con el precio base ("Desde $...").
    - En el FloatingActionButton de recarga, invocar `_loadProjectMarkers` si `isProjectsMode`, o `_loadPropertyMarkers` en caso contrario.
  - **Hecho cuando:** En modo proyectos únicamente se carguen y pinten los proyectos válidos del `ProjectProvider`, sin mezclar propiedades estándar.

- [x] **Tarea 3.3: Tarjeta modal y navegación a detalles (`_showProjectDetails`)**
  - **RF Cubiertos:** RF-45.1, RF-45.2, RF-46.1, RF-46.2, RF-46.3, CL-41, CL-42, DT-4
  - **Descripción:** En `mapa_page.dart`:
    - En `_handleAnnotationClick`: si `isProjectsMode`, localizar el proyecto más cercano en `projectProvider.projects` e invocar `_showProjectDetails(project)`.
    - Implementar `void _showProjectDetails(Project project)`:
      - Mostrar un `showModalBottomSheet` con diseño adaptado a proyectos:
        - Título y ubicación principal.
        - Badge de estado de construcción (ej. "Sobre Planos", "En Construcción").
        - Chips informativos: Habitaciones, Baños, Área.
        - Etiqueta de "Precio Desde" y valor formateado en pesos colombianos.
        - Botón "Ver Detalles" que cierra el modal y navega a `context.push('/proyecto-detalle', extra: project)`.
  - **Hecho cuando:** Al pulsar un marcador de proyecto se abra el modal bottom sheet con los datos del proyecto y el botón "Ver Detalles" navegue a `/proyecto-detalle`.

---

## Fase 4: Pruebas Automatizadas y Regresión Completa

- [x] **Tarea 4.1: Suite de pruebas de enrutamiento (`app_router_mapa_query_param_test.dart`)**
  - **Descripción:** Crear pruebas unitarias que verifiquen que `AppRouter` procesa correctamente el query param `tipo=proyectos`.
  - **Hecho cuando:** La prueba pase con exit code 0.

- [x] **Tarea 4.2: Suite de pruebas de widget para `ProyectosPage` (`proyectos_page_map_button_test.dart`)**
  - **Descripción:** Crear prueba de widget que verifique la presencia del botón de mapa en la AppBar de `ProyectosPage`, su tooltip y la navegación.
  - **Hecho cuando:** La prueba pase con exit code 0.

- [x] **Tarea 4.3: Suite de pruebas de componente y lógica para `MapaPage` (`mapa_page_projects_mode_test.dart`)**
  - **Descripción:** Crear prueba de componente que verifique el título dinámico, la omisión de coordenadas en cero y el modal de detalles de proyecto.
  - **Hecho cuando:** La prueba pase con exit code 0.

- [ ] **Tarea 4.4: Verificación de calidad, 0 lints y suite completa (320+ tests)**
  - **Descripción:** Ejecutar `flutter analyze` y `flutter test` en todo el proyecto asegurando 100% de tests aprobados y 0 advertencias.
  - **Hecho cuando:** Ambos comandos finalicen con exit code 0.

---

## Fase 5: Revisión de Usuario (Pre-commit)

- [ ] **Tarea 5.1: Notificación y presentación de cambios para revisión del usuario**
  - **Descripción:** Detallar la entrega, pruebas ejecutadas y arquitectura implementada, dejando el espacio para que el usuario valide antes de proceder al commit final.
  - **Hecho cuando:** El usuario revise y dé la aprobación para realizar el commit y cierre en Notion.
