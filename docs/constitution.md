# Constitución del Proyecto ViHome

## 1. Propósito y Filosofía
ViHome es una plataforma inmobiliaria digital para la compra, venta y arrendamiento de propiedades y proyectos. Este documento establece los principios rectores de calidad, especificación de requisitos y metodología de desarrollo para garantizar consistencia, estabilidad y valor real a los usuarios.

---

## 2. Principios Fundamentales

### 2.1. Separación Estricta entre Especificación e Implementación
- **Fase de Especificación (QUÉ y POR QUÉ):** Se documenta exclusivamente la intención del negocio, flujos de usuario, reglas de negocio, casos límite y criterios de aceptación. No se mencionan frameworks, tecnologías, nombres de archivos ni patrones arquitectónicos.
- **Fase de Planificación e Implementación (CÓMO):** Se definen los detalles técnicos, arquitectura, estructura de archivos y código una vez aprobada la especificación.

### 2.2. Notación EARS para Criterios de Aceptación
Todos los criterios de aceptación en los requisitos funcionales deben redactarse utilizando la sintaxis formal de EARS (Easy Approach to Requirements Syntax) en español:
- **Ubicuos (siempre activos):** `El sistema DEBERÁ <acción/resultado>.`
- **Dirigidos por eventos:** `CUANDO <evento disparador>, el sistema DEBERÁ <acción/resultado>.`
- **Basados en estado:** `MIENTRAS <estado/condición activa>, el sistema DEBERÁ <acción/resultado>.`
- **Opcionales / Por características:** `DONDE <característica opcional esté presente>, el sistema DEBERÁ <acción/resultado>.`
- **Manejo de errores y excepciones:** `SI <condición de error o excepción>, ENTONCES el sistema DEBERÁ <acción/resultado>.`

### 2.3. Desarrollo Guiado por Comportamiento y Verificación
- Ningún comportamiento nuevo o existente se da por completado sin una suite de pruebas automatizadas que valide los criterios de aceptación.
- Los comportamientos del código existente deben identificarse, documentarse en la especificación y verificarse mediante pruebas antes de refactorizaciones mayores.

### 2.4. Manejo Robusto de Casos Límite y Errores
- Toda interacción de usuario debe prever escenarios de fallo: sin conexión, datos incompletos, errores de permisos o fallos de servicio.
- El sistema debe ofrecer siempre retroalimentación comprensible y accionable al usuario.

---

## 3. Estructura de Documentación de Especificaciones
Toda especificación funcional debe ubicarse en `specs/<id-especificacion>/spec.md` y contar con:
1. **Contexto y Objetivo:** Por qué existe esta funcionalidad y qué valor aporta.
2. **Perfiles de Usuario:** Quiénes interactúan con el sistema y sus motivaciones.
3. **Historias de Usuario:** Declaraciones de valor (Como [rol], quiero [acción], para [beneficio]).
4. **Requisitos Funcionales (RF-x):** Criterios de aceptación formalizados en EARS.
5. **Requisitos No Funcionales (RNF-x):** Rendimiento, seguridad, accesibilidad y usabilidad.
6. **Casos Límite y Excepciones:** Escenarios extremos o atípicos.
7. **Fuera de Alcance:** Delimitación explícita de lo que no forma parte de la entrega/MVP.
8. **Criterios de Finalización (Definition of Done):** Condiciones medibles para dar por finalizada la entrega.
9. **Dudas Abiertas:** Marcadas explícitamente con `[NECESITA ACLARACIÓN]` para resolución continua.
