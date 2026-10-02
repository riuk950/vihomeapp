# Especificación Funcional: Persistencia de Datos al Cambiar Rol (007-vihomeapp-mvp)

## 1. Contexto y Objetivo

En la plataforma ViHome, los usuarios pueden interactuar tanto en calidad de inquilinos (Arrendatarios) como de propietarios u oferentes de inmuebles (Arrendadores). La información personal básica requerida por la plataforma para certificar la identidad de un usuario es compartida y equivalente en ambos roles: nombres completos, apellidos, tipo y número de documento de identidad, teléfono de contacto y dirección de contacto.

Actualmente, cuando un usuario que ya completó su registro y validó su información personal como Arrendatario decide cambiar su rol a Arrendador dentro de su perfil (o viceversa), el sistema actualiza la etiqueta de rol pero no transfiere ni preserva sus datos personales preexistentes hacia el repositorio del nuevo rol. Como consecuencia directa:
1. El usuario es percibido por la plataforma como si fuera un usuario nuevo sin datos ni verificación.
2. La interfaz redirige de manera forzosa e intempestiva al usuario a pantallas de captura de datos ya suministrados.
3. Se presentan formularios vacíos que obligan al usuario a reingresar manualmente información redundante, exponiéndolo a alertas de "campos obligatorios vacíos".
4. Se bloquean injustificadamente las funcionalidades operativas del nuevo rol (tales como la publicación de propiedades o el acceso a la gestión de solicitudes) a pesar de que el usuario ya era un usuario verificado.
5. No existe un mecanismo simétrico y amigable para regresar o alternar entre el rol de Arrendador y Arrendatario desde la interfaz.

El objetivo de esta especificación es formalizar la **Persistencia y Sincronización Automática de Datos al Cambiar Rol**, garantizando que:
- La información personal del usuario permanezca intacta y vinculada de manera persistente a su identidad única, independientemente de la alternancia de roles.
- Al cambiar de rol, si el usuario ya completó previamente su perfil, sus datos se sincronicen de inmediato sin exigir re-entrada de datos.
- Las funcionalidades y permisos asociados al nuevo rol se activen inmediatamente sin interrupciones ni pantallas intermedias innecesarias.
- Si el usuario decide acceder voluntariamente a actualizar su información en cualquier rol, los formularios carguen de forma predeterminada los datos personales existentes.
- La experiencia de alternancia de rol sea bidireccional, fluida y transparente tanto para Arrendatarios como para Arrendadores.

---

## 2. Perfiles de Usuario

- **Arrendatario:** Usuario registrado que busca o postula a inmuebles en arriendo y que ya ha completado su información personal. Desea poder convertirse en Arrendador para publicar inmuebles sin tener que volver a digitar sus datos de identidad, domicilio ni teléfono.
- **Arrendador:** Usuario registrado que gestiona propiedades y arriendos. Desea poder alternar al rol de Arrendatario para buscar u ofertar por arriendos conservando intacta su información personal y su estatus verificado.

---

## 3. Historias de Usuario

- **HU-32 (Cambio de Rol con Datos Persistentes):** Como usuario de la plataforma (Arrendatario o Arrendador), quiero que mi información personal se mantenga intacta cuando cambie mi rol en la aplicación, para que no tenga que completar datos de forma redundante y el proceso sea fluido y rápido.
- **HU-33 (Evitar Re-entrada de Datos y Alertas Redundantes):** Como usuario que acaba de alternar su rol y ya contaba con un perfil completo, quiero que el sistema reconozca mi información previa y no me exija completar campos básicos ni me muestre alertas de campos obligatorios vacíos.
- **HU-34 (Habilitación Inmediata de Permisos del Nuevo Rol):** Como usuario que cambia de rol exitosamente, quiero que las funciones operativas del nuevo rol (ejemplo: publicar propiedades en el rol de Arrendador, o postular a propiedades en el rol de Arrendatario) queden habilitadas de inmediato sin bloqueos artificiales de verificación.
- **HU-35 (Alternancia Bidireccional de Rol desde el Perfil):** Como usuario en cualquier rol activo, quiero disponer de una opción clara y accesible en mi Pantalla de Perfil de Usuario para alternar entre el rol de Arrendatario y el rol de Arrendador mediante confirmación explícita.
- **HU-36 (Precarga de Datos en Formularios de Perfil):** Como usuario que accede a las pantallas de actualización o completado de información de perfil en cualquier momento, quiero que los campos del formulario aparezcan precargados con los datos personales ya registrados en el sistema para facilitar su edición sin empezar desde cero.

---

## 4. Requisitos Funcionales (RF)

### RF-37: Sincronización y Persistencia de Datos al Cambiar de Rol
- **RF-37.1:** CUANDO un usuario autenticado confirme la solicitud de cambio de rol de Arrendatario a Arrendador, el sistema DEBERÁ:
  - Actualizar la asignación del rol activo del usuario al valor de "Arrendador".
  - MIENTRAS el usuario posea un registro de información personal previo como Arrendatario: copiar y sincronizar automáticamente la totalidad de sus datos personales (primer nombre, segundo nombre si existe, primer apellido, segundo apellido si existe, tipo de documento, número de documento, teléfono de contacto y dirección de contacto) hacia el registro del perfil de Arrendador, asegurando que no se pierda ningún dato existente.
- **RF-37.2:** CUANDO un usuario autenticado confirme la solicitud de cambio de rol de Arrendador a Arrendatario, el sistema DEBERÁ:
  - Actualizar la asignación del rol activo del usuario al valor de "Arrendatario".
  - MIENTRAS el usuario posea un registro de información personal previo como Arrendador: copiar y sincronizar automáticamente la totalidad de sus datos personales hacia el registro del perfil de Arrendatario sin pérdida de información.
- **RF-37.3:** El sistema DEBERÁ asegurar que la actualización de rol preserve de manera inmutable el identificador único del usuario, su correo electrónico, su estatus de suscripción y su reputación comunitaria acumulada.

### RF-38: Prevención de Redirección Innecesaria y Supresión de Alertas
- **RF-38.1:** SI el usuario que ejecuta el cambio de rol ya cuenta con un perfil completo y verificado en su rol de origen, ENTONCES el sistema NO DEBERÁ redirigir al usuario hacia formularios de captura obligatoria de datos ni interrumpir su permanencia en la aplicación.
- **RF-38.2:** CUANDO culmine exitosamente el cambio de rol con datos persistidos, el sistema DEBERÁ presentar un mensaje de notificación de éxito contextual e informativo:
  - Si el nuevo rol es Arrendador: *"¡Tu rol ahora es Arrendador! Ya puedes publicar propiedades"*.
  - Si el nuevo rol es Arrendatario: *"¡Tu rol ahora es Arrendatario! Ya puedes explorar y solicitar arriendos"*.
- **RF-38.3:** SI el usuario NO contaba previamente con un perfil completo (faltaban datos obligatorios en su rol de origen), ENTONCES el sistema DEBERÁ orientarlo mediante una notificación clara a completar su información personal en el nuevo rol.

### RF-39: Habilitación Inmediata de Permisos y Funcionalidades por Rol
- **RF-39.1:** CUANDO un usuario verificado cambie al rol de Arrendador, el sistema DEBERÁ reconocerlo de forma inmediata como usuario verificado en su nuevo rol, habilitando sin demoras:
  - El acceso a las opciones del menú de usuario que requieren verificación (información personal, notificaciones, etc.).
  - El acceso y operatividad completa en el Panel de Control del Arrendador.
  - La capacidad de publicar y administrar inmuebles.
- **RF-39.2:** CUANDO un usuario verificado cambie al rol de Arrendatario, el sistema DEBERÁ reconocerlo de forma inmediata como usuario verificado, habilitando sin demoras:
  - El distintivo de usuario verificado en la Pantalla de Perfil de Usuario.
  - El acceso al historial de solicitudes de arriendo y postulaciones.
  - El envío de nuevas solicitudes de arrendamiento sin restricciones de perfil incompleto.

### RF-40: Alternancia Bidireccional de Rol en la Pantalla de Perfil de Usuario
- **RF-40.1:** MIENTRAS el usuario tenga asignado el rol de Arrendatario, la Pantalla de Perfil de Usuario DEBERÁ exhibir una opción destacada y visualmente intuitiva para solicitar el cambio a rol de Arrendador (*"Conviértete en Arrendador"*).
- **RF-40.2:** MIENTRAS el usuario tenga asignado el rol de Arrendador, la Pantalla de Perfil de Usuario DEBERÁ exhibir una opción simétrica, clara y accesible para solicitar la alternancia al rol de Arrendatario (*"Cambiar a rol Arrendatario"* o *"Volver a rol Arrendatario"*).
- **RF-40.3:** Al presionar la opción de cambio de rol en cualquiera de los dos sentidos, el sistema DEBERÁ desplegar un diálogo de confirmación explícito que informe al usuario las implicaciones del cambio antes de proceder.
- **RF-40.4:** SI el usuario ya se encuentra en el rol solicitado, el sistema NO DEBERÁ permitir la ejecución de acciones redundantes de cambio de rol.

### RF-41: Precarga de Datos Personales en Pantallas de Formulario
- **RF-41.1:** CUANDO el usuario acceda a la Pantalla de Completar Perfil de Arrendador, el sistema DEBERÁ inicializar los campos del formulario con los valores existentes en el perfil del usuario (provenientes del registro de Arrendador o del registro previo de Arrendatario si estuviese disponible), suprimiendo la necesidad de volver a digitar datos conocidos.
- **RF-41.2:** CUANDO el usuario acceda a la Pantalla de Completar Perfil de Arrendatario, el sistema DEBERÁ inicializar los campos del formulario con los valores existentes en el perfil del usuario (provenientes del registro de Arrendatario o del registro previo de Arrendador si estuviese disponible).
- **RF-41.3:** Al guardar modificaciones en cualquiera de las pantallas de formulario, el sistema DEBERÁ actualizar los datos sin borrar ni corromper información previamente almacenada.

---

## 5. Requisitos No Funcionales (RNF)

- **RNF-23 (Integridad y Prevención de Pérdida de Datos):** La sincronización entre perfiles DEBERÁ ser estrictamente aditiva e idempotente. Bajo ninguna circunstancia una sincronización o cambio de rol podrá sobrescribir datos válidos existentes con valores nulos o cadenas vacías.
- **RNF-24 (Tiempo de Respuesta en Alternancia):** El proceso completo de cambio de rol y sincronización de datos personales DEBERÁ ejecutarse en un tiempo no mayor a dos (2) segundos bajo condiciones de conectividad móvil estándar, mostrando un indicador de progreso no bloqueante durante la transición.
- **RNF-25 (Accesibilidad y Claridad en Diálogos y Avisos):** Todos los diálogos de confirmación, botones de alternancia y notificaciones de éxito o error DEBERÁN contar con descripciones semánticas accesibles para lectores de pantalla y contrastes acordes a las directrices WCAG 2.1 AA.
- **RNF-26 (Consistencia Reactiva en el Estado de la Aplicación):** El cambio de rol y la disponibilidad de los datos sincronizados DEBERÁ propagarse reactivamente en todos los componentes y pantallas activas de la aplicación sin requerir el reinicio ni el cierre de sesión del usuario.

---

## 6. Casos Límite y Manejo de Excepciones

- **CL-32 (Usuario con Perfil Incompleto al Cambiar de Rol):** SI un usuario que aún no ha diligenciado su información personal solicita el cambio de rol, ENTONCES el sistema DEBERÁ actualizar el rol pero mantener el estado de verificación como no verificado, orientando al usuario a la pantalla correspondiente para completar sus datos.
- **CL-33 (Solicitud Repetitiva o Redundante de Cambio de Rol):** SI se invoca un cambio al rol que el usuario ya ostenta activamente, ENTONCES el sistema DEBERÁ ignorar la petición y notificar al usuario que ya se encuentra operando bajo dicho rol sin realizar escrituras innecesarias en el servidor.
- **CL-34 (Fallo de Red o Timeout Durante la Sincronización):** SI ocurre un error de comunicación con el servidor durante el proceso de cambio de rol, ENTONCES el sistema DEBERÁ revertir cualquier cambio transitorio en la interfaz local, mantener al usuario en su rol previo y presentar un mensaje de error claro invitando a reintentar.
- **CL-35 (Edición Posterior de Datos en un Rol Específico):** SI un usuario que ya sincronizó sus datos edita su teléfono o dirección en la pantalla de un rol, ENTONCES el sistema DEBERÁ guardar el cambio y asegurar que la próxima sincronización mantenga la información más actualizada.
- **CL-36 (Preservación de Campos Opcionales Omitidos):** SI el usuario no posee segundo nombre o segundo apellido, ENTONCES la sincronización DEBERÁ gestionar adecuadamente los valores nulos sin generar excepciones ni deformar los nombres completos en la interfaz.
- **CL-37 (Preservación de Reputación Comunitaria):** Al alternar de rol, las calificaciones, estrellas y comentarios históricos recibidos por el usuario DEBERÁN permanecer asociados a su identidad sin sufrir reinicios ni alteraciones.

---

## 7. Criterios de Aceptación (Escenarios EARS / Given-When-Then)

### Escenario 1: Cambio de Rol con Datos Persistentes (Arrendatario a Arrendador)
- **Dado que** soy un usuario registrado y ya completé mi perfil como "Arrendatario" (con nombre, apellidos, tipo de documento, documento, teléfono y dirección).
- **Cuando** accedo a la opción de cambiar mi rol a "Arrendador" dentro de mi Pantalla de Perfil de Usuario y confirmo la acción.
- **Entonces:** El sistema debe actualizar el rol del usuario a "Arrendador".
- **Y además:** Todos mis datos personales (nombre, apellidos, documento, tipo de documento, teléfono y dirección) deben permanecer iguales, cargados y disponibles en mi nuevo rol de Arrendador sin pérdida de información.

### Escenario 2: Evitar Re-entrada de Datos y Alertas Redundantes
- **Dado que** acabo de cambiar mi rol a "Arrendador" y mis datos personales ya estaban completos en el rol de Arrendatario.
- **Cuando** el sistema procesa el cambio y me muestra la Pantalla de Perfil de Usuario.
- **Entonces:** El sistema no debe solicitar que complete campos de información básica nuevamente.
- **Y:** No debo recibir alertas de "campos obligatorios vacíos" ni ser redirigido forzosamente a la pantalla de completar perfil.
- **Y:** Debo visualizar el mensaje de éxito: *"¡Tu rol ahora es Arrendador! Ya puedes publicar propiedades"*.

### Escenario 3: Actualización Inmediata de Permisos y Capacidades por Rol
- **Dado que** el cambio de rol a "Arrendador" ha concluido exitosamente con datos completos.
- **Cuando** accedo a las funciones operativas de la aplicación.
- **Entonces:** El sistema debe habilitar automáticamente las funcionalidades asociadas al rol de "Arrendador" (incluyendo la publicación de inmuebles y el acceso a opciones protegidas de perfil) sin requerir completar el perfil de nuevo.

### Escenario 4: Cambio Simétrico de Rol (Arrendador a Arrendatario)
- **Dado que** soy un usuario con rol de "Arrendador" con perfil completo y verificado.
- **Cuando** accedo a la opción de cambiar mi rol a "Arrendatario" en la Pantalla de Perfil de Usuario y confirmo la acción.
- **Entonces:** El sistema debe actualizar el rol a "Arrendatario" manteniendo intactos todos mis datos personales.
- **Y:** Debo visualizar el mensaje de éxito: *"¡Tu rol ahora es Arrendatario! Ya puedes explorar y solicitar arriendos"*.
- **Y:** Se deben habilitar de inmediato las opciones de postulación y el distintivo de usuario verificado sin pedir datos redundantes.

### Escenario 5: Precarga de Datos en Pantallas de Edición o Completado de Perfil
- **Dado que** cuento con datos personales registrados en el sistema.
- **Cuando** accedo a la Pantalla de Completar Perfil de Arrendador o a la Pantalla de Completar Perfil de Arrendatario.
- **Entonces:** Los campos de primer nombre, segundo nombre, primer apellido, segundo apellido, tipo de documento, número de documento, teléfono y dirección deben aparecer precargados con la información existente.

---

## 8. Fuera de Alcance

1. **Eliminación o borrado permanente de perfiles:** Esta especificación cubre únicamente la sincronización y persistencia de datos personales al cambiar de rol; no incluye mecanismos de supresión de cuentas.
2. **Proceso de verificación documental de antecedentes:** La validación externa de cédulas o antecedentes judiciales no forma parte de este alcance; se sincronizan los datos ya suministrados por el usuario.
3. **Roles especiales administrativos:** Solo se contemplan los roles de usuario final "Arrendatario" y "Arrendador".
4. **Fusión de cuentas distintas:** No se contempla la consolidación de dos cuentas de correo electrónico diferentes en una sola.

---

## 9. Criterios de Finalización (Definition of Done)

Para considerar concluida satisfactoriamente la entrega de esta especificación, deberán cumplirse la totalidad de las siguientes condiciones:
1. **Especificación validada:** Documentos `spec.md`, `plan.md` y `tasks.md` elaborados y alineados con la Constitución 2.1 (sin nombres de archivos técnicos en `spec.md`).
2. **Sincronización bidireccional:** Funcionamiento verificado del cambio de rol de Arrendatario a Arrendador y de Arrendador a Arrendatario con persistencia íntegra de datos personales.
3. **No re-entrada de datos:** Comprobación de que los usuarios verificados no son forzados a completar formularios ni reciben alertas de campos vacíos tras el cambio de rol.
4. **Precarga de formularios:** Inicialización correcta de campos en las pantallas de completar perfil con los datos personales existentes.
5. **Habilitación inmediata de capacidades:** Acceso operativo inmediato a las herramientas del nuevo rol tras la alternancia.
6. **Calidad y Cobertura de Pruebas:**
   - 100% de las pruebas automatizadas (unitarias, de integración y de widgets) aprobadas con salida limpia.
   - 0 advertencias o errores en el análisis estático (`flutter analyze`).
7. **Sincronización en Notion y Git:**
   - Registro de avance y cierre formal de la Historia de Usuario `HU: Persistencia de Datos al Cambiar Rol` (ID: `3ed8442e-3f49-8047-b396-f0e69bed83d6`) en Notion con estado "Finalizado".
   - Commit semántico en la rama `develop` de acuerdo con los estándares de Git del repositorio.
