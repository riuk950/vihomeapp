# Especificación Funcional: Sistema de Calificación y Confianza - Ranking de Estrellas (005-vihomeapp-mvp)

## 1. Contexto y Objetivo

En una plataforma de corretaje y arrendamiento inmobiliario, la confianza mutua entre las partes interesadas es el pilar fundamental para concretar acuerdos seguros y satisfactorios. Los arrendatarios requieren verificar la seriedad y reputación de los propietarios antes de comprometer sus recursos y formalizar un contrato, mientras que los arrendadores necesitan constatar el cumplimiento y responsabilidad de los postulantes antes de entregar la tenencia de sus inmuebles.

Previamente, la plataforma carecía de un mecanismo objetivo y cuantificable para evaluar la experiencia de las partes tras culminar un proceso. Además, en los mercados abiertos existe el riesgo constante de reseñas fraudulentas o calificaciones por frustración (cuando una postulación no prospera), lo que distorsiona la reputación de los usuarios.

El objetivo de esta especificación es formalizar el **Sistema de Calificación y Confianza**, estableciendo un modelo de evaluación basado en estrellas (1 a 5) y comentarios opcionales vinculado estrictamente a **transacciones reales finalizadas**. Asimismo, se define la reputación centrada en la **persona (usuario)**, el cálculo automático de promedios, la visualización en perfiles y anuncios de inmuebles, y una regla de confianza inicial para usuarios verificados, garantizando un ecosistema transparente, seguro y libre de spam.

---

## 2. Perfiles de Usuario

- **Arrendador (Propietario / Administrador):** Usuario que oferta inmuebles en la plataforma y, tras haber completado exitosamente un proceso de solicitud o entrega de la propiedad, desea calificar el comportamiento y cumplimiento del arrendatario, así como exhibir su propio puntaje de reputación para atraer postulantes de calidad.
- **Arrendatario (Inquilino / Postulante):** Usuario que busca viviendas y, tras haber completado satisfactoriamente el proceso de arrendamiento con un arrendador, desea evaluar la atención, veracidad y trato recibido, además de consultar la calificación del propietario en los anuncios para tomar decisiones informadas.

---

## 3. Historias de Usuario

- **HU-22 (Calificación del Arrendatario al Arrendador):** Como Arrendatario que ha completado exitosamente una solicitud de arrendamiento con un propietario, quiero otorgarle una puntuación de 1 a 5 estrellas y un comentario opcional, para valorar el servicio recibido y aportar a la reputación comunitaria de la plataforma.
- **HU-23 (Calificación del Arrendador al Arrendatario):** Como Arrendador que ha aprobado y culminado exitosamente una solicitud de arrendamiento con un postulante, quiero calificar su cumplimiento con una puntuación de 1 a 5 estrellas y un comentario opcional, para certificar su seriedad frente a futuros propietarios.
- **HU-24 (Visualización de Reputación en Perfiles y Anuncios):** Como usuario de la aplicación, quiero visualizar el promedio de estrellas y el número de reseñas de cualquier usuario o propietario de un inmueble (tanto en su perfil como en la vista previa y detalle del anuncio), para validar su nivel de confianza antes de iniciar un contacto o postulación.
- **HU-25 (Puntaje Inicial de Confianza para Usuarios Verificados):** Como usuario nuevo con estado verificado, quiero contar con un nivel de confianza inicial de 3.0 estrellas mientras recibo mis primeras calificaciones reales, para disponer de credibilidad inicial sin perjudicar la transparencia de las reseñas futuras.

---

## 4. Requisitos Funcionales (RF)

### RF-23: Habilitación y Permisos de Calificación
- **RF-23.1:** El sistema DEBERÁ habilitar la opción de calificar a la contraparte ÚNICAMENTE cuando la solicitud de arrendamiento vinculada alcance un estado final exitoso (`Aceptada` o `Finalizada`).
- **RF-23.2:** El sistema DEBERÁ permitir exactamente una (1) calificación por cada usuario participante en dicha solicitud (el arrendatario califica al arrendador y el arrendador califica al arrendatario).
- **RF-23.3:** El sistema DEBERÁ impedir que un usuario se califique a sí mismo bajo cualquier circunstancia.
- **RF-23.4:** SI una solicitud se encuentra en estado `Pendiente`, `Rechazada` o `Cancelada`, ENTONCES el sistema DEBERÁ mantener completamente bloqueada e inaccesible la opción de calificar para ambas partes.
- **RF-23.5:** SI un usuario intenta emitir una calificación sobre una solicitud en la cual no figura como arrendador ni como arrendatario titular, ENTONCES el sistema DEBERÁ denegar la operación e informar que no cuenta con autorización.

### RF-24: Formulario y Registro de Calificación
- **RF-24.1:** CUANDO el usuario acceda a la acción de calificar, el sistema DEBERÁ presentar un selector interactivo de puntuación obligatoria de 1 a 5 estrellas enteras.
- **RF-24.2:** El sistema DEBERÁ proporcionar un campo de texto opcional para comentarios de retroalimentación sobre la experiencia, con una longitud máxima permitida de 500 caracteres.
- **RF-24.3:** CUANDO el usuario envíe una calificación válida (puntuación seleccionada de 1 a 5 estrellas y comentario dentro de los límites), el sistema DEBERÁ registrar la calificación de forma permanente e inmutable.
- **RF-24.4:** SI el usuario intenta enviar la calificación sin haber seleccionado una puntuación de estrellas, ENTONCES el sistema DEBERÁ impedir el envío y resaltar la obligatoriedad de asignar una puntuación entre 1 y 5.
- **RF-24.5:** SI el comentario ingresado supera los 500 caracteres, ENTONCES el sistema DEBERÁ impedir el envío e indicar la cantidad de caracteres excedidos.
- **RF-24.6:** SI una calificación ya fue enviada y registrada para una solicitud específica, ENTONCES el sistema DEBERÁ bloquear envíos posteriores para ese mismo usuario y solicitud, deshabilitando la opción de edición o eliminación.

### RF-25: Cálculo y Actualización de Reputación
- **RF-25.1:** El sistema DEBERÁ asociar la reputación directamente a la persona (perfil de usuario evaluado).
- **RF-25.2:** CUANDO se registre una nueva calificación válida, el sistema DEBERÁ recalcular de forma automática e inmediata el promedio general de estrellas del usuario evaluado.
- **RF-25.3:** El sistema DEBERÁ calcular el promedio aritmético de las puntuaciones recibidas redondeado a un (1) dígito decimal (ejemplo: 4.8 / 5.0).
- **RF-25.4:** El sistema DEBERÁ mantener un contador acumulativo exacto del número total de calificaciones reales recibidas por cada usuario.

### RF-26: Visualización de Reputación en Perfiles y Anuncios
- **RF-26.1:** MIENTRAS el usuario consulte el perfil público de un Arrendador o Arrendatario que posea calificaciones reales, el sistema DEBERÁ exhibir:
  - El promedio numérico de estrellas (ejemplo: `4.8`).
  - La representación visual gráfica de estrellas correspondientes al puntaje.
  - El número total de calificaciones recibidas en formato descriptivo (ejemplo: `Basado en 12 reseñas`).
- **RF-26.2:** MIENTRAS se visualice una tarjeta de inmueble en la vista previa del mapa o en el listado general de propiedades, el sistema DEBERÁ mostrar de forma visible la calificación de estrellas y el promedio del Arrendador propietario del inmueble.
- **RF-26.3:** MIENTRAS se consulte la pantalla de detalle de una propiedad, el sistema DEBERÁ incluir en la sección de información del anfitrión/propietario el promedio de estrellas del Arrendador y el contador total de reseñas.
- **RF-26.4:** DONDE el usuario visualice un comentario registrado por otro usuario, el sistema DEBERÁ exhibir el nombre del autor, la fecha relativa o absoluta de publicación, la puntuación otorgada (1 a 5 estrellas) y el texto del comentario.

### RF-27: Manejo de Usuarios sin Reseñas y Confianza Inicial
- **RF-27.1:** SI un usuario no verificado no ha recibido ninguna calificación, ENTONCES el sistema DEBERÁ exhibir un estado neutral indicando: `Sin calificaciones aún`.
- **RF-27.2:** SI un usuario posee estado verificado y no ha recibido calificaciones reales de transacciones, ENTONCES el sistema DEBERÁ exhibir un puntaje inicial visual de `3.0 ★` acompañado del texto o distintivo indicativo: `Puntaje inicial de confianza`.
- **RF-27.3:** CUANDO un usuario verificado reciba su primera calificación real producto de una solicitud completada, el sistema DEBERÁ calcular y mostrar su promedio fundamentado al 100% sobre las calificaciones reales recibidas, reemplazando el puntaje inicial provisional.

### RF-28: Manejo de Errores y Resiliencia en la Emisión
- **RF-28.1:** SI ocurre una interrupción de red o fallo en el servicio durante el envío de la calificación, ENTONCES el sistema DEBERÁ presentar un mensaje descriptivo del fallo conservando intactos la puntuación seleccionada y el comentario escrito para permitir el reintento inmediato.
- **RF-28.2:** SI el usuario presiona repetidamente el botón de envío mientras una solicitud de calificación está en curso, ENTONCES el sistema DEBERÁ deshabilitar el botón de acción para impedir registros duplicados concurrentes.

---

## 5. Requisitos No Funcionales (RNF)

- **RNF-15 (Integridad e Inmutabilidad de las Reseñas):** Una vez registrada la calificación, los datos de puntuación, comentario y autoría DEBERÁN ser estrictamente inalterables por parte del emisor o del receptor para garantizar la fidelidad del historial.
- **RNF-16 (Tiempo de Respuesta y Visualización):** La consulta y renderizado del promedio de estrellas y contador de reseñas en perfiles y tarjetas de propiedades DEBERÁ efectuarse en un tiempo no mayor a 150 milisegundos tras la disponibilidad de los datos.
- **RNF-17 (Accesibilidad de Componentes de Calificación):** La representación visual de estrellas DEBERÁ incluir etiquetas semánticas para tecnologías de asistencia y lectores de pantalla (ejemplo: "Calificación 4.5 de 5 estrellas"), cumpliendo con las directrices WCAG 2.1 nivel AA.
- **RNF-18 (Privacidad y Seguridad):** El sistema DEBERÁ impedir que usuarios ajenos a la transacción tengan acceso a formularios de calificación no autorizados, validando rigurosamente la titularidad de las partes involucradas.

---

## 6. Casos Límite y Manejo de Excepciones

- **CL-19 (Solicitudes Canceladas o Rechazadas):** SI una solicitud de arrendamiento culmina en estado `Rechazada` o `Cancelada`, ENTONCES el sistema DEBERÁ bloquear permanentemente la acción de calificar, evitando calificaciones por despecho o represalias no vinculadas a una transacción formalizada.
- **CL-20 (Doble Envío Concurrente de Calificación):** SI dos peticiones de calificación para una misma solicitud son disparadas en paralelo por el mismo usuario, ENTONCES el sistema DEBERÁ admitir únicamente la primera transacción y descartar la segunda sin generar inconsistencias en el promedio.
- **CL-21 (Comentario con Texto en Blanco o Espacios Vacíos):** SI el usuario ingresa únicamente espacios en blanco o saltos de línea en el campo de comentario, ENTONCES el sistema DEBERÁ registrar la calificación considerando el comentario como vacío/ausente, almacenando únicamente la puntuación numérica obligatoria.
- **CL-22 (Intento de Autoevaluación):** SI por alguna anomalía en los datos un usuario figura simultáneamente como arrendador y solicitante de la misma propiedad, ENTONCES el sistema DEBERÁ bloquear la emisión de la calificación indicando que la autocalificación no está permitida.
- **CL-23 (Transición de Estado Verificado al Recibir Primera Reseña):** SI un usuario verificado tiene una puntuación visual provisional de 3.0 ★ y recibe su primera calificación real de 1 estrella (o de 5 estrellas), ENTONCES el sistema DEBERÁ reflejar de forma exacta e inmediata el valor real (1.0 ★ o 5.0 ★, según corresponda) sustentado en `1 reseña`, retirando la etiqueta de puntaje provisional.

---

## 7. Fuera de Alcance

1. **Flujo de verificación documental de identidad o títulos:** En este MVP no se implementa el proceso de carga, análisis, OCR o validación de documentos de identidad o certificados de tradición; el sistema asume la existencia del estado de verificación de usuario para aplicar el puntaje base inicial.
2. **Edición o eliminación de reseñas:** Los usuarios no podrán modificar la puntuación ni el comentario una vez enviados, ni borrarlos posteriormente.
3. **Calificación física independiente del inmueble:** No se evalúa el inmueble como entidad separada; la calificación pertenece exclusivamente a la persona (Arrendador o Arrendatario).
4. **Respuestas públicas o hilos de réplica:** No se contempla la opción de que el usuario calificado responda públicamente a las reseñas dejadas en su perfil.
5. **Reporte o moderación comunitaria de comentarios:** No se incluye sistema de denuncias o flags comunitarios para solicitar el retiro de una reseña en este MVP.
6. **Calificación en solicitudes inconclusas o visitas:** No se permite calificar tras una simple visita presencial o contacto por mensaje si la solicitud no fue formalmente aprobada o finalizada.

---

## 8. Criterios de Finalización (Definition of Done)

1. Todos los requisitos funcionales (RF-23 a RF-28) y casos límite (CL-19 a CL-23) están redactados y validados formalmente bajo la sintaxis EARS en español.
2. Quedan explícitamente establecidas las reglas de negocio para los estados de usuario: no calificado sin verificar (`Sin calificaciones aún`), verificado sin reseñas (`3.0 ★ Puntaje inicial de confianza`) y calificado (`X.X ★ basado en N reseñas`).
3. Se especifica con claridad que la reputación corresponde al usuario y que los anuncios y mapas exhiben la reputación de su respectivo propietario.
4. El documento excluye terminología de arquitectura, frameworks, dependencias y nombres de archivos de código fuente, centrándose exclusivamente en el **QUÉ** y el **POR QUÉ**.

---

## 9. Dudas Abiertas

- `[NECESITA ACLARACIÓN]` **Pestaña o modal dedicado para lectura de opiniones completas:** Confirmar si en la vista de detalle de propiedad o perfil de usuario se requiere un listado deslizable/paginado con el texto completo de todas las reseñas de otros usuarios, o si en el MVP basta con mostrar el promedio y contador global junto a los comentarios más recientes.
- `[NECESITA ACLARACIÓN]` **Ventana de tiempo máxima para calificar:** Determinar si un usuario tiene un tiempo límite tras completarse la solicitud (por ejemplo, 30 días calendario) para emitir su calificación, o si la opción permanece abierta de forma indefinida hasta que decida usarla.
