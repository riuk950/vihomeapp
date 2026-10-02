# Especificación Funcional: Navegación a Mapa Exclusivo de Proyectos (008-vihomeapp-mvp)

## 1. Visión General

La plataforma ofrece a los usuarios interesados en proyectos inmobiliarios y nuevas construcciones la capacidad de explorar el catálogo de proyectos mediante una vista geográfica interactiva. Esta funcionalidad proporciona un acceso directo desde la sección de proyectos hacia un mapa especializado que filtra y presenta exclusivamente desarrollos en construcción y proyectos sobre planos, omitiendo cualquier otro tipo de inmueble tradicional (como casas, habitaciones o locales en arriendo estándar), para ofrecer una experiencia de búsqueda enfocada y sin distracciones.

---

## 2. Historias de Usuario

- **HU-37: Acceso Directo al Mapa desde la Pantalla de Proyectos**  
  *Como* usuario (arrendatario, comprador o arrendador) interesado en proyectos inmobiliarios,  
  *quiero* contar con un botón de acceso directo al mapa en la cabecera de la sección de proyectos,  
  *para* visualizar geográficamente dónde se ubican los desarrollos urbanísticos disponibles en la ciudad.

- **HU-38: Filtrado Exclusivo de Proyectos en el Mapa**  
  *Como* usuario que accede al mapa desde la sección de proyectos,  
  *quiero* que el mapa cargue únicamente los marcadores correspondientes a proyectos inmobiliarios,  
  *para* no confundirme con propiedades en arriendo individual o ventas tradicionales que no corresponden a obras o desarrollos.

- **HU-39: Visualización de Información Resumida del Proyecto en el Mapa**  
  *Como* usuario que explora proyectos en el mapa,  
  *quiero* pulsar sobre un marcador y visualizar una tarjeta informativa con los datos clave del proyecto (nombre, estado de la obra, precio base y características principales),  
  *para* evaluar rápidamente si el proyecto se ajusta a mi interés antes de ver su ficha completa.

- **HU-40: Navegación a la Ficha Completa del Proyecto desde el Mapa**  
  *Como* usuario que consulta un proyecto en el mapa,  
  *quiero* disponer de un botón de acción en la tarjeta resumen para abrir la vista completa del proyecto,  
  *para* revisar todos los detalles, imágenes, planes de financiamiento y contactar a la constructora.

---

## 3. Requisitos Funcionales (RF)

- **RF-42 (Acceso Rápido al Mapa):**
  - **RF-42.1:** La cabecera de la pantalla de proyectos debe incluir un botón interactivo de acceso al mapa ubicado en el extremo superior, junto al indicador de notificaciones.
  - **RF-42.2:** El botón debe contar con una indicación visual descriptiva y una etiqueta accesible clara (por ejemplo, "Ver Proyectos en Mapa") que informe al usuario la acción que va a realizar.
  - **RF-42.3:** Al pulsar el botón, el sistema debe dirigir al usuario a la vista de mapa configurada en modo exclusivo de proyectos.

- **RF-43 (Modo Exclusivo de Proyectos en el Mapa):**
  - **RF-43.1:** Cuando el usuario ingrese a la vista de mapa desde la sección de proyectos, el mapa debe aplicar un filtro estricto que muestre únicamente desarrollos inmobiliarios.
  - **RF-43.2:** No deben mostrarse en esta vista propiedades de arriendo o venta tradicional (casas familiares, habitaciones, oficinas aisladas ni locales comerciales independientes).
  - **RF-43.3:** La barra de título de la vista de mapa debe reflejar con claridad el contexto activo (por ejemplo, "Mapa de Proyectos").

- **RF-44 (Georreferenciación y Marcadores de Proyectos):**
  - **RF-44.1:** Cada proyecto con coordenadas geográficas válidas registradas en el sistema debe representarse mediante un marcador visual distintivo en el mapa.
  - **RF-44.2:** El marcador debe incluir una etiqueta legible con el precio base ("Desde $...") o una identificación clara del proyecto.
  - **RF-44.3:** Si un proyecto carece de coordenadas geográficas válidas, no debe generar un marcador en el mapa ni causar bloqueos en la visualización general.

- **RF-45 (Tarjeta Resumen Informativa):**
  - **RF-45.1:** Al seleccionar cualquier marcador de proyecto en el mapa, debe desplegarse una tarjeta inferior con la información esencial:
    - Nombre del proyecto.
    - Ubicación o dirección principal.
    - Estado de avance de la obra (por ejemplo: Sobre Planos, En Construcción, Entrega Inmediata).
    - Métricas clave: número de habitaciones, baños y área en metros cuadrados.
    - Rango de precios o valor base de partida.
  - **RF-45.2:** La tarjeta resumen debe poder cerrarse de forma intuitiva deslizando hacia abajo o tocando fuera de ella.

- **RF-46 (Acceso a la Ficha Detallada):**
  - **RF-46.1:** La tarjeta resumen debe contener un botón de acción principal ("Ver Detalles").
  - **RF-46.2:** Al accionar el botón, el sistema debe abrir la vista detallada del proyecto seleccionado, transfiriendo toda la información correspondiente.
  - **RF-46.3:** Al regresar desde la vista detallada del proyecto, el usuario debe retornar al mapa manteniendo el estado y los marcadores de proyectos previamente cargados.

---

## 4. Requisitos No Funcionales (RNF)

- **RNF-27 (Rendimiento y Tiempo de Carga):** La inicialización del mapa y la colocación de los marcadores de proyectos disponibles no debe tardar más de 2 segundos en redes móviles estándar.
- **RNF-28 (Accesibilidad A11y):** Todos los componentes interactivos (botón de mapa en la cabecera, marcadores y botones de acción) deben disponer de etiquetas descriptivas compatibles con lectores de pantalla (TalkBack en Android y VoiceOver en iOS), cumpliendo estándares de contraste y tamaño táctil mínimo (48x48 dp).
- **RNF-29 (Coherencia Visual y Diseño Responsivo):** La interfaz debe adaptarse armoniosamente a dispositivos de diferentes resoluciones y tamaños de pantalla, preservando los colores corporativos y la jerarquía tipográfica del sistema de diseño.
- **RNF-30 (Resiliencia ante Ausencia de Datos o Fallas de Red):** Si no existen proyectos disponibles o falla la conexión, el sistema debe mostrar un estado visual limpio y controlado con posibilidad de reintentar, sin interrumpir la operatividad general de la aplicación.

---

## 5. Casos Límite y Excepciones (CL)

- **CL-38 (Proyectos sin coordenadas válidas):** Aquellos proyectos que tengan latitud y longitud en cero (0.0, 0.0) o nulas deben ignorarse para el pintado de marcadores, sin emitir alertas intrusivas al usuario ni bloquear el despliegue de los proyectos válidos.
- **CL-39 (Catálogo de proyectos vacío):** Si la consulta no devuelve ningún proyecto, el mapa debe centrarse en la ubicación por defecto o en la ubicación del usuario, informando de forma no bloqueante que no hay proyectos disponibles en la zona.
- **CL-40 (Acceso general al mapa sin filtro):** Si el usuario accede al mapa desde las secciones generales de arriendos o ventas (sin indicar el modo proyectos), el mapa debe operar en su modalidad estándar de inmuebles sin verse alterado.
- **CL-41 (Pulsación de marcador no coincidente o con latencia):** Si un marcador seleccionado no coincide con ningún registro local en memoria debido a sincronizaciones concurrentes, la acción debe descartarse de forma silenciosa y segura.
- **CL-42 (Navegación y Retorno):** Al volver al mapa tras consultar un proyecto detallado, el mapa debe conservar el filtro de proyectos activo sin reiniciar la consulta innecesariamente.

---

## 6. Criterios de Aceptación (EARS)

- **CA-1 (Acceso desde la Cabecera de Proyectos):**
  - *Cuando* el usuario se encuentre en la vista principal de proyectos, el sistema **debe** presentar un botón de mapa en la barra superior junto al acceso de notificaciones con la etiqueta descriptiva "Ver Proyectos en Mapa".
  - *Cuando* el usuario presione dicho botón, el sistema **debe** abrir inmediatamente la vista de mapa configurada en modo proyectos.

- **CA-2 (Exclusividad del Filtro de Proyectos en el Mapa):**
  - *Dado que* el mapa se abrió desde la sección de proyectos, el sistema **debe** mostrar en la barra superior el título "Mapa de Proyectos".
  - *Dado que* el mapa se abrió desde la sección de proyectos, el sistema **debe** excluir todas las propiedades de arriendo o venta estándar y mostrar **únicamente** los marcadores de proyectos inmobiliarios.

- **CA-3 (Despliegue de Información Resumida):**
  - *Cuando* el usuario pulse sobre un marcador de proyecto en el mapa, el sistema **debe** desplegar una tarjeta inferior que contenga el título, la ubicación, el estado de obra, habitaciones, baños, área y precio base.

- **CA-4 (Navegación al Detalle):**
  - *Cuando* el usuario pulse el botón "Ver Detalles" dentro de la tarjeta resumen del proyecto, el sistema **debe** abrir la vista con la información completa de dicho proyecto.
