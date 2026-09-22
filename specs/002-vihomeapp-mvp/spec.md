# Especificación Funcional: Mitigación de Deuda Técnica y Calidad Integral (002-vihomeapp-mvp)

## 1. Contexto y Objetivo
Tras la consolidación de la suite de pruebas unitarias de la lógica de negocio pura y modelos en la entrega inicial (001-vihomeapp-mvp), se identificaron brechas de calidad asociadas a:
1. Resiliencia y aislamiento de la sincronización de eventos en tiempo real ante conexiones inestables.
2. Definición formal de las reglas visuales, validaciones de longitud/formato y estados interactivos de los formularios centrales (Creación/Edición de Propiedad, Solicitud Financiera y Suscripciones).
3. Manejo predecible de interrupciones de red y recuperación de compras.

El objetivo de esta especificación es formalizar el comportamiento funcional, los estados de interacción y los criterios de aceptación de los flujos interactivos, garantizando una experiencia de usuario fluida, predecible y verificable.

---

## 2. Perfiles de Usuario

- **Arrendador (Propietario):** Usuario que interactúa con los formularios interactivos de publicación/edición de inmuebles, revisa solicitudes con comprobantes en tiempo real y gestiona su suscripción con retroalimentación inmediata de compra y restauración.
- **Arrendatario (Inquilino):** Usuario que completa formularios de solicitud de arrendamiento, adjunta documentos financieros con validación de formato/peso en pantalla y recibe actualizaciones de estado en tiempo real.
- **Visitante / No autenticado:** Usuario que explora el catálogo público sin sesión activa.

---

## 3. Historias de Usuario

- **HU-08 (Validación Interactiva en Creación de Propiedad):** Como arrendador, quiero que el formulario de creación de inmueble valide mis datos en tiempo real (longitud de texto, precios positivos y mínimo una foto) y bloquee el envío durante la carga, para evitar publicaciones incompletas o duplicadas.
- **HU-09 (Edición Segura de Propiedad):** Como arrendador, quiero editar los datos de mis propiedades publicadas asegurando que nunca queden sin fotografías activas, para mantener la calidad del catálogo.
- **HU-10 (Cargue y Validación Visual de Solicitud Financiera):** Como arrendatario, quiero ingresar mis ingresos formateados en moneda, seleccionar mi comprobante con validación de peso y ver el estado de carga antes de enviar la postulación, para tener certeza del envío exitoso.
- **HU-11 (Escucha en Tiempo Real y Resiliencia de Red):** Como usuario (arrendador o arrendatario), quiero recibir actualizaciones instantáneas de mis postulaciones e inmuebles cuando haya conectividad, y que la aplicación continúe funcionando fluidamente sin bloqueos cuando la conexión se interrumpa.
- **HU-12 (Gestión Interactiva de Suscripciones y Recuperación Automática):** Como arrendador, quiero tener botones claros para comprar o restaurar suscripciones con estados visuales de espera y recuperación automática al iniciar la app, para entender el estado de mi cuenta en todo momento.

---

## 4. Requisitos Funcionales (RF)

### RF-08: Validación y Comportamiento del Formulario de Creación de Inmuebles
- **RF-08.1:** MIENTRAS el arrendador complete el formulario de creación de propiedad, el sistema DEBERÁ validar que el título tenga entre 5 y 80 caracteres, la descripción entre 10 y 1.000 caracteres, el precio sea un número entero positivo mayor a cero y se haya seleccionado la ciudad y el tipo de inmueble.
- **RF-08.2:** CUANDO el arrendador seleccione fotografías de su galería (hasta un máximo de 10 fotos), el sistema DEBERÁ mostrar una previsualización interactiva de las imágenes seleccionadas con opción para removerlas individualmente.
- **RF-08.3:** SI el arrendador presiona el botón de publicar sin haber adjuntado al menos una (1) fotografía válida, ENTONCES el sistema DEBERÁ bloquear la acción, resaltar visualmente el selector de fotos y presentar un mensaje de advertencia indicando que se requiere al menos una imagen.
- **RF-08.4:** CUANDO se inicie el proceso de guardado y subida de archivos, el sistema DEBERÁ inhabilitar inmediatamente el botón de envío y presentar un indicador visual de progreso hasta que finalice la operación.

### RF-09: Edición Segura y Mantenimiento de Inmuebles
- **RF-09.1:** CUANDO el arrendador abra la pantalla de edición de un inmueble existente, el sistema DEBERÁ precargar todos los valores y fotos actuales de la propiedad.
- **RF-09.2:** SI durante la edición el arrendador intenta eliminar la última fotografía existente sin haber seleccionado una nueva imagen de reemplazo, ENTONCES el sistema DEBERÁ impedir la eliminación y advertir que todo inmueble requiere mínimo una fotografía.
- **RF-09.3:** CUANDO el arrendador guarde los cambios de edición exitosamente, el sistema DEBERÁ retornar a la vista de detalle o listado y reflejar los datos actualizados de forma inmediata.

### RF-10: Formulario Interactivo de Solicitud Financiera
- **RF-10.1:** MIENTRAS el arrendatario digite sus ingresos mensuales, el sistema DEBERÁ formatear el campo numérico en tiempo real con separadores de miles (formato `$ 2.500.000`) y bloquear el ingreso de caracteres no numéricos, valores negativos o cero.
- **RF-10.2:** CUANDO el arrendatario seleccione un archivo de comprobante (PDF, JPG, PNG), el sistema DEBERÁ mostrar el nombre del archivo seleccionado y su tamaño estimado en pantalla.
- **RF-10.3:** SI el archivo seleccionado excede el tamaño máximo permitido de 10 MB, ENTONCES el sistema DEBERÁ rechazar el archivo y solicitar al usuario un documento más liviano.
- **RF-10.4:** CUANDO el envío de la postulación culmine con éxito, el sistema DEBERÁ mostrar un diálogo o pantalla de confirmación exitosa con la opción de regresar al detalle del inmueble o al historial de solicitudes.

### RF-11: Resiliencia de Reactividad en Tiempo Real y Sincronización
- **RF-11.1:** MIENTRAS exista conexión a internet activa y una sesión de usuario iniciada, el sistema DEBERÁ escuchar en segundo plano las inserciones de nuevas solicitudes para el arrendador y las actualizaciones de estado para el arrendatario.
- **RF-11.2:** SI la conexión a internet se pierde mientras se escucha el canal en tiempo real, ENTONCES el sistema DEBERÁ mantener en pantalla los últimos datos conocidos sin interrumpir la navegación del usuario ni emitir excepciones no controladas.
- **RF-11.3:** CUANDO la conexión a internet se restablezca tras una interrupción, el sistema DEBERÁ reconectar automáticamente la escucha en intervalos progresivos (2s, 4s, 8s hasta un máximo de 30s) y refrescar la lista de solicitudes.
- **RF-11.4:** CUANDO un usuario cierre su sesión activa, el sistema DEBERÁ cancelar inmediatamente todas las escuchas de eventos en tiempo real asociadas a su cuenta.

### RF-12: Experiencia Interactiva de Suscripciones y Restauración de Compras
- **RF-12.1:** CUANDO el usuario presione el botón de compra o restauración de suscripción, el sistema DEBERÁ mostrar de forma inmediata (en menos de 100 ms) un diálogo modal bloqueante con indicador visual de espera.
- **RF-12.2:** CUANDO la pasarela de pagos confirme la transacción y se valide el recibo de compra, el sistema DEBERÁ actualizar el estado a premium en la interfaz, cerrar el diálogo de espera y presentar una confirmación de éxito.
- **RF-12.3:** SI el usuario cancela voluntariamente el flujo de compra en la pasarela de la tienda de aplicaciones, ENTONCES el sistema DEBERÁ cerrar el diálogo de espera y retornar a la pantalla de planes sin desplegar mensajes de error.
- **RF-12.4:** SI ocurre un fallo durante el procesamiento (fondos insuficientes, problemas de red o tienda no disponible), ENTONCES el sistema DEBERÁ mostrar un mensaje descriptivo con la causa exacta y habilitar las opciones de reintentar o restaurar compras.
- **RF-12.5:** CUANDO la aplicación se inicie con un usuario autenticado, el sistema DEBERÁ consultar automáticamente el estado de suscripción vigente para sincronizar los permisos de publicación y la supresión de anuncios.

---

## 5. Requisitos No Funcionales (RNF)

- **RNF-05 (Aislamiento y Verificabilidad):** Todos los componentes de interacción, validación de formularios y suscripción deben diseñarse para ser completamente verificables de forma automatizada sin dependencia obligatoria de servicios de backend externos en pruebas.
- **RNF-06 (Feedback Visual Inmediato):** Toda acción del usuario (pulsación de botones, selección de archivos, envío de formularios) debe reflejar un cambio visual de respuesta en menos de 100 ms.
- **RNF-07 (Preservación de Estado en Formularios):** Las pantallas de formulario deben retener la totalidad de los datos digitados por el usuario ante cambios de orientación de pantalla o pausas breves de la aplicación.

---

## 6. Casos Límite y Manejo de Excepciones

- **CL-05:** SI el arrendador intenta ingresar un precio de alquiler con valor 0 o negativo, ENTONCES el sistema DEBERÁ marcar el campo en rojo y deshabilitar el botón de publicar.
- **CL-06:** SI el arrendatario intenta presionar el botón de envío mientras el archivo adjunto aún se encuentra en proceso de subida, ENTONCES el sistema DEBERÁ mantener el botón inhabilitado hasta que la carga finalice exitosamente.
- **CL-07:** SI ocurre un error de conectividad durante la subida múltiple de fotografías de una propiedad, ENTONCES el sistema DEBERÁ detener la publicación, notificar el fallo de conexión y mantener todas las imágenes seleccionadas y los campos digitados para permitir el reintento.
- **CL-08:** SI el archivo seleccionado está dañado o protegido con contraseña y no puede ser procesado, ENTONCES el sistema DEBERÁ rechazar el archivo inmediatamente tras la selección y solicitar un documento legible sin protección.
- **CL-09:** SI la tienda de aplicaciones reporta que no hay productos disponibles o la API de compras no responde, ENTONCES el sistema DEBERÁ informar amigablemente al arrendador que el servicio de pagos no se encuentra disponible temporalmente.

---

## 7. Fuera de Alcance

- Pasarela de cobros recurrentes ajena a las tiendas oficiales de aplicaciones (Google Play / Apple App Store).
- Editor avanzado de retoque o recorte de fotografías dentro de la aplicación.
- Compresión o conversión de formatos de documentos PDF en el cliente.

---

## 8. Criterios de Finalización (Definition of Done)

1. Todos los requisitos funcionales (RF-08 a RF-12) y casos límite (CL-05 a CL-09) están formalizados bajo la notación EARS.
2. Se han eliminado todas las ambigüedades de formato (moneda, longitud de texto, intervalos de reconexión).
3. Se han resuelto las contradicciones entre la inhabilitación de botones y acciones asíncronas concurrentes.
4. El documento cumple estrictamente la constitución del proyecto (enfoque exclusivo en el QUÉ y el POR QUÉ).

---

## 9. Dudas Abiertas

- `[NECESITA ACLARACIÓN]` **Acción ante restauración de compras sin historial:** Confirmar si cuando un usuario presiona "Restaurar Compras" y no tiene transacciones registradas, se le muestra un mensaje informativo de "No se encontraron suscripciones previas para esta cuenta" o si simplemente se actualiza el estado a no premium.
