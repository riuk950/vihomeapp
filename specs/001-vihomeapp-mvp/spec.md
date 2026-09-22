# Especificación Funcional: ViHome MVP (001-vihomeapp-mvp)

## 1. Contexto y Objetivo
El mercado de arrendamiento inmobiliario tradicional presenta fricciones considerables en la conexión entre propietarios e inquilinos, la verificación inicial de solvencia y la monetización equitativa de los espacios publicitarios. 

El objetivo de este MVP es proporcionar una plataforma centralizada y confiable donde los arrendadores puedan publicar y gestionar sus inmuebles bajo un modelo escalable (gratuito con publicidad y límite de una propiedad, o mediante suscripción para múltiples propiedades sin anuncios), y donde los arrendatarios puedan descubrir inmuebles mediante filtros clave y postularse formalmente compartiendo su información y solvencia financiera inicial.

---

## 2. Perfiles de Usuario

- **Arrendatario (Inquilino):** Usuario interesado en buscar inmuebles en alquiler, filtrar según sus necesidades (ciudad, tipo de inmueble, precio), consultar el detalle de las propiedades y postularse mediante una solicitud formal que incluye su situación financiera y comprobantes de ingreso.
- **Arrendador (Propietario):** Usuario que publica y gestiona sus inmuebles en alquiler, evalúa las solicitudes financieras recibidas por parte de los arrendatarios interesados y gestiona su nivel de suscripción para habilitar la publicación de múltiples propiedades y eliminar la publicidad.
- **Visitante / No autenticado:** Usuario que puede explorar el catálogo de propiedades disponibles antes de registrarse o iniciar sesión para postularse o publicar.

---

## 3. Historias de Usuario

- **HU-01 (Búsqueda y Exploración):** Como arrendatario, quiero buscar y filtrar propiedades por ciudad, tipo de inmueble y rango de precio, para encontrar opciones que se ajusten a mi presupuesto y preferencias de vivienda.
- **HU-02 (Detalle del Inmueble):** Como arrendatario, quiero ver la información detallada, fotografías y precio de una propiedad, para decidir si deseo postularme para arrendarla.
- **HU-03 (Solicitud Financiera):** Como arrendatario, quiero enviar una solicitud de arrendamiento adjuntando mis ingresos mensuales y comprobantes, para demostrar al arrendador mi capacidad de pago e interés formal.
- **HU-04 (Publicación de Inmuebles):** Como arrendador, quiero registrar y publicar un inmueble con sus características principales, fotos y precio, para ponerlo a disposición de posibles inquilinos.
- **HU-05 (Gestión de Solicitudes):** Como arrendador, quiero visualizar y evaluar las solicitudes recibidas con los comprobantes financieros de los postulantes, para seleccionar al inquilino adecuado.
- **HU-06 (Monetización y Suscripción):** Como arrendador, quiero suscribirme a un plan premium, para publicar más de una propiedad simultáneamente y disfrutar de una experiencia libre de anuncios comerciales.
- **HU-07 (Experiencia con Anuncios en Plan Gratuito):** Como usuario del plan gratuito, quiero tener acceso sin costo a la plataforma, aceptando la visualización de espacios publicitarios comerciales integrados.

---

## 4. Requisitos Funcionales (RF)

### RF-01: Autenticación y Perfil de Usuario
- **RF-01.1:** CUANDO un usuario ingrese credenciales válidas (correo electrónico y contraseña), el sistema DEBERÁ autenticar al usuario y concederle acceso a su sesión.
- **RF-01.2:** SI las credenciales ingresadas son inválidas o inexistentes, ENTONCES el sistema DEBERÁ mostrar un mensaje claro de error indicando que los datos no coinciden.
- **RF-01.3:** CUANDO un usuario no autenticado intente postularse a una propiedad o publicar un inmueble, el sistema DEBERÁ solicitarle iniciar sesión o registrarse antes de continuar.

### RF-02: Búsqueda y Filtrado de Inmuebles
- **RF-02.1:** El sistema DEBERÁ permitir filtrar el catálogo de propiedades por los siguientes criterios: ciudad, tipo de inmueble (casa, apartamento, etc.) y rango de precio (mínimo y máximo).
- **RF-02.2:** CUANDO el usuario aplique uno o varios filtros, el sistema DEBERÁ actualizar la lista de resultados mostrando únicamente los inmuebles que cumplan con todos los criterios seleccionados.
- **RF-02.3:** SI no existen propiedades que coincidan con los criterios de búsqueda, ENTONCES el sistema DEBERÁ mostrar un mensaje informativo claro indicando la ausencia de resultados y sugerir ajustar los filtros.

### RF-03: Visualización de Propiedades
- **RF-03.1:** El sistema DEBERÁ presentar para cada propiedad su título, descripción, tipo de inmueble, ciudad, valor del canon de arrendamiento, características y galería de imágenes.
- **RF-03.2:** MIENTRAS el arrendatario visualice el detalle de una propiedad activa, el sistema DEBERÁ habilitar la opción de iniciar una solicitud de arrendamiento.

### RF-04: Envío y Registro de Solicitud Financiera
- **RF-04.1:** CUANDO el arrendatario decida postularse a una propiedad, el sistema DEBERÁ presentar un formulario de solicitud que requiera obligatoriamente el monto de ingresos mensuales y el cargue de al menos un comprobante de ingresos (documento/imagen).
- **RF-04.2:** SI el arrendatario intenta enviar la solicitud sin especificar ingresos o sin adjuntar el comprobante, ENTONCES el sistema DEBERÁ bloquear el envío y señalar claramente los campos faltantes.
- **RF-04.3:** CUANDO la solicitud sea enviada exitosamente, el sistema DEBERÁ confirmar la recepción de la misma al arrendatario y notificar la postulación en la bandeja del arrendador correspondiente.
- **RF-04.4:** SI ocurre un error de conectividad durante el envío de la solicitud o la carga de documentos, ENTONCES el sistema DEBERÁ mostrar un mensaje claro de error y mantener los datos ingresados en el formulario para permitir reintentar el envío.

### RF-05: Publicación y Gestión de Inmuebles por el Arrendador
- **RF-05.1:** CUANDO un arrendador cree una propiedad, el sistema DEBERÁ exigir obligatoriamente: título, tipo de inmueble, ciudad, precio del alquiler, descripción y al menos una fotografía.
- **RF-05.2:** SI el arrendador cuenta con el plan gratuito y ya tiene una (1) propiedad activa publicada, ENTONCES el sistema DEBERÁ bloquear la publicación de una nueva propiedad y ofrecer la opción de suscribirse al plan premium.
- **RF-05.3:** DONDE el arrendador cuente con una suscripción premium activa, el sistema DEBERÁ permitirle publicar múltiples propiedades sin restricción de unidad única.
- **RF-05.4:** CUANDO el arrendador modifique o pause una de sus publicaciones, el sistema DEBERÁ reflejar de inmediato los cambios en el catálogo público.

### RF-06: Gestión de Solicitudes por el Arrendador
- **RF-06.1:** MIENTRAS el arrendador consulte el panel de una de sus propiedades, el sistema DEBERÁ listar todas las solicitudes recibidas con fecha de postulación, monto de ingresos y acceso para visualizar los comprobantes adjuntos.
- **RF-06.2:** CUANDO el arrendador evalúe una solicitud, el sistema DEBERÁ permitirle actualizar su estado (por ejemplo: En revisión, Aprobada, Rechazada).
- **RF-06.3:** CUANDO el estado de una solicitud cambie, el sistema DEBERÁ reflejar el nuevo estado en la vista de seguimiento del arrendatario postulante.

### RF-07: Suscripciones y Publicidad
- **RF-07.1:** MIENTRAS el usuario opere bajo el plan gratuito, el sistema DEBERÁ desplegar anuncios comerciales en las secciones designadas de la aplicación.
- **RF-07.2:** DONDE el arrendador adquiera una suscripción activa, el sistema DEBERÁ suprimir la totalidad de los anuncios comerciales de su experiencia.
- **RF-07.3:** SI una suscripción premium finaliza o se cancela, ENTONCES el sistema DEBERÁ restituir las condiciones del plan gratuito (activación de anuncios y límite de 1 propiedad activa para futuras publicaciones).

---

## 5. Requisitos No Funcionales (RNF)

- **RNF-01 (Claridad en Manejo de Errores):** El sistema debe presentar mensajes descriptivos, no técnicos y accionables ante cualquier falla de validación, error de red o límite de permisos.
- **RNF-02 (Seguridad y Privacidad Financiera):** La información de ingresos y los documentos de comprobantes adjuntos deben ser accesibles únicamente por el arrendatario que los emite y el arrendador propietario del inmueble al que se postuló.
- **RNF-03 (Rendimiento y Carga de Medios):** Las imágenes de las propiedades y los comprobantes deben optimizarse para garantizar tiempos de carga ágiles en redes móviles estándar.
- **RNF-04 (Consistencia de Datos):** Ante pérdidas momentáneas de conexión durante formularios de postulación o publicación, el sistema no debe perder el texto ingresado por el usuario en pantalla.

---

## 6. Casos Límite y Manejo de Excepciones

- **CL-01 (Cargue de archivos pesados o formatos inválidos):** Si el usuario intenta adjuntar un comprobante en un formato no soportado o que excede el tamaño máximo establecido, el sistema debe alertar antes de subir y solicitar un archivo compatible.
- **CL-02 (Pérdida de conexión durante el envío):** Si la red se interrumpe mientras se procesa la solicitud financiera o la publicación de un inmueble, el sistema debe notificar el fallo de conexión sin vaciar los campos del formulario y permitir el reintento.
- **CL-03 (Propiedad despublicada con solicitudes en curso):** Si un arrendador pausa o elimina una propiedad que tenía solicitudes pendientes, los arrendatarios con solicitudes activas deben poder ver que la propiedad ya no se encuentra disponible.
- **CL-04 (Intento de duplicar solicitud):** Si un arrendatario intenta enviar más de una solicitud simultánea a la misma propiedad mientras tiene una activa, el sistema debe informarle que ya cuenta con una postulación en curso para ese inmueble.

---

## 7. Fuera de Alcance del MVP

- Procesamiento de pagos en línea del canon de arrendamiento mensual dentro de la aplicación.
- Firma electrónica/digital con validez legal de contratos de arrendamiento.
- Chat libre o mensajería instantánea abierta no estructurada (la comunicación inicial se canaliza a través de la solicitud formal con datos financieros).
- Venta de proyectos inmobiliarios en preventa o pozo complejos.
- Facturación electrónica automatizada para arrendadores.
- Calificaciones o reseñas públicas entre arrendatarios y propietarios.

---

## 8. Criterios de Finalización (Definition of Done)

1. Todos los requisitos funcionales (RF-01 a RF-07) están especificados con criterios de aceptación en sintaxis EARS.
2. Los flujos de búsqueda/filtrado, detalle de propiedad, envío de solicitud financiera, publicación con límites de plan (1 gratis vs ilimitadas premium), visualización de solicitudes y anuncios comerciales están completamente definidos.
3. Se han formalizado todos los casos de error con mensajes comprensibles para el usuario final.
4. Las pruebas de comportamiento requeridas para validar cada criterio EARS quedan identificadas para la fase de implementación.

---

## 9. Dudas Abiertas y Puntos de Decisión

- `[NECESITA ACLARACIÓN]` **Tamaño y formato admitido para comprobantes:** Definir formalmente la lista exacta de formatos permitidos (PDF, JPG, PNG) y el peso máximo por archivo (ej. 5 MB o 10 MB).
- `[NECESITA ACLARACIÓN]` **Mecanismo de pago de la suscripción:** Confirmar si la activación de la suscripción en este MVP se gestiona mediante compras dentro de la tienda de aplicaciones (In-App Purchases) o enlace a pasarela externa web.
- `[NECESITA ACLARACIÓN]` **Notificaciones al usuario:** Confirmar si las notificaciones de cambio de estado de solicitud y recepción de postulaciones serán exclusivamente dentro de la aplicación (in-app) o si requerirán además notificaciones push / correo electrónico para el MVP.
