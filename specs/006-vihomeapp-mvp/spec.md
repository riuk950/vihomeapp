# Especificación Funcional: Visualización de Ranking en Perfiles y Propiedades (006-vihomeapp-mvp)

## 1. Contexto y Objetivo

En la plataforma ViHome, la reputación de los usuarios es el elemento determinante para inspirar seguridad y agilizar la toma de decisiones tanto en la búsqueda de vivienda como en la selección de inquilinos. Tras haberse formalizado el mecanismo transaccional de emisión, cálculo y registro inmutable de calificaciones (especificación 005), se hace indispensable conectar dicha reputación con los puntos de contacto más críticos de la experiencia de usuario: la **Pantalla de Perfil de Usuario**, la **Pantalla de Detalle de Propiedad** y el **Panel de Control del Arrendador**.

Actualmente, cuando un potencial inquilino explora una propiedad en oferta, visualiza las características físicas del inmueble pero carece de visibilidad inmediata sobre la fiabilidad del arrendador responsable. De forma análoga, al consultar el perfil de un usuario o ingresar al panel de administración del arrendador, no se expone de manera explícita su trayectoria o evaluación comunitaria acumulada.

El objetivo de esta especificación es formalizar la **Visualización Integral de Ranking y Reputación**, garantizando que:
1. La Pantalla de Perfil de Usuario exponga el promedio de estrellas, la cantidad total de evaluaciones y el desglose de opiniones recibidas.
2. La sección del arrendador en la Pantalla de Detalle de Propiedad presente de forma clara, destacada y no invasiva el nivel de confianza del propietario.
3. El Panel de Control del Arrendador exhiba su propio ranking promedio, nivel de confianza y acceso directo a sus opiniones recibidas, permitiéndole monitorear su prestigio comunitario mientras gestiona sus propiedades y solicitudes.
4. Se contemplen de forma homogénea los estados sin calificaciones previas, diferenciando usuarios nuevos estándar de usuarios verificados que gozan del puntaje inicial de confianza.
5. Se mantenga una experiencia visual uniforme, accesible y con manejo resiliente ante demoras o fallos en la obtención de datos.

---

## 2. Perfiles de Usuario

- **Arrendador (Propietario / Oferente):** Desea que su perfil, su panel de control y las publicaciones de sus inmuebles reflejen claramente su calificación y reputación positiva acumulada, transmitiendo confianza inmediata a los postulantes para maximizar el interés en sus propiedades.
- **Arrendatario (Postulante / Inquilino):** Desea consultar el nivel de reputación del propietario al revisar un anuncio de arriendo antes de contactar o postular, así como revisar su propia reputación acumulada en su perfil para validar su credibilidad ante futuros arrendadores.
- **Usuario Invitado o No Registrado:** Desea examinar anuncios de propiedades y verificar la reputación del anunciante sin fricciones antes de decidir registrarse en la plataforma.

---

## 3. Historias de Usuario

- **HU-26 (Visualización de Reputación en Perfil de Usuario):** Como usuario de la aplicación (arrendatario o arrendador), quiero ver en la Pantalla de Perfil de Usuario la puntuación de estrellas promedio, el número total de reseñas recibidas y el listado de comentarios, para evaluar la credibilidad propia o de otros miembros de la comunidad.
- **HU-27 (Visualización de Calificación del Arrendador en Detalle de Propiedad):** Como usuario interesado en arrendar un inmueble, quiero ver el ranking de estrellas del propietario en la sección de información del anfitrión dentro del Detalle de Propiedad, para tomar una decisión informada de postulación basada en la confianza.
- **HU-28 (Tratamiento de Estados Neutrales y Confianza Inicial):** Como usuario que consulta un perfil o propiedad cuyo titular carece de historial de reseñas, quiero visualizar un indicador neutral comprensible o el distintivo de confianza inicial si está verificado, evitando estados visuales erróneos de "cero estrellas".
- **HU-29 (Visualización de Ranking en el Panel de Control del Arrendador):** Como Arrendador, quiero ver en mi Panel de Control principal mi calificación promedio, nivel de confianza y resumen de opiniones recibidas, para conocer mi reputación comunitaria de forma inmediata mientras gestiono mis propiedades y solicitudes.
- **HU-30 (Actualización Dinámica y Escucha de Ranking al Navegar):** Como usuario de la plataforma (arrendador o arrendatario), quiero que mi ranking, reputación y opiniones se actualicen automáticamente o escuchen los cambios cada vez que navegue por las pantallas de Perfil de Usuario, Panel de Control y Detalle de la Propiedad, para contar siempre con la información más reciente sin tener que reiniciar la aplicación ni forzar manualmente la recarga.
- **HU-31 (Registro de Calificación y Comentario de Usuario Verificado al Completar Perfil):** Como usuario de la plataforma (arrendador o arrendatario) que completa satisfactoriamente sus datos obligatorios de perfil, quiero que el sistema envíe y guarde formalmente mi evaluación inicial con el comentario de "Usuario verificado" en el repositorio central de calificaciones, para que mi reputación y opiniones queden registradas de manera persistente en la base de datos y visibles en las pantallas de perfil y panel de gestión.

---

## 4. Requisitos Funcionales (RF)

### RF-29: Visualización de Ranking en Pantalla de Perfil de Usuario
- **RF-29.1:** CUANDO el usuario acceda a la Pantalla de Perfil de Usuario, el sistema DEBERÁ evaluar el historial de evaluaciones del usuario y presentar:
  - MIENTRAS el usuario posea al menos una (1) calificación real registrada: el promedio numérico redondeado a un (1) decimal (ejemplo: `4.8`), la representación gráfica de estrellas y el contador legible (ejemplo: `"Basado en 12 valoraciones"`).
  - SI el usuario no posee calificaciones registradas: el sistema DEBERÁ aplicar el tratamiento de estado correspondiente a la regla de verificación estipulada en `RF-31`.
- **RF-29.2:** DONDE el usuario posea opiniones registradas, el sistema DEBERÁ mostrar una sección de listado de reseñas que exhiba el nombre del autor, la fecha relativa o absoluta de la opinión, la puntuación otorgada y el comentario sanitizado.
- **RF-29.3:** El sistema DEBERÁ presentar un único consolidado de reputación comunitaria por usuario, indicando el rol principal activo o la categoría de interacción del usuario evaluado sin fragmentar su historial.

### RF-30: Visualización de Reputación del Propietario en Detalle de Propiedad
- **RF-30.1:** MIENTRAS el usuario consulte la Pantalla de Detalle de Propiedad, el sistema DEBERÁ exhibir en la tarjeta o sección de datos del propietario/arrendador:
  - MIENTRAS el propietario cuente con calificaciones reales: el componente visual de estrellas, el puntaje numérico (ejemplo: `4.9`) y el conteo de reseñas recibidas (ejemplo: `"8 reseñas"`).
  - SI el propietario no registra calificaciones: el estado neutral o de confianza inicial estipulado en `RF-31`.
- **RF-30.2:** El sistema DEBERÁ posicionar la calificación del arrendador de forma contigua y visible junto a su nombre y foto/avatar para garantizar visibilidad inmediata antes de los botones de postulación o contacto.
- **RF-30.3:** CUANDO el usuario presione sobre el indicador de calificación del arrendador en la Pantalla de Detalle de Propiedad, el sistema DEBERÁ desplegar una hoja modal deslizante inferior (*bottom sheet*) con el resumen de reputación y el listado de reseñas históricas del propietario, manteniendo intacto el contexto de la propiedad visualizada.
- **RF-30.4:** SI el usuario autenticado que visualiza la Pantalla de Detalle de Propiedad es el propietario del inmueble, ENTONCES el sistema DEBERÁ exhibir su propia insignia de reputación tal como la perciben los postulantes, manteniendo habilitada la consulta de sus opiniones recibidas.

### RF-31: Tratamiento de Usuarios sin Reseñas y Confianza Inicial
- **RF-31.1:** SI el usuario evaluado no cuenta con calificaciones registradas y no posee estado de verificación, ENTONCES el sistema DEBERÁ exhibir un estado neutral textual: `"Sin calificaciones aún"`, suprimiendo cualquier indicador engañoso de 0 estrellas.
- **RF-31.2:** SI el usuario evaluado posee estado verificado y no registra calificaciones de transacciones previas, ENTONCES el sistema DEBERÁ exhibir un valor inicial de `3.0 ★` acompañado del texto o distintivo indicativo: `"Puntaje inicial de confianza"`.
- **RF-31.3:** CUANDO el usuario verificado reciba su primera calificación real producto de un proceso culminado, el sistema DEBERÁ retirar de inmediato la etiqueta de puntaje provisional y reflejar el 100% del promedio real acumulado.

### RF-32: Consistencia Visual y Estados de Carga
- **RF-32.1:** El sistema DEBERÁ utilizar una paleta de color y estilo iconográfico consistente para las estrellas y distintivos de reputación tanto en la Pantalla de Perfil de Usuario como en la Pantalla de Detalle de Propiedad.
- **RF-32.2:** MIENTRAS los datos de reputación del usuario o propietario se encuentren en proceso de carga o sincronización, el sistema DEBERÁ presentar un marcador visual no bloqueante (placeholder o esqueleto visual) que impida saltos abruptos en la disposición de la interfaz.

### RF-33: Resiliencia ante Fallos de Consulta
- **RF-33.1:** SI ocurre un error de red o timeout al consultar la reputación del usuario o del propietario, ENTONCES el sistema DEBERÁ presentar la pantalla principal del perfil o de la propiedad sin interrumpir el flujo del usuario, indicando de forma discreta que la reputación no está disponible temporalmente.
- **RF-33.2:** El sistema DEBERÁ proveer un mecanismo de reintento automático o mediante actualización manual (deslizar para refrescar) que recupere la reputación una vez restablecida la conectividad.

### RF-34: Visualización de Ranking en el Panel de Control del Arrendador
- **RF-34.1:** CUANDO el usuario con rol de arrendador acceda a su Panel de Control, el sistema DEBERÁ evaluar su reputación comunitaria y presentar de forma destacada bajo la sección de bienvenida y estado de verificación:
  - MIENTRAS el arrendador cuente con al menos una (1) calificación real registrada: el promedio numérico redondeado a un (1) decimal, la representación gráfica de estrellas y el total de opiniones recibidas (ejemplo: `"Basado en 8 reseñas"`).
  - SI el arrendador no registra calificaciones: el sistema DEBERÁ aplicar el tratamiento de estado correspondiente a la regla de verificación estipulada en `RF-31` (`3.0 ★ Puntaje inicial de confianza` si está verificado, o `"Sin calificaciones aún"` si no está verificado).
- **RF-34.2:** CUANDO el arrendador interactúe con el indicador de reputación en su Panel de Control, el sistema DEBERÁ permitirle consultar el listado completo de opiniones y comentarios recibidos sin abandonar el contexto de su panel de gestión.
- **RF-34.3:** El sistema DEBERÁ proveer recarga reactiva de la reputación en el Panel de Control ante gestos de actualización de la vista (*pull-to-refresh*).

### RF-35: Actualización y Escucha Reactiva de Ranking en la Navegación Entre Pantallas
- **RF-35.1:** CUANDO el usuario navegue o acceda a la Pantalla de Perfil de Usuario (tanto por selección de pestaña en la navegación principal como por retorno desde otra vista), el sistema DEBERÁ sincronizar y actualizar automáticamente la reputación comunitaria, el promedio numérico y las opiniones recibidas.
- **RF-35.2:** CUANDO el usuario con rol de arrendador navegue o acceda a su Panel de Control (tanto por selección de pestaña en la navegación principal como por retorno desde otra vista), el sistema DEBERÁ sincronizar y actualizar automáticamente su ranking, nivel de confianza y opiniones históricas.
- **RF-35.3:** CUANDO el usuario navegue a la Pantalla de Detalle de Propiedad (incluyendo reingresos o transiciones entre diferentes inmuebles), el sistema DEBERÁ consultar y sincronizar el ranking y la reputación más reciente del propietario del inmueble en consulta.
- **RF-35.4:** DONDE el sistema registre una nueva calificación o actualización de reputación, las pantallas de Perfil de Usuario, Panel de Control y Detalle de Propiedad DEBERÁN reflejar reactivamente los cambios en sus indicadores visuales sin requerir el reinicio de la aplicación.

### RF-36: Registro Persistente de Calificación de Usuario Verificado al Completar Perfil
- **RF-36.1:** CUANDO el usuario con rol de arrendador complete y guarde exitosamente la totalidad de sus datos en la Pantalla de Completar Perfil de Arrendador, el sistema DEBERÁ registrar automáticamente en el repositorio persistente de calificaciones una evaluación inicial con una puntuación de 3 estrellas, identificador de emisor del sistema de verificación y el comentario explícito: `"Usuario verificado"`.
- **RF-36.2:** CUANDO el usuario con rol de arrendatario complete y guarde exitosamente la totalidad de sus datos en la Pantalla de Completar Perfil de Arrendatario, el sistema DEBERÁ registrar automáticamente en el repositorio persistente de calificaciones una evaluación inicial con una puntuación de 3 estrellas, identificador de emisor del sistema de verificación y el comentario explícito: `"Usuario verificado"`.
- **RF-36.3:** SI el usuario (arrendador o arrendatario) ya cuenta con una calificación previa de usuario verificado o con calificaciones históricas en el repositorio, ENTONCES el sistema NO DEBERÁ duplicar la calificación inicial al actualizar nuevamente sus datos de perfil.
- **RF-36.4:** CUANDO se registre exitosamente la calificación de usuario verificado en el repositorio persistente, el sistema DEBERÁ actualizar de inmediato y de forma reactiva la reputación comunitaria en las pantallas de Perfil de Usuario y Panel de Control sin requerir recarga manual ni reinicio de la aplicación.
- **RF-36.5:** SI la inserción remota de la calificación de usuario verificado falla por desconexión o indisponibilidad del servicio, ENTONCES el sistema DEBERÁ permitir que el guardado del perfil de usuario concluya satisfactoriamente, evitando interrumpir o bloquear la experiencia del usuario.

---

## 5. Requisitos No Funcionales (RNF)

- **RNF-19 (Carga No Bloqueante y Rendimiento):** La consulta de la información de reputación del usuario o propietario DEBERÁ ejecutarse de forma asíncrona sin bloquear la carga ni la interactividad de los detalles fundamentales de la propiedad (título, precio, fotos, descripción) ni del perfil de usuario.
- **RNF-20 (Accesibilidad Semántica):** Todo indicador visual de estrellas y distintivos de reputación DEBERÁ incorporar descripciones auditivas y etiquetas de accesibilidad compatibles con lectores de pantalla (ejemplo: `"Calificación de 4.8 estrellas sobre 5, basado en 12 opiniones"`), cumpliendo las directrices WCAG 2.1 nivel AA.
- **RNF-21 (Consistencia de Diseño en Pantallas Estrechas):** La presentación de la insignia de calificación en el detalle de la propiedad DEBERÁ adaptarse fluidamente a dispositivos móviles con anchos de pantalla reducidos (hasta 320 px) sin desbordamientos horizontales de texto o iconos.
- **RNF-22 (Sincronización en Navegación sin Bloqueo de Interfaz):** Las actualizaciones automáticas de reputación desencadenadas al navegar o cambiar de vista DEBERÁN ejecutarse de forma asíncrona en segundo plano, sin bloquear la interfaz de usuario ni generar saltos o parpadeos perceptibles.

---

## 6. Casos Límite y Manejo de Excepciones

- **CL-24 (Propietario Nuevo sin Calificaciones en Detalle de Propiedad):** SI una propiedad pertenece a un arrendador sin reseñas, ENTONCES el bloque del anfitrión en el detalle del inmueble DEBERÁ mostrar `"Sin calificaciones aún"` (o `"3.0 ★ Puntaje inicial de confianza"` si está verificado) sin desestructurar el diseño de la tarjeta de contacto.
- **CL-25 (Propiedad con Propietario No Disponible o Inactivo):** SI los datos del arrendador asociado a una propiedad no se encuentran disponibles o la cuenta fue suspendida, ENTONCES el sistema DEBERÁ mostrar la información inmobiliaria disponible ocultando la sección de reputación sin generar bloqueos en la vista.
- **CL-26 (Volumen Elevado de Reseñas en Perfil):** SI un usuario registra un número considerable de reseñas (ejemplo: más de 50 opiniones), ENTONCES el sistema DEBERÁ implementar paginación o desplazamiento continuo para evitar degradación de memoria y rendimiento en la pantalla de perfil.
- **CL-27 (Formateo de Cifras Mayores en Contadores):** SI el total de reseñas supera las 999 evaluaciones, ENTONCES el sistema DEBERÁ formatear la cifra en un estándar compacto legible (ejemplo: `"1.2k reseñas"`).
- **CL-28 (Comentarios Extensos en Listado de Opiniones):** SI una reseña contiene un comentario de hasta 500 caracteres, ENTONCES el sistema DEBERÁ limitar la visualización inicial a 3 líneas de texto con un control de alternancia `"Ver más"` y `"Ver menos"` para no sobrecargar el desplazamiento vertical.
- **CL-29 (Fallo de Red con Caché Parcial de Inmueble):** SI los datos de la propiedad están disponibles localmente pero la reputación del propietario falla por desconexión, ENTONCES el sistema DEBERÁ presentar un estado neutral transitorio de advertencia discreta permitiendo el reintento sin congelar la pantalla.
- **CL-30 (Navegación Frecuente Entre Pestañas y Pantallas):** SI el usuario alterna rápidamente entre pestañas o pantallas sucesivas, ENTONCES el sistema DEBERÁ gestionar eficientemente las peticiones de sincronización en segundo plano, descartando respuestas obsoletas y evitando sobrecarga innecesaria en la red.
- **CL-31 (Idempotencia de Calificación de Usuario Verificado):** SI un usuario edita o guarda sus datos de perfil en múltiples oportunidades tras haber completado su perfil inicial, ENTONCES el sistema DEBERÁ verificar la existencia de una reseña previa de verificación antes de registrar una nueva, garantizando que no se generen duplicados ni se altere indebidamente el promedio ponderado.

---

## 7. Fuera de Alcance

1. **Flujo de verificación de documentos de identidad:** La aprobación y concesión de la insignia de verificación continúa siendo un proceso de plataforma previo; esta especificación solo consume el estado de verificación existente.
2. **Acción de emitir nueva calificación interactiva entre usuarios desde el detalle de la propiedad:** Las calificaciones cruzadas entre partes solo se originan a partir de solicitudes de arriendo completadas (especificación 005); la calificación inicial de usuario verificado al completar datos de perfil (RF-36) es una evaluación automática del sistema.
3. **Filtros avanzados y ordenamiento complejo de reseñas:** En esta entrega no se contemplan filtros por cantidad de estrellas (ejemplo: "ver solo 5 estrellas") ni motores de búsqueda de palabras clave dentro de los comentarios.
4. **Respuesta pública a reseñas desde el perfil:** No se incluye la funcionalidad para que el titular responda públicamente a los comentarios expuestos en su perfil.

---

## 8. Criterios de Finalización (Definition of Done)

Para considerar concluida satisfactoriamente la entrega de esta especificación, deberán satisfacerse la totalidad de las siguientes condiciones:
1. **Especificación validada:** Aprobación de los criterios de aceptación EARS y resolución de los 9 hallazgos de aseguramiento de calidad.
2. **Integración en Pantalla de Perfil de Usuario:** Se exhibe el encabezado de reputación con promedio numérico, estrellas gráficas, contador de reseñas y lista de opiniones con control de expansión/colapso, estados neutrales y soporte de usuarios verificados.
3. **Integración en Pantalla de Detalle de Propiedad:** Se exhibe de forma prominente la insignia y calificación del propietario en la sección del anfitrión con apertura modal inferior (*bottom sheet*) de las opiniones históricas.
4. **Integración en Panel de Control del Arrendador:** Se exhibe el ranking y nivel de confianza del propietario en su panel principal de gestión con acceso interactivo a sus opiniones históricas y soporte de actualización reactiva.
5. **Actualización y Escucha Reactiva en Navegación:** Sincronización automática del ranking y reputación al navegar por las pantallas de Perfil de Usuario, Panel de Control y Detalle de Propiedad, reflejando de inmediato los cambios sin requerir reinicio de la aplicación.
6. **Persistencia de Calificación de Usuario Verificado:** Registro automático de la calificación de 3 estrellas con comentario `"Usuario verificado"` en el repositorio persistente al completar perfil (arrendador y arrendatario), con idempotencia garantizada y actualización reactiva.
7. **Manejo de Casos Límite:** Verificación de usuarios sin calificaciones, usuarios verificados con puntaje inicial de 3.0 ★, adaptación en pantallas estrechas (320 px) y resiliencia ante errores de red.
8. **Calidad y Cobertura de Pruebas:**
   - 100% de pruebas unitarias y de widgets aprobadas sin fallas.
   - 0 advertencias o errores en el análisis estático de código (`flutter analyze`).
9. **Sincronización:** Actualización y cierre de las tareas correspondientes en Notion y registro en el repositorio Git.

---

## 9. Dudas Abiertas

*Actualmente no se identifican dudas abiertas bloqueantes. Los 9 hallazgos de aseguramiento de calidad han sido formalmente incorporados en los requisitos funcionales y casos límite.*
