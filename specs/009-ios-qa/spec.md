# Especificación Funcional: Aseguramiento de Calidad y Estabilidad para iOS (Flutter)

## 1. Visión General y Propósito
El objetivo de esta especificación es garantizar que los usuarios de dispositivos Apple (iPhone y iPad) disfruten de una experiencia fluida, consistente y libre de interrupciones o cierres inesperados. Se busca que la aplicación cumpla con los estándares de diseño y privacidad del ecosistema iOS, asegurando que el uso de la cámara, la galería de fotos, la navegación táctil por gestos, el teclado en pantalla y los componentes flotantes operen con total naturalidad y respeto a las áreas seguras de la pantalla.

---

## 2. Historias de Usuario

### HU-41: Compatibilidad y Permisos Claros en Dispositivos Apple
* **Como:** usuario arrendador o arrendatario en un dispositivo iPhone o iPad,  
* **Quiero:** que la aplicación me informe de manera transparente el motivo por el cual necesita acceder a mi galería o cámara al momento de subir fotos de propiedades o documentos,  
* **Para:** otorgar los permisos con confianza y que la aplicación funcione sin fallos ni cierres forzosos.

### HU-42: Experiencia Visual y Ergonomía en Pantallas con Áreas Especiales
* **Como:** usuario que navega por fichas de propiedades, proyectos o mapas en dispositivos con muesca o barra de inicio táctil,  
* **Quiero:** que los botones, precios y textos inferiores no queden ocultos ni se superpongan con la barra del sistema operativo,  
* **Para:** poder interactuar con los botones de acción sin activar por error los gestos del sistema del dispositivo.

### HU-43: Fluidez e Interacción con el Teclado en Formularios Extensos
* **Como:** usuario que diligencia formularios de registro, creación de inmuebles o postulaciones de arriendo,  
* **Quiero:** que el teclado se oculte con facilidad al deslizar la vista o tocar fuera de los campos de texto,  
* **Para:** no perder visibilidad de los campos siguientes ni de los botones de confirmación.

### HU-44: Estabilidad Continua y Cero Cierres Inesperados
* **Como:** usuario que utiliza las diversas funcionalidades de la plataforma (mapas, publicidad informativa, llamadas y enlaces de mensajería),  
* **Quiero:** que los servicios complementarios se activen de forma silenciosa y confiable,  
* **Para:** tener una navegación ininterrumpida y libre de bloqueos.

---

## 3. Requerimientos Funcionales

* **RF-47 (Transparencia en Acceso a Fotos y Cámara):** El sistema debe presentar descripciones claras y justificadas ante el sistema operativo al solicitar acceso a fotos o archivos del usuario.
* **RF-48 (Márgenes Seguros en Vistas Modales e Inferiores):** Todos los paneles desplegables inferiores, hojas de detalle de inmuebles y barras de navegación deben respetar los márgenes seguros inferiores y superiores de la pantalla del dispositivo.
* **RF-49 (Cierre Táctil de Teclado en Formularios):** En todas las pantallas de ingreso de datos, el usuario debe poder ocultar el teclado deslizando el contenido hacia abajo o tocando el fondo sin que se borre la información ingresada.
* **RF-50 (Compatibilidad con Comunicación Externa):** El sistema debe permitir iniciar llamadas telefónicas, mensajes y correos electrónicos hacia los contactos de soporte y contrapartes sin restricciones de seguridad del dispositivo.
* **RF-51 (Inicialización Segura de Componentes Auxiliares):** Todos los componentes de publicidad, métricas y actualización deben iniciar correctamente en la plataforma móvil sin generar excepciones críticas.

---

## 4. Requerimientos No Funcionales

* **RNF-31 (Estabilidad Absoluta):** La tasa de cierres forzosos atribuibles a incompatibilidades de plataforma debe ser del 0%.
* **RNF-32 (Conformidad con Directrices del Ecosistema):** El sistema debe adherirse estrictamente a las directrices de revisión de tiendas de aplicaciones móviles respecto a la declaración de permisos de privacidad.
* **RNF-33 (Ergonomía Táctil):** Las áreas de pulsación de botones principales en la parte inferior deben mantener una separación mínima adecuada con respecto a la barra de gestos del sistema.
* **RNF-34 (Rendimiento Visual):** Las transiciones de pantalla, apertura de modales y desplazamientos deben responder con fluidez a 60 cuadros por segundo.

---

## 5. Criterios de Aceptación (Formato EARS)

* **CA-1:** Cuando el usuario decida seleccionar fotos de inmuebles o adjuntar documentos, el sistema solicitará el permiso del dispositivo mostrando una justificación comprensible antes de abrir el selector de archivos.
* **CA-2:** Mientras el usuario visualice una ficha informativa o modal desplegable en un dispositivo con barra de inicio táctil, el sistema mantendrá un margen libre inferior para evitar la superposición de elementos interactivos con la barra del sistema.
* **CA-3:** Cuando el usuario esté editando campos en un formulario y deslice la pantalla hacia abajo, el sistema ocultará el teclado automáticamente para despejar el campo visual.
* **CA-4:** Cuando la aplicación inicie en cualquier dispositivo compatible, el sistema preparará todos los servicios de soporte en segundo plano sin congelar la interfaz de usuario.

---

## 6. Cláusulas de Limitación

* **CL-43:** El acceso a la galería y archivos del usuario solo se solicitará cuando el usuario ejecute una acción explícita de adjuntar o cargar contenido.
* **CL-44:** La aplicación no solicitará permisos que no correspondan con las funcionalidades activas de la plataforma.
* **CL-45:** La adaptación ergonómica a pantallas de diferentes proporciones debe mantenerse sin alterar los colores de marca ni la legibilidad tipográfica.
* **CL-46:** Las funciones de actualización de tienda propietarias de otros sistemas no deben ejecutarse ni emitir advertencias en este entorno.
* **CL-47:** La navegación entre pantallas debe respetar los gestos de retroceso estándar del sistema operativo móvil.
