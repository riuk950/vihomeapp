# Especificación Funcional: Eliminación de Cuenta y Limpieza Integral de Datos

## 1. Visión General y Propósito
El objetivo de esta especificación es permitir que los usuarios autenticados (tanto arrendatarios como arrendadores) puedan solicitar y ejecutar la eliminación definitiva de su cuenta y de todos sus datos personales asociados desde la aplicación móvil. Esta funcionalidad garantiza el cumplimiento de los derechos de privacidad del usuario, las leyes de protección de datos personales y las directrices obligatorias de publicación de aplicaciones en tiendas oficiales (Apple App Store y Google Play Store). Asimismo, asegura que la eliminación retire en cascada toda la información vinculada (publicaciones, solicitudes, calificaciones y perfiles) evitando la existencia de registros huérfanos o inconsistencias en la base de datos.

---

## 2. Historias de Usuario

### HU-45: Acceso Transparente a la Eliminación de Cuenta
* **Como:** usuario registrado y autenticado (arrendatario o arrendador),  
* **Quiero:** encontrar una opción visible y accesible para eliminar mi cuenta dentro de las pantallas de gestión de mi perfil y panel de control,  
* **Para:** ejercer mi derecho al olvido y decidir cuándo dejar de utilizar el servicio de forma definitiva.

### HU-46: Confirmación Segura y Prevención de Borrado Accidental
* **Como:** usuario que pulsa accidentalmente sobre la opción de eliminar cuenta,  
* **Quiero:** que el sistema me presente una advertencia clara sobre las consecuencias irreversibles de la acción antes de proceder,  
* **Para:** tener la oportunidad de cancelar la operación y no perder mi información por un toque involuntario.

### HU-47: Limpieza Integral y Borrado en Cascada
* **Como:** usuario que confirma la eliminación de su cuenta,  
* **Quiero:** que toda mi información personal, inmuebles publicados, solicitudes de arriendo y calificaciones sean eliminadas en su totalidad del sistema,  
* **Para:** tener la certeza de que no queda ningún rastro de mi identidad o actividad almacenada en los servidores.

### HU-48: Finalización de Sesión y Retroalimentación Inmediata
* **Como:** usuario cuya cuenta ha sido eliminada exitosamente,  
* **Quiero:** que mi sesión se cierre de forma automática y el sistema me informe con claridad que el proceso concluyó,  
* **Para:** tener la tranquilidad de que ya no puedo acceder con mis credenciales anteriores y regresar a la vista de bienvenida.

---

## 3. Requerimientos Funcionales

* **RF-52 (Disponibilidad de Opción Destructiva en Perfil de Arrendatario):** El sistema debe desplegar un botón u opción interactiva con estética de advertencia ("Eliminar cuenta") dentro de la vista principal de perfil del arrendatario.
* **RF-53 (Disponibilidad de Opción Destructiva en Panel de Arrendador):** El sistema debe desplegar un botón u opción interactiva con estética de advertencia ("Eliminar cuenta") dentro de la sección de ajustes o menú del panel principal del arrendador.
* **RF-54 (Diálogo Modal de Confirmación Explícita):** Al presionar la opción de eliminación, el sistema debe presentar un diálogo emergente con un mensaje explícito alertando sobre la pérdida permanente de datos personales, inmuebles publicados y solicitudes asociadas, ofreciendo botones claros de "Cancelar" y "Eliminar cuenta".
* **RF-55 (Eliminación en Cascada en el Servidor de Datos):** Al confirmar la solicitud, el sistema debe invocar una operación segura en la plataforma backend que elimine el registro de autenticación del usuario y borre en cascada:
  1. Su información de perfil (general y específica de rol).
  2. Todas las propiedades registradas a su nombre (en caso de arrendador).
  3. Todas las solicitudes de arriendo enviadas o recibidas.
  4. Todas las calificaciones y reseñas emitidas o recibidas.
* **RF-56 (Limpieza de Estado Local y Redirección al Inicio):** Una vez concluida la eliminación en el servidor, el sistema debe limpiar la memoria local, cerrar la sesión activa del usuario y redirigirlo a la pantalla de autenticación o bienvenida, presentando un mensaje de confirmación exitosa.
* **RF-57 (Manejo Resiliente de Fallos de Red):** Si ocurre un error de conectividad o falla en el servicio durante la eliminación, el sistema no debe cerrar la sesión del usuario y debe notificarle con un mensaje comprensible para que pueda reintentarlo.

---

## 4. Requerimientos No Funcionales

* **RNF-35 (Seguridad en la Ejecución Backend):** La operación de eliminación únicamente debe ser ejecutable por el usuario que posee la sesión activa (`auth.uid()`), impidiendo que cualquier usuario elimine datos ajenos.
* **RNF-36 (Consistencia e Integridad Referencial):** La base de datos debe mantener integridad absoluta tras la eliminación; ninguna tabla dependiente debe conservar registros huérfanos con identificadores de usuarios inexistentes.
* **RNF-37 (Cumplimiento de Políticas de Tiendas de Apps):** La funcionalidad debe cumplir a cabalidad con la directriz 5.1.1(v) de Apple App Store y las políticas de datos de usuario de Google Play Store para eliminación de cuentas initiated in-app.
* **RNF-38 (Tiempo de Respuesta y Retroalimentación):** El proceso completo de eliminación y cierre de sesión no debe tomar más de 4 segundos bajo condiciones normales de red móvil, mostrando un indicador de progreso mientras se procesa.

---

## 5. Criterios de Aceptación (Formato EARS)

* **CA-1:** Mientras un usuario autenticado visualice la pantalla de su perfil o su panel de administración, el sistema mostrará visiblemente la acción para eliminar su cuenta con estilo diferenciado de advertencia.
* **CA-2:** Cuando el usuario seleccione la opción "Eliminar cuenta", el sistema mostrará un diálogo de confirmación indicando el impacto irreversible de la acción y solicitando confirmación explícita.
* **CA-3:** Cuando el usuario confirme la eliminación en el diálogo emergente, el sistema ejecutará la limpieza en cascada en la base de datos eliminando el usuario de autenticación, sus perfiles, propiedades, solicitudes y calificaciones.
* **CA-4:** Cuando la eliminación en el servidor finalice exitosamente, el sistema borrará las credenciales almacenadas localmente, cerrará la sesión y redirigirá al usuario a la vista de ingreso mostrando un mensaje de confirmación.
* **CA-5:** Si la comunicación con el servidor falla durante la solicitud de eliminación, el sistema mantendrá la sesión del usuario intacta y presentará un mensaje de error permitiendo reintentar la acción.

---

## 6. Cláusulas de Limitación

* **CL-48:** La acción de eliminación de cuenta es irreversible; una vez confirmada y ejecutada en el servidor, no existirá mecanismo de recuperación de credenciales, publicaciones ni historial previo.
* **CL-49:** Ningún usuario no autenticado o con sesión caducada podrá acceder ni ejecutar la acción de eliminación.
* **CL-50:** El diálogo de confirmación no debe cerrarse automáticamente al tocar fuera de su área mientras la operación de borrado se encuentre en curso.
* **CL-51:** La eliminación de datos no afectará el funcionamiento ni la integridad de las solicitudes o calificaciones de otros usuarios que no estén vinculadas directamente con la cuenta eliminada.
* **CL-52:** Si el usuario decide presionar "Cancelar" en el diálogo de confirmación, el sistema cerrará el diálogo de inmediato sin alterar ningún dato ni suspender la sesión.
