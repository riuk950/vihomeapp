# Especificación Funcional: Mejora de Interfaz (UI) en la Tabla de Solicitudes (004-vihomeapp-mvp)

## 1. Contexto y Objetivo
En las fases precedentes de la plataforma, el flujo de solicitudes de arrendamiento permitía capturar información básica y contextualizada según la tipología del inmueble. Sin embargo, la presentación de las solicitudes presentaba oportunidades críticas de mejora a nivel de usabilidad y experiencia de usuario en dispositivos móviles:
- La vista de solicitudes carecía de una jerarquía visual estructurada y de alta densidad que permitiera escanear con rapidez los datos determinantes (quién postula, a qué propiedad, en qué fecha y bajo qué estado).
- Los arrendatarios no contaban con una indicación explícita sobre el "paso siguiente" de su postulación, generando incertidumbre sobre el avance del trámite o la forma de contactar al propietario una vez aprobada.
- No existían mecanismos inmediatos de segmentación por estado en la vista principal, obligando al usuario a inspeccionar registros mixtos.
- Existían riesgos de desbordamiento visual (*overflows*) en pantallas con dimensiones reducidas cuando los nombres, títulos de inmuebles o motivos excedían los anchos estándar.

El objetivo de esta especificación es formalizar el comportamiento funcional, las reglas de visualización móvil, los criterios de filtrado y el ciclo de retroalimentación interactiva para la **tabla y lista de solicitudes de arrendamiento**, tanto para el perfil de arrendador como para el de arrendatario, asegurando una experiencia ágil, legible y sin desbordamientos en cualquier dispositivo móvil.

---

## 2. Perfiles de Usuario

- **Arrendador (Propietario / Administrador):** Usuario que gestiona propiedades publicadas y necesita revisar, clasificar y evaluar las solicitudes recibidas de manera rápida, identificando de inmediato a los postulantes, sus datos de contacto y el estado de revisión.
- **Arrendatario (Postulante / Inquilino):** Usuario que ha enviado una o más postulaciones a inmuebles y requiere monitorear de forma transparente el estado actual de cada solicitud, entender el paso siguiente a seguir y acceder al contacto directo del propietario cuando su solicitud sea aceptada.

---

## 3. Historias de Usuario

- **HU-18 (Visualización Clara y Estructurada de Solicitudes):** Como Arrendatario o Arrendador, quiero que el listado de solicitudes presente la información de forma clara, organizada y con alta densidad visual en tarjetas compactas, para que pueda identificar rápidamente el estado y los datos clave de cada solicitud sin confusiones ni desbordamientos de pantalla.
- **HU-19 (Identificación del Paso Siguiente para Arrendatarios):** Como Arrendatario, quiero ver en cada postulación enviada un resumen claro del paso siguiente (si está en espera de revisión, si fue aprobada con habilitación de contacto o si fue rechazada), para tener certeza del estado del trámite y saber cómo proceder.
- **HU-20 (Contacto Rápido desde la Lista):** Como usuario (Arrendador o Arrendatario con solicitud aceptada), quiero disponer de un botón de contacto directo (llamada o WhatsApp) en la misma tarjeta de solicitud cuando haya un teléfono disponible, para comunicarme ágilmente sin pasos intermedios innecesarios.
- **HU-21 (Filtrado Rápido por Estado de Solicitud):** Como usuario, quiero segmentar mis solicitudes mediante pestañas o chips de estado (Todas, Pendientes, Aceptadas, Rechazadas) y verlas ordenadas cronológicamente, para enfocarme en las solicitudes que requieren atención prioritaria.

---

## 4. Requisitos Funcionales (RF)

### RF-18: Presentación y Estructura Visual en Dispositivos Móviles
- **RF-18.1:** El sistema DEBERÁ presentar las solicitudes utilizando un formato de tarjetas estructuradas de alta densidad tipo fila optimizadas para pantalla móvil, adaptándose al ancho disponible sin requerir desplazamiento horizontal.
- **RF-18.2:** MIENTRAS el arrendador visualice el listado de solicitudes recibidas, el sistema DEBERÁ mostrar en cada tarjeta los siguientes elementos obligatorios:
  - Nombre completo del solicitante.
  - Título o denominación del inmueble postulado.
  - Fecha de registro de la postulación en formato legible (ej. día, mes y año).
  - Insignia distintiva de estado (`Pendiente`, `Aceptada` o `Rechazada`).
  - Botón de contacto rápido directo si existe un número telefónico asociado.
- **RF-18.3:** MIENTRAS el arrendatario visualice el listado de sus solicitudes enviadas, el sistema DEBERÁ mostrar en cada tarjeta los siguientes elementos obligatorios:
  - Título o denominación del inmueble postulado.
  - Nombre del arrendador o contacto responsable.
  - Fecha de envío de la solicitud en formato legible.
  - Insignia distintiva de estado (`Pendiente`, `Aceptada` o `Rechazada`).
  - Bloque visual informativo con el "Paso siguiente" correspondiente.
- **RF-18.4:** MIENTRAS se representen nombres, títulos o descripciones de longitud superior al espacio asignado en la tarjeta, el sistema DEBERÁ aplicar truncamiento seguro mediante puntos suspensivos (`...`), impidiendo desbordamientos visuales o quiebres de interfaz.

### RF-19: Ciclo de Vida y Resumen del Paso Siguiente (Vista Arrendatario)
- **RF-19.1:** SI la solicitud del arrendatario se encuentra en estado `Pendiente`, ENTONCES el sistema DEBERÁ exhibir una insignia en color de aviso y un mensaje destacado de paso siguiente con el texto: `Esperando respuesta del propietario`.
- **RF-19.2:** SI la solicitud del arrendatario pasa a estado `Aceptada`, ENTONCES el sistema DEBERÁ:
  - Exhibir una insignia en color de éxito (positivo).
  - Presentar el mensaje de paso siguiente con el texto: `Contacto habilitado`.
  - Habilitar e incorporar en la tarjeta el botón de contacto rápido directo (llamada y/o enlace a WhatsApp) hacia el propietario.
- **RF-19.3:** SI la solicitud del arrendatario se encuentra en estado `Rechazada`, ENTONCES el sistema DEBERÁ exhibir una insignia en color de advertencia/inactivo y un mensaje de paso siguiente con el texto: `Solicitud no aprobada`, omitiendo botones de contacto directo asociados a dicha postulación.

### RF-20: Interacción Directa y Navegación al Detalle
- **RF-20.1:** CUANDO el usuario presione el cuerpo general de una tarjeta de solicitud, el sistema DEBERÁ navegar a la vista de detalle completo de dicha solicitud, permitiendo consultar los soportes financieros, formularios contextuales y realizar la gestión de aprobación o rechazo (en el caso del arrendador).
- **RF-20.2:** CUANDO el usuario presione el botón de contacto rápido presente en una tarjeta, el sistema DEBERÁ invocar el servicio de comunicación del dispositivo (marcador telefónico o enlace directo a WhatsApp) utilizando el número telefónico del destinatario.
- **RF-20.3:** SI una solicitud no dispone de número telefónico registrado para el contacto, ENTONCES el sistema DEBERÁ ocultar de forma limpia el botón de contacto rápido en la tarjeta, manteniendo inalterada la estructura de los demás elementos y la navegación al detalle.

### RF-21: Segmentación, Filtros por Estado y Orden Cronológico
- **RF-21.1:** El sistema DEBERÁ incluir en la parte superior de la vista una barra de segmentación rápida con cuatro pestañas o chips de filtro:
  - `Todas`: Muestra el consolidado global de solicitudes.
  - `Pendientes`: Muestra exclusivamente las solicitudes en espera de decisión.
  - `Aceptadas`: Muestra exclusivamente las solicitudes aprobadas.
  - `Rechazadas`: Muestra exclusivamente las solicitudes declinadas.
- **RF-21.2:** CUANDO el usuario seleccione cualquiera de los filtros de estado, el sistema DEBERÁ actualizar de forma inmediata la lista para exhibir únicamente los registros correspondientes.
- **RF-21.3:** El sistema DEBERÁ ordenar las solicitudes de forma predeterminada en orden cronológico descendente (las solicitudes más recientes se posicionan en la cabecera del listado).

### RF-22: Gestión de Estados Vacíos y Resiliencia de Conexión
- **RF-22.1:** SI un usuario ingresa a la vista de solicitudes y no cuenta con ninguna postulación registrada (en ninguna categoría), ENTONCES el sistema DEBERÁ presentar un estado vacío compuesto por un ícono o ilustración alegórica, un mensaje informativo claro en español y un botón de acción principal ("Explorar inmuebles" para inquilinos o "Ver mis propiedades" para propietarios).
- **RF-22.2:** SI el usuario selecciona un filtro por estado que no contiene registros (ej. filtro `Aceptadas` con cero postulaciones aprobadas), ENTONCES el sistema DEBERÁ exhibir un mensaje amigable indicando que no hay solicitudes bajo ese estado e invitando a consultar las demás pestañas.
- **RF-22.3:** SI ocurre una interrupción de red o fallo de carga al consultar las solicitudes, ENTONCES el sistema DEBERÁ presentar un mensaje descriptivo del incidente con un botón para "Reintentar", permitiendo además actualizar la vista mediante el gesto de deslizamiento vertical hacia abajo (*pull-to-refresh*).

---

## 5. Requisitos No Funcionales (RNF)

- **RNF-11 (Rendimiento de Desplazamiento y Fluidez):** El desplazamiento vertical de la lista de tarjetas DEBERÁ mantener una tasa de refresco constante de 60 fotogramas por segundo (fps) en dispositivos móviles estándar, sin tirones (*jank*) durante el scroll o el cambio de filtros.
- **RNF-12 (Adaptabilidad y Cero Desbordamientos):** La interfaz DEBERÁ ser completamente responsiva en pantallas con anchos desde 320 px hasta pantallas de tabletas, garantizando cero desbordamientos visuales (*RenderFlex overflow*) bajo cualquier densidad de píxeles o tamaño de fuente del sistema.
- **RNF-13 (Accesibilidad y Contraste Visual):** Las insignias de estado, textos informativos y botones de acción DEBERÁN cumplir con las pautas de accesibilidad WCAG 2.1 nivel AA respecto al ratio de contraste de color (mínimo 4.5:1 para texto estándar).
- **RNF-14 (Tiempo de Respuesta en Filtrado Local):** La alternancia entre pestañas de filtro (`Todas`, `Pendientes`, `Aceptadas`, `Rechazadas`) sobre datos ya cargados DEBERÁ ejecutarse en un tiempo no mayor a 50 milisegundos.

---

## 6. Casos Límite y Manejo de Excepciones

- **CL-15 (Nombres o Títulos Extremadamente Largos):** SI el nombre de un solicitante supera los 40 caracteres o el título de una propiedad supera los 60 caracteres, ENTONCES el sistema DEBERÁ aplicar truncamiento elíptico en un máximo de líneas fijas para preservar la altura uniforme de la tarjeta, permitiendo ver el contenido íntegro en la pantalla de detalle.
- **CL-16 (Número Telefónico Incompleto o Ausente):** SI el contacto no tiene teléfono asignado o el campo telefónico contiene un formato inválido, ENTONCES el sistema DEBERÁ ocultar el botón de acción rápida de llamada/WhatsApp sin generar huecos visuales irregulares en la tarjeta.
- **CL-17 (Transición Concurrente de Estado):** SI el arrendador acepta o rechaza una solicitud y el arrendatario refresca su vista, ENTONCES el sistema DEBERÁ actualizar de inmediato la insignia de estado, los botones de contacto y el bloque de paso siguiente sin duplicar registros.
- **CL-18 (Listas con Alto Volumen de Solicitudes):** SI un propietario administra un volumen superior a 50 solicitudes, ENTONCES el sistema DEBERÁ mantener un consumo de memoria acotado y scroll fluido reutilizando las tarjetas visuales de forma eficiente.

---

## 7. Fuera de Alcance

1. **Exportación de datos:** No se incluye la generación ni descarga de solicitudes en formato PDF, Excel o CSV.
2. **Selección múltiple y acciones en bloque:** No se contemplan casillas de verificación (*checkboxes*) para aprobar, rechazar o archivar múltiples solicitudes simultáneamente en un solo paso.
3. **Plataforma de mensajería interna / chat integrado:** La comunicación directa se canaliza a través de las aplicaciones nativas de llamada telefónica o WhatsApp del dispositivo; no se implementa un chat interno propietario dentro de la aplicación.
4. **Pasarela de cobro o pagos en línea:** No se incluye el cobro de cánones de arrendamiento, depósitos ni comisiones dentro de la lista o detalle de solicitudes.

---

## 8. Criterios de Finalización (Definition of Done)

1. Todos los requisitos funcionales (RF-18 a RF-22) y casos límite (CL-15 a CL-18) se encuentran formalizados bajo la notación EARS en español.
2. Se ha especificado con precisión el comportamiento visual tanto para la perspectiva del Arrendador como del Arrendatario.
3. Se han formalizado las reglas de negocio para cada uno de los tres estados de solicitud (`Pendiente`, `Aceptada`, `Rechazada`) y su respectivo paso siguiente.
4. El documento excluye terminología de arquitectura, frameworks, bibliotecas y nombres de archivos de código fuente, centrándose exclusivamente en el **QUÉ** y el **POR QUÉ**.

---

## 9. Dudas Abiertas

- `[NECESITA ACLARACIÓN]` **Contador numérico de solicitudes en chips de filtro:** Confirmar si las pestañas de filtro (`Todas`, `Pendientes`, `Aceptadas`, `Rechazadas`) deben exhibir un indicador numérico con el total de elementos coincidentes (ej: `Pendientes (3)`).
- `[NECESITA ACLARACIÓN]` **Mensaje plantilla predeterminado para WhatsApp:** Confirmar si al presionar el botón de WhatsApp se debe pre-cargar un mensaje plantilla introductorio (ej: *"Hola, te contacto desde Vihome respecto a la solicitud para..."*) o si debe abrir la conversación en blanco.
