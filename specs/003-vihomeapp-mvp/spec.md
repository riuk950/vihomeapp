# Especificación Funcional: Formularios Independientes de Solicitud de Arrendamiento (003-vihomeapp-mvp)

## 1. Contexto y Objetivo
En las versiones iniciales de la plataforma, el proceso de postulación a un arrendamiento utilizaba un formulario único y genérico enfocado principalmente en la solvencia económica base. Sin embargo, las necesidades de información de un propietario varían sustancialmente según la naturaleza y destino del inmueble:
- Un inmueble residencial completo requiere evaluar la composición del núcleo familiar, el aforo y la tenencia de mascotas para asegurar la convivencia y conservación del espacio.
- Una habitación o espacio individual requiere verificar la actividad principal del postulante (trabajo o estudio) y, en caso de personas menores de edad, los datos de contacto y respaldo de sus padres o acudientes legales.
- Un inmueble comercial demanda información corporativa, identificación fiscal y el giro o actividad económica que se desarrollará en el lugar.

El objetivo de esta especificación es formalizar el comportamiento funcional, los criterios de validación interactiva y las reglas de presentación de **formularios contextuales e independientes** de solicitud de arrendamiento adaptados a cada categoría de inmueble, garantizando que el arrendador reciba datos pertinentes para su evaluación y que el arrendatario experimente un proceso de postulación guiado, claro y confiable.

---

## 2. Perfiles de Usuario

- **Arrendatario (Inquilino postulante):** Usuario registrado que busca postularse formalmente a un inmueble, diligenciando un formulario específico acorde con el tipo de propiedad seleccionada.
- **Arrendador (Propietario / Administrador):** Usuario que recibe, consulta y evalúa las postulaciones recibidas, visualizando los datos contextuales organizados según la tipología del inmueble ofertado.

---

## 3. Historias de Usuario

- **HU-13 (Formularios Contextuales de Postulación):** Como arrendatario, quiero que la solicitud de arrendamiento me presente preguntas acordes con el tipo de inmueble que deseo alquilar (familiar, individual o comercial), para no responder preguntas irrelevantes y proporcionar la información que el propietario realmente necesita.
- **HU-14 (Postulación a Vivienda Residencial Familiar):** Como arrendatario interesado en una casa, apartamento o finca, quiero registrar cuántas personas vivirán conmigo, cómo está conformado mi núcleo familiar y si poseo mascotas, para que el propietario conozca nuestro perfil de convivencia.
- **HU-15 (Postulación a Habitación y Respaldo para Menores):** Como arrendatario interesado en una habitación o apartaestudio, quiero registrar mi ocupación y lugar de estudio o trabajo, y en caso de ser menor de edad, ingresar los datos de mis acudientes para formalizar el respaldo de mi postulación.
- **HU-16 (Postulación a Inmuebles Comerciales):** Como arrendatario interesado en un local, oficina o bodega, quiero ingresar los datos de mi negocio, razón social, NIT y actividad económica prevista, para demostrar la idoneidad y legalidad comercial de mi proyecto.
- **HU-17 (Evaluación Contextual de Solicitudes):** Como arrendador, quiero revisar las solicitudes recibidas viendo claramente la información específica del tipo de inmueble postulado (núcleo familiar, ocupación/acudiente o datos comerciales), para tomar decisiones de aprobación informadas.

---

## 4. Requisitos Funcionales (RF)

### RF-13: Detección y Enrutamiento Automático del Formulario Contextual
- **RF-13.1:** CUANDO el arrendatario presione el botón de postulación o solicitud desde el detalle de una propiedad, el sistema DEBERÁ identificar la categoría del inmueble y desplegar automáticamente la plantilla de formulario correspondiente sin requerir selección manual del tipo de solicitud.
- **RF-13.2:** El sistema DEBERÁ clasificar los inmuebles en tres categorías de formulario:
  - **Categoría Residencial Familiar:** Aplica para Casas, Apartamentos y Fincas.
  - **Categoría Individual / Habitación:** Aplica para Habitaciones y Apartaestudios.
  - **Categoría Comercial:** Aplica para Locales, Oficinas y Bodegas.
- **RF-13.3:** MIENTRAS el arrendatario complete cualquiera de los tres formularios, el sistema DEBERÁ conservar los campos base universales de la solicitud (ingresos mensuales formateados y selector de comprobante financiero).

### RF-14: Formulario y Reglas para Inmuebles Residenciales Familiares
- **RF-14.1:** MIENTRAS el arrendatario diligencie la solicitud para un inmueble residencial familiar, el sistema DEBERÁ exigir de forma obligatoria el número total de ocupantes (entero positivo mayor o igual a 1).
- **RF-14.2:** MIENTRAS el arrendatario diligencie la solicitud residencial familiar, el sistema DEBERÁ exigir una descripción del núcleo familiar con una longitud mínima de 10 caracteres y máxima de 500 caracteres.
- **RF-14.3:** CUANDO el arrendatario indique que posee mascotas mediante la selección "Tiene mascotas: Sí", el sistema DEBERÁ desplegar un campo de texto obligatorio para describir el tipo y cantidad de mascotas (mínimo 3 caracteres y máximo 150 caracteres).
- **RF-14.4:** SI el arrendatario selecciona "Tiene mascotas: No", ENTONCES el sistema DEBERÁ ocultar el campo de detalle de mascotas y no exigir información adicional al respecto.

### RF-15: Formulario y Reglas para Inmuebles Individuales / Habitaciones
- **RF-15.1:** MIENTRAS el arrendatario diligencie la solicitud para una habitación o apartaestudio, el sistema DEBERÁ solicitar de forma obligatoria su ocupación principal (Estudiante, Empleado o Trabajador Independiente) y el nombre de la institución educativa o empresa donde desempeña su actividad (mínimo 3 y máximo 100 caracteres).
- **RF-15.2:** MIENTRAS el arrendatario complete la solicitud individual, el sistema DEBERÁ incluir una pregunta obligatoria sobre minoría de edad ("¿El solicitante es menor de edad?: Sí / No").
- **RF-15.3:** SI el solicitante marca "Es menor de edad: Sí", ENTONCES el sistema DEBERÁ desplegar de forma obligatoria la sección de información del acudiente o responsable, exigiendo:
  - Nombre completo del acudiente (mínimo 5 y máximo 80 caracteres alfabéticos).
  - Número telefónico de contacto del acudiente (formato numérico válido de 10 dígitos).
  - Parentesco o relación legal (ejemplo: Padre, Madre, Tutor legal).
- **RF-15.4:** SI el solicitante marca "Es menor de edad: No", ENTONCES el sistema DEBERÁ mantener oculta la sección de datos del acudiente y no exigir su diligenciamiento.

### RF-16: Formulario y Reglas para Inmuebles Comerciales
- **RF-16.1:** MIENTRAS el arrendatario diligencie una solicitud para un inmueble comercial, el sistema DEBERÁ exigir de forma obligatoria el nombre comercial o razón social de la empresa o negocio (mínimo 3 y máximo 100 caracteres).
- **RF-16.2:** MIENTRAS el arrendatario diligencie una solicitud comercial, el sistema DEBERÁ exigir de forma obligatoria el NIT o documento de identificación tributaria/empresarial (mínimo 6 y máximo 20 caracteres alfanuméricos).
- **RF-16.3:** MIENTRAS el arrendatario diligencie una solicitud comercial, el sistema DEBERÁ exigir la descripción detallada de la actividad económica y el uso proyectado del inmueble (mínimo 10 y máximo 500 caracteres).

### RF-17: Visualización y Evaluación de Solicitudes para el Arrendador
- **RF-17.1:** CUANDO el arrendador consulte el detalle de una solicitud recibida, el sistema DEBERÁ presentar una tarjeta o bloque informativo contextual acorde con la categoría del inmueble:
  - Para solicitudes residenciales: Bloque "Composición Familiar" detallando número de personas, descripción del núcleo familiar y presencia/detalle de mascotas.
  - Para solicitudes individuales: Bloque "Ocupación y Solicitante" detallando profesión/estudio, entidad y, si aplica, una sección destacada con los datos del acudiente responsable.
  - Para solicitudes comerciales: Bloque "Información Comercial" detallando razón social, NIT y actividad económica proyectada.
- **RF-17.2:** El sistema DEBERÁ exhibir estos bloques contextuales de manera integrada y armónica junto a los datos económicos base (ingresos certificados y comprobante adjunto) previamente capturados.

---

## 5. Requisitos No Funcionales (RNF)

- **RNF-08 (Inmediatez Visual y Reactividad):** Toda visualización condicional de campos (como la aparición de campos de acudiente al seleccionar menor de edad o la especificación de mascotas) DEBERÁ reaccionar en pantalla en un tiempo menor a 100 ms tras la acción del usuario.
- **RNF-09 (Preservación de Estado ante Interrupciones):** Si ocurre un error de red durante el envío de la postulación o la pantalla cambia de orientación, el sistema DEBERÁ retener intactos el 100% de los datos diligenciados y el archivo seleccionado, permitiendo el reintento inmediato sin reiniciar el formulario.
- **RNF-10 (Accesibilidad y Claridad de Errores):** Cada campo requerido no completado o con formato inválido DEBERÁ ser resaltado visualmente con un mensaje de retroalimentación explícito en español junto al control correspondiente.

---

## 6. Casos Límite y Manejo de Excepciones

- **CL-10 (Número de Ocupantes Inválido):** SI el arrendatario ingresa un valor de 0, negativo o no numérico en el campo de número de personas en una solicitud residencial, ENTONCES el sistema DEBERÁ marcar el campo en estado de error y deshabilitar el botón de envío.
- **CL-11 (Inconsistencia en Datos de Acudiente):** SI el solicitante marca que es menor de edad pero deja incompleto el teléfono del acudiente (menos de 10 dígitos) o el nombre del responsable, ENTONCES el sistema DEBERÁ bloquear el envío e indicar visualmente cuáles campos del acudiente faltan por completar.
- **CL-12 (Omisión de Información de Mascotas):** SI el solicitante marca "Tiene mascotas: Sí" y deja en blanco la descripción de las mascotas, ENTONCES el sistema DEBERÁ impedir la postulación hasta que se especifique el tipo o cantidad de animales.
- **CL-13 (Pérdida de Conectividad en el Envío):** SI se pierde la conexión a internet al presionar enviar, ENTONCES el sistema DEBERÁ informar al usuario del fallo de conectividad mediante un mensaje flotante o diálogo amigable, manteniendo habilitada la opción de reintentar con todos los datos preservados.
- **CL-14 (Propiedad Sin Categoría Asignada):** SI una propiedad no posee una categoría claramente asignada en el catálogo, ENTONCES el sistema DEBERÁ aplicar por defecto el formulario Residencial Familiar para garantizar que la solicitud siempre cuente con información de aforo y convivencia.

---

## 7. Fuera de Alcance

1. **Formularios personalizados por propietario:** Los arrendadores no podrán agregar, eliminar ni modificar las preguntas o campos de las solicitudes; el sistema asigna de forma estricta y automática una de las 3 plantillas estandarizadas.
2. **Validación automática externa de identificación tributaria:** No se realizarán consultas en tiempo real a bases de datos fiscales, gubernamentales ni cámaras de comercio para validar la existencia o solvencia del NIT comercial ingresado.
3. **Carga de documentos adjuntos adicionales para acudientes o empresas:** No se solicitarán soportes documentales complementarios (como fotocopias de cédula del acudiente o certificados de existencia y representación legal); toda la información contextual se recolecta a través de campos de texto estructurados.
4. **Firma digital de contratos o acuerdos de arrendamiento:** El alcance se circunscribe a la postulación y evaluación preliminar, excluyendo la generación y suscripción de contratos vinculantes.

---

## 8. Criterios de Finalización (Definition of Done)

1. Todos los requisitos funcionales (RF-13 a RF-17) y casos límite (CL-10 a CL-14) están formalizados bajo la notación EARS en español.
2. Se han definido claramente los criterios de validación interactiva, obligatoriedad y límites de caracteres para cada campo de los 3 formularios.
3. El comportamiento de visualización para el arrendador se encuentra completamente especificado para cada tipo de inmueble.
4. El documento se enfoca rigurosamente en el **QUÉ** y el **POR QUÉ**, sin alusión a componentes de arquitectura, nombres de archivos de código ni bibliotecas técnicas.

---

## 9. Dudas Abiertas

- `[NECESITA ACLARACIÓN]` **Lista cerrada vs. campo abierto para Parentesco de Acudiente:** Confirmar si el campo "Parentesco" en el formulario de acudiente para menores de edad debe ser una lista desplegable con opciones predefinidas (Padre, Madre, Tutor Legal, Familiar Cercano, Otro) o si debe ser un campo de texto libre.
- `[NECESITA ACLARACIÓN]` **Edad mínima permitida para postularse a una habitación:** Confirmar si el sistema debe validar un umbral de edad mínima (por ejemplo, mínimo 14 o 16 años) o si la declaración afirmativa de minoría de edad con datos de acudiente es suficiente sin requerir fecha de nacimiento exacta.
