# Plataforma de inspección visual móvil con inferencia local
## Documento de análisis funcional, arquitectura y plan de entrenamiento — v1

**Estado:** propuesta técnica inicial para trabajar con Claude Code  
**Idioma:** español  
**Objetivo del documento:** servir como contexto de producto, especificación técnica inicial y guía de implementación incremental.  
**Principio rector:** no inventar requisitos, capacidades de hardware, resultados de modelos ni datos de prueba. Todo supuesto debe declararse y validarse.

---

## 1. Resumen ejecutivo

Se propone desarrollar una plataforma web móvil para ayudar a técnicos a inspeccionar salas audiovisuales, pantallas, racks y conectividad mediante la cámara del dispositivo. El sistema debe analizar imágenes localmente, mostrar anotaciones en tiempo real, guiar la captura de evidencias y generar diagnósticos progresivos a partir de lo que realmente se observa, el inventario técnico y procedimientos validados.

La inferencia local es la ruta principal para mantener una experiencia fluida, reducir dependencia de la conectividad y limitar la exposición de imágenes. El análisis remoto está permitido bajo demanda, con controles de privacidad, minimización de datos y auditoría; no se debe transmitir vídeo continuo a la nube por defecto.

El sistema no debe tratar una detección visual como prueba definitiva de una causa técnica. Debe distinguir entre:
- **Observación:** lo que el sistema detecta directamente en la imagen.
- **Hipótesis:** posible explicación compatible con las observaciones.
- **Causa confirmada:** conclusión respaldada por una verificación técnica suficiente.
- **Inconcluso / escalar:** la evidencia no permite determinarlo con confianza.

El aprendizaje será controlado: los casos confirmados o corregidos se revisan y etiquetan antes de entrar en un dataset. Los modelos nuevos se evalúan y publican como versiones; no se actualizan automáticamente los pesos del modelo de producción con feedback sin validar.

---

## 2. Contexto y problema

Las inspecciones de salas audiovisuales y de conectividad pueden requerir desplazamientos, comprobaciones manuales y experiencia técnica. La herramienta debe ayudar a:
- identificar visualmente equipos y componentes;
- guiar al técnico hacia las vistas necesarias;
- detectar síntomas visuales concretos y definidos;
- comparar lo observado con el inventario y la configuración esperada;
- conservar evidencias y trazabilidad;
- permitir trabajo offline para los casos y paquetes descargados que lo soporten;
- mejorar el sistema a partir de casos reales validados.

No se pretende construir de inicio un diagnóstico universal ni afirmar fallos internos o eléctricos a partir de una imagen.

## 3. Decisiones de producto ya acordadas

1. **Dispositivos:** equipos corporativos gestionados por MDM. El inventario exacto de modelos, versiones de sistema operativo, navegador/contenedor, RAM y aceleradores está pendiente.
2. **Primer caso de uso:** salas audiovisuales, pantallas, racks y conectividad.
3. **Análisis remoto:** permitido bajo demanda, con controles de privacidad.
4. **Inferencia:** priorizar ejecución local en el dispositivo móvil.
5. **Offline:** objetivo para tareas cubiertas por modelos, inventario, reglas y procedimientos descargados.
6. **Datos de entrenamiento:** actualmente no hay imágenes reales disponibles.
7. **Política de datos:** imágenes y datos de entrenamiento solo en infraestructura propia; no subirlos a servicios externos.
8. **Hardware de entrenamiento:** VPS Linux, capacidades exactas aún desconocidas.
9. **Plataforma cliente:** comenzar evaluando una PWA con React/TypeScript; no cerrar PWA frente a Capacitor/nativa hasta realizar pruebas en dispositivos reales.
10. **Aprendizaje:** no reentrenar automáticamente el modelo de producción a partir de feedback sin revisión.

## 4. Alcance del MVP

### 4.1 Incluido

- Captura de imagen y vídeo en directo con cámara, en los dispositivos aprobados.
- Selección de fotogramas recientes para inferencia local.
- Anotaciones visuales sobre la imagen en directo.
- Detección de equipos y componentes seleccionados.
- Guía de captura cuando la evidencia no sea suficiente.
- Diagnóstico progresivo mediante reglas, inventario y procedimientos.
- Registro de observaciones, hipótesis, confirmaciones y casos inconclusos.
- Guardado local y recuperación tras cierre inesperado.
- Modo offline para los casos declarados compatibles.
- Sincronización posterior con el backend, con idempotencia y gestión explícita de conflictos.
- Gestión de versiones de modelos y paquetes de conocimiento.
- Análisis remoto opcional bajo demanda y con controles de privacidad.
- Trazabilidad: modelo, versión, paquete de conocimiento, evidencia y decisiones del técnico.

### 4.2 Fuera del alcance inicial

- Diagnóstico universal de cualquier dispositivo o incidencia.
- Confirmación de fallos internos, eléctricos o de red que no sean observables visualmente.
- Compatibilidad garantizada con cualquier móvil.
- Entrenamiento continuo automático en producción.
- Supervisión garantizada cuando la aplicación está en segundo plano.
- Transmisión continua de vídeo a la nube por defecto.
- Microservicios distribuidos desde el primer día si no existe una necesidad demostrada.

---

## 5. Experiencia y flujo principal de inspección

1. El técnico selecciona emplazamiento, sala y tipo de inspección.
2. La aplicación comprueba que los modelos, inventario, reglas y procedimientos necesarios están disponibles y son compatibles.
3. Se inicia la cámara sin esperar a que la IA esté lista.
4. Un planificador selecciona fotogramas recientes y descarta los antiguos cuando hay retraso.
5. El runtime local ejecuta detección y, cuando sea necesario, tracking.
6. El motor diagnóstico combina detecciones con activos, reglas, procedimientos y estado esperado.
7. Si falta evidencia, la aplicación pide al técnico cambiar el ángulo, acercarse, capturar una etiqueta o mostrar un indicador.
8. Se presentan observaciones e hipótesis con nivel de confianza y evidencia asociada.
9. El técnico confirma, rechaza, corrige o deja pendiente el hallazgo.
10. Se guarda localmente la inspección y se sincroniza cuando exista conectividad.
11. Si está permitido y el caso lo requiere, se puede solicitar análisis remoto enviando únicamente los datos mínimos necesarios y mostrando qué se enviará.

La interfaz debe seguir siendo usable aunque la inferencia sea lenta, falle o no esté disponible.

---

## 6. Arquitectura lógica

### 6.1 Capas

**A. Aplicación móvil**
- React + TypeScript + Vite como baseline.
- Cámara y permisos.
- Vista de inspección y overlays.
- Guía de captura.
- Estados de inspección y confirmación técnica.
- Historial local y cola de sincronización.

**B. Motor visual local**
- Frame Scheduler: frecuencia de inferencia controlada, cola acotada y descarte de fotogramas antiguos.
- Preprocesamiento.
- Runtime de inferencia.
- Detector de objetos.
- Tracker ligero, si aporta valor medido.
- OCR para etiquetas o pantallas en una fase posterior.
- Postprocesamiento y gestión de confianza.
- Métricas de latencia, memoria, FPS y errores.

**C. Motor diagnóstico**
- Máquina de estados.
- Reglas y condiciones de aplicabilidad.
- Asociación entre objetos detectados e inventario.
- Procedimientos técnicos versionados.
- Requisitos de evidencia.
- Separación entre observación, hipótesis y causa confirmada.
- Abstención y escalado cuando la evidencia sea insuficiente.

**D. Datos locales**
- IndexedDB para inspecciones, estados y metadatos.
- Cache Storage para recursos web compatibles.
- Modelos y paquetes de conocimiento versionados.
- Evidencias autorizadas.
- Cola de sincronización persistente.
- Verificación de cuotas, persistencia y fallos de almacenamiento.

**E. Servicios centrales**
- API con autenticación y autorización.
- Usuarios, roles, emplazamientos, salas y activos.
- Inspecciones, hallazgos, evidencias y auditoría.
- Sincronización y resolución de conflictos.
- Registro y distribución de modelos.
- Registro de paquetes de conocimiento.
- Servicio de análisis remoto opcional.
- Trabajos de evaluación y preparación de nuevos modelos.

### 6.2 Stack de referencia

| Área | Baseline |
|---|---|
| Frontend | React + TypeScript + Vite |
| Captura inicial | `getUserMedia()` en PWA |
| Tareas pesadas | Web Workers |
| Runtime web | ONNX Runtime Web |
| Aceleración | WASM como fallback; probar WebGPU cuando exista compatibilidad |
| Persistencia cliente | IndexedDB + Cache Storage |
| API | Python + FastAPI |
| Base de datos | PostgreSQL |
| Evidencias | Almacenamiento de objetos bajo control propio |
| Identidad | OIDC/SSO corporativo |
| Cola de tareas | Añadir solo cuando el flujo lo necesite |
| Anotación | CVAT autohospedado o herramienta equivalente |
| Entrenamiento inicial | PyTorch + Ultralytics, condicionado a licencia y compatibilidad |
| Exportación | ONNX y pruebas de equivalencia |

No asumir que WebGPU está disponible en todos los dispositivos. Si la PWA no cumple rendimiento, cámara, persistencia u operación offline, evaluar Capacitor o integración nativa sin cambiar los contratos del motor diagnóstico y backend.

### 6.3 Organización orientativa del repositorio

```text
visual-inspection/
├── apps/
│   ├── mobile-web/
│   ├── admin-web/
│   └── api/
├── packages/
│   ├── domain/
│   ├── vision-runtime/
│   ├── diagnostic-engine/
│   ├── camera/
│   ├── local-storage/
│   ├── sync-engine/
│   └── contracts/
├── services/
│   ├── model-registry/
│   ├── model-evaluation/
│   └── background-jobs/
├── ml/
│   ├── datasets/
│   ├── training/
│   ├── evaluation/
│   └── export/
├── infra/
│   ├── containers/
│   ├── deployment/
│   └── monitoring/
└── docs/
    ├── architecture/
    ├── api/
    ├── security/
    └── test-plans/
```

Esta estructura es una orientación, no una obligación. Mantener un backend modular único al inicio.

---

## 7. Estrategia de IA y entrenamiento

### 7.1 No entrenar un modelo desde cero

La estrategia recomendada es aprendizaje por transferencia con un detector compacto preentrenado, y construir el dataset específico antes de evaluar la idoneidad real del modelo.

Separar tres responsabilidades:

1. **Detección visual:** localizar equipos/componentes y síntomas visuales definidos.
2. **Diagnóstico contextual:** aplicar reglas, inventario y procedimientos; no requiere una red neuronal al principio.
3. **Análisis avanzado opcional:** análisis remoto bajo demanda para casos complejos, con datos minimizados y auditoría.

No asumir que un detector genérico sabe identificar correctamente los equipos de la empresa ni incidencias específicas.

### 7.2 Primer catálogo de clases

Catálogo inicial propuesto para revisión con un especialista:

| ID provisional | Clase | Definición |
|---:|---|---|
| 0 | `display` | Pantalla o monitor |
| 1 | `av_camera` | Cámara audiovisual |
| 2 | `video_bar` | Barra de videoconferencia |
| 3 | `rack` | Armario rack |
| 4 | `network_switch` | Switch de red |
| 5 | `cable` | Cable visible |
| 6 | `connector` | Conector visible |

No fijar IDs hasta confirmar el esquema final. Mantener la misma correspondencia en las anotaciones, `data.yaml`, evaluación, aplicación y manifiestos de modelo.

No añadir todavía clases ambiguas como `cable_desconectado`, `pantalla_defectuosa` o `equipo_roto` sin una definición operacional y ejemplos etiquetables de forma consistente. Algunas condiciones pueden necesitar clasificación especializada, análisis temporal o reglas contextuales.

### 7.3 Datos iniciales

No existen imágenes reales todavía. Por tanto, el primer hito de ML es **recoger y etiquetar datos**, no entrenar un detector personalizado.

Objetivo exploratorio, no garantía de suficiencia: entre 500 y 2.000 imágenes variadas para iniciar un piloto. El número necesario dependerá de las clases, variabilidad y rendimiento medido.

Recoger:
- vistas generales y primeros planos;
- ángulos y distancias diferentes;
- iluminación normal, baja y con reflejos;
- varios modelos de equipos cuando sea posible;
- estados normales y síntomas definidos;
- ejemplos difíciles y casos sin objetos de las clases seleccionadas.

Evitar que miles de fotogramas casi idénticos se consideren diversidad. Separar train/validation/test por sala, sesión o instalación para evitar fuga de datos.

Privacidad:
- Capturar solo en emplazamientos autorizados.
- Minimizar rostros, credenciales, códigos QR, datos personales y contenido de pantalla que no sea necesario.
- Mantener imágenes, etiquetas y checkpoints en infraestructura propia.
- No subir datos a servicios de anotación o entrenamiento externos.
- Definir acceso, retención, borrado, cifrado y auditoría.
- Si se descargan paquetes o pesos iniciales, verificar su procedencia y licencias.

### 7.4 Anotación

Usar CVAT Community autohospedado o una alternativa local. Exportar en formato compatible con detección YOLO.

Cada imagen debe tener anotaciones consistentes. Los archivos YOLO de detección contienen clase y coordenadas normalizadas de las cajas. Revisar una muestra de cada clase y comprobar:
- límites de cajas;
- etiquetas correctas;
- objetos omitidos;
- objetos parcialmente ocultos;
- clases confundibles;
- imágenes sin objetos;
- duplicados y calidad del dataset.

### 7.5 División de datos

Punto de partida:
- 70 % entrenamiento.
- 15 % validación.
- 15 % prueba.

La división debe agruparse por sala, sesión o instalación, no aleatorizar simplemente fotogramas. No usar el conjunto de prueba para ajustar el modelo.

### 7.6 Modelo y licencia

Modelo experimental propuesto: variante compacta de YOLO, por ejemplo YOLO26n, para probar detección y exportación. La selección definitiva debe comprobar:
- rendimiento en hardware real;
- compatibilidad con ONNX Runtime Web;
- operadores soportados;
- precisión por clase;
- licencia del framework y checkpoint;
- condiciones de distribución/comercialización.

No asumir que un modelo, checkpoint o paquete tiene licencia compatible con el producto solo porque se puede descargar. Revisar términos vigentes antes de incorporarlo comercialmente.

### 7.7 Entrenamiento en VPS Linux

Hardware desconocido. Primer paso obligatorio: obtener CPU, RAM, almacenamiento, sistema operativo y disponibilidad de GPU/controladores. No instalar CUDA hasta confirmar una GPU NVIDIA compatible y una matriz de versiones adecuada.

Usar un entorno virtual Python. Instalar PyTorch, Ultralytics, ONNX y ONNX Runtime con versiones compatibles. Si no hay GPU, comenzar con un experimento pequeño de CPU solo si la memoria y el tiempo son razonables; no afirmar que un VPS desconocido soportará un entrenamiento concreto.

Ejemplo de estructura:

```text
ml/
├── datasets/
│   └── av_inspection/
│       ├── images/
│       │   ├── train/
│       │   ├── val/
│       │   └── test/
│       ├── labels/
│       │   ├── train/
│       │   ├── val/
│       │   └── test/
│       └── data.yaml
├── training/
├── evaluation/
└── export/
```

Ejemplo de `data.yaml` (adaptar rutas e IDs reales):

```yaml
path: /ruta/absoluta/ml/datasets/av_inspection
train: images/train
val: images/val
test: images/test

names:
  0: display
  1: av_camera
  2: video_bar
  3: rack
  4: network_switch
  5: cable
  6: connector
```

Ejemplo conceptual de entrenamiento con Ultralytics; usarlo solo después de crear y revisar el dataset:

```python
from ultralytics import YOLO

model = YOLO("yolo26n.pt")
model.train(
    data="ml/datasets/av_inspection/data.yaml",
    epochs=50,
    imgsz=640,
    batch=2,          # valor inicial conservador; ajustar según RAM/VRAM
    workers=2,
    patience=12,
    seed=42,
    project="runs",
    name="av_detector_v1",
)
```

Este script es una plantilla de partida. Debe adaptarse al hardware, a la versión de Ultralytics y a las rutas del proyecto. La descarga inicial del checkpoint puede requerir Internet. No usar imágenes sintéticas como única prueba de validez.

### 7.8 Evaluación

Evaluar el conjunto de prueba reservado y reportar por clase:
- precisión;
- recall;
- mAP50 y mAP50-95;
- falsos positivos y falsos negativos;
- matriz de confusión cuando sea aplicable;
- ejemplos de aciertos y errores;
- rendimiento por sala, iluminación, distancia y dispositivo.

No fijar porcentajes de aceptación universales sin analizar el riesgo por clase. En casos críticos, priorizar una política explícita de abstención/escalado.

### 7.9 Exportación ONNX

Exportar desde el checkpoint validado y verificar el archivo con ONNX checker. Después:
- ejecutar inferencia con ONNX Runtime en el VPS;
- comparar outputs con el modelo original;
- documentar tamaño, resolución de entrada y nombres/shapes de tensores;
- implementar preprocesamiento y postprocesamiento idénticos;
- medir la latencia y memoria;
- probar WASM y WebGPU en cada dispositivo móvil aprobado;
- evaluar cuantización solo después de tener una referencia de precisión.

No considerar el archivo ONNX listo para producción solo porque la exportación termina sin error.

### 7.10 Ciclo de mejora continua

1. El modelo produce observaciones.
2. El técnico confirma, rechaza, corrige o deja pendiente.
3. Se registran evidencias autorizadas, contexto y versiones.
4. Los casos difíciles pasan a revisión humana.
5. Los especialistas corrigen las etiquetas.
6. Se crea una nueva versión del dataset.
7. Se entrena un candidato y se ejecuta la batería de regresión.
8. Se compara con la versión actual, incluyendo clases críticas.
9. Se publica gradualmente si cumple los criterios.
10. Se mantiene rollback.

El feedback del técnico no es automáticamente una verdad de referencia. No actualizar pesos de producción en línea sin revisión y evaluación.

---

## 8. Runtime local y rendimiento móvil

La aplicación no debe bloquear la cámara esperando inferencia.

Diseño recomendado:
- capturar frames continuamente;
- enviar al runtime solo frames recientes;
- mantener cola acotada;
- descartar frames obsoletos;
- etiquetar cada resultado con timestamp;
- ocultar o marcar overlays obsoletos;
- separar la cámara del hilo principal cuando sea posible;
- limitar resolución/frecuencia de inferencia según el perfil del dispositivo;
- registrar FPS, latencia p50/p95, memoria y errores;
- permitir degradación explícita si no hay aceleración.

Objetivos iniciales para benchmark, sujetos a validación:
- 30 FPS de cámara si el dispositivo lo sostiene;
- latencia p95 de anotación ligera inferior a 250 ms como objetivo inicial;
- sesión representativa de 30 minutos sin degradación que impida completar;
- no mostrar anotaciones como actuales si están desfasadas.

Estos son objetivos de ingeniería, no prestaciones garantizadas.

---

## 9. Backend, datos y sincronización

### 9.1 Backend de referencia

- FastAPI.
- PostgreSQL.
- Almacenamiento de objetos bajo control propio.
- OIDC/SSO.
- Autorización comprobada en el servidor.
- Registro de auditoría.
- API versionada.
- Backend modular inicialmente.

### 9.2 Entidades de dominio iniciales

Diseñar contratos y esquemas para:
- `User` / `Role`
- `Site`
- `Room`
- `Asset`
- `Inspection`
- `Finding`
- `Observation`
- `Evidence`
- `Procedure`
- `ModelVersion`
- `KnowledgePackVersion`
- `SyncOperation`
- `AuditEvent`

Son entidades propuestas. Validar el modelo de datos antes de implementar migraciones.

### 9.3 Sincronización

- Guardar localmente antes de confirmar al usuario que el dato está guardado.
- Mantener cola persistente.
- Usar claves idempotentes para evitar duplicados.
- Registrar errores y reintentos.
- No sobrescribir silenciosamente datos críticos ante conflictos.
- Exponer estados pendiente, sincronizado y error.
- Recuperar inspecciones tras cierre inesperado.
- Definir expiración, tamaño máximo y limpieza de evidencias.
- Comprobar cuotas y persistencia en navegadores aprobados.

### 9.4 Versionado de modelos y paquetes

Cada modelo debería tener un manifiesto con, como mínimo:
- ID y versión;
- hash criptográfico del artefacto;
- clases y su orden;
- formato y resolución de entrada;
- versión del preprocesamiento/postprocesamiento;
- runtime y requisitos de compatibilidad;
- métricas por clase y dataset de evaluación;
- fecha y responsable de publicación;
- licencia y procedencia;
- estado de aprobación.

Descargar en una ubicación temporal, verificar hash/firma, comprobar compatibilidad y activar de forma atómica. Si falla la actualización, conservar la versión anterior. No activar modelos no verificados.

---

## 10. Privacidad y análisis remoto bajo demanda

La política permite análisis remoto bajo demanda, pero prohíbe enviar vídeo continuo por defecto.

Antes de enviar:
- confirmar que el usuario tiene permiso y que la política lo permite;
- explicar qué se enviará y con qué finalidad;
- minimizar a recortes, imágenes seleccionadas y metadatos imprescindibles;
- eliminar o enmascarar datos innecesarios;
- aplicar cifrado en tránsito y en reposo;
- aplicar autorización en servidor;
- registrar quién solicita el análisis, qué se envía y el resultado;
- definir retención y borrado;
- no usar datos para entrenar modelos automáticamente;
- si el servicio falla, mantener el caso inconcluso o pendiente y no inventar un diagnóstico.

No almacenar secretos en el cliente ni incluir credenciales en código fuente.

---

## 11. Criterios de aceptación

### Cámara e inferencia
- **ACC-01:** la cámara funciona en cada combinación aprobada de dispositivo/SO/navegador.
- **ACC-02:** la cámara continúa aunque la inferencia esté ocupada.
- **ACC-03:** las anotaciones obsoletas se ocultan o identifican como antiguas.
- **ACC-04:** se guía al técnico cuando la evidencia es insuficiente.
- **ACC-05:** estados explícitos de resuelta, confirmada, inconclusa o escalada.
- **ACC-08:** objetivo de 30 FPS cuando el dispositivo lo sostenga.
- **ACC-09:** objetivo inicial p95 de anotación ligera <250 ms, sujeto a benchmark.
- **ACC-10:** cola acotada y descarte de frames antiguos.
- **ACC-11:** sesión representativa de 30 minutos sin degradación que impida completar.
- **ACC-12:** perfil de dispositivo selecciona una ruta validada.
- **ACC-13:** fallback probado o degradación explícita si falla el backend acelerado.

### Offline y sincronización
- **ACC-06:** recuperación de inspección tras cierre inesperado.
- **ACC-14:** los casos declarados offline se completan en modo avión.
- **ACC-15:** se detectan paquetes ausentes, caducados o incompatibles.
- **ACC-16:** se sincronizan pendientes al recuperar conexión.
- **ACC-17:** los reintentos no duplican incidencias.
- **ACC-18:** los conflictos se registran sin sobrescribir silenciosamente datos críticos.
- **ACC-19:** fallo de almacenamiento visible y sin falsa confirmación de guardado.

### Calidad del diagnóstico y modelos
- **ACC-07:** no declarar ausencia de un objeto sin cobertura visual suficiente.
- **ACC-20:** cada hallazgo conserva evidencia y versión de modelo.
- **ACC-21:** observación, hipótesis y causa confirmada se distinguen.
- **ACC-22:** métricas propias de precisión/recall/falsos positivos por clase.
- **ACC-23:** abstención/escalado cuando falte evidencia.
- **ACC-24:** no publicar un modelo si empeora inaceptablemente los casos críticos.

### Seguridad y trazabilidad
- **ACC-25:** API autentica y autoriza en servidor.
- **ACC-26:** modelos verificados antes de activarse.
- **ACC-27:** una actualización fallida conserva la versión anterior.
- **ACC-28:** análisis remoto requiere política permitida y auditoría.
- **ACC-29:** reglas de retención y borrado aplicadas.
- **ACC-30:** cada resultado permite rastrear modelo y paquete de conocimiento.

Los umbrales de precisión se definirán con datos reales y análisis de riesgo por clase, no se inventarán.

---

## 12. Backlog priorizado

### P0 — Bloqueos y decisiones
- **TECH-001:** inventario MDM: modelos exactos, versiones de SO, navegador/contenedor, RAM, políticas, almacenamiento.
- **TECH-002:** prueba técnica de cámara e inferencia: WASM, WebGPU si está disponible, alternativa híbrida/nativa; medir FPS, latencia, memoria y temperatura.
- **TECH-003:** definir piloto: salas, equipos, incidencias, condiciones de captura y resultados esperados.
- **TECH-004:** contratos de datos, privacidad, retención y permisos.
- **ML-001:** comprobar hardware del VPS (CPU/RAM/disco/GPU/OS) y fijar entorno reproducible.
- **ML-002:** diseñar protocolo de captura y taxonomía de clases.
- **ML-003:** desplegar herramienta de anotación local y flujo de revisión.

### P1 — MVP funcional
- **APP-101:** base React/TypeScript.
- **CAM-102:** cámara, orientación, overlays y guía.
- **AI-103:** runtime, worker, selección de frames, detector, tracker y métricas.
- **DIAG-104:** máquina de estados, reglas, evidencias e hipótesis.
- **DATA-105:** persistencia offline y recuperación.
- **API-106:** backend, PostgreSQL, activos/inspecciones/usuarios/auditoría.
- **SYNC-107:** sincronización robusta, idempotencia y conflictos.
- **MODEL-108:** manifiestos, descarga, verificación, activación y rollback.
- **SEC-109:** SSO/roles, autorización, cifrado, permisos offline y análisis remoto.
- **QA-110:** banco de pruebas, dataset, métricas y regresión.
- **ML-004:** capturar, etiquetar y revisar el primer dataset.
- **ML-005:** entrenar, evaluar y documentar el primer detector.
- **ML-006:** exportar ONNX y comprobar equivalencia.

### P2 — Mejoras
- **AI-201:** OCR avanzado para etiquetas y pantallas.
- **AI-202:** modelos especializados por incidencia.
- **AI-203:** comparación con referencias visuales.
- **GUIDE-204:** guía adaptativa de captura.
- **CLOUD-205:** análisis remoto bajo demanda.
- **LEARN-206:** ciclo de mejora y publicación gradual.
- **OPS-207:** dashboard operativo.
- **MDM-208:** despliegue corporativo.
- **ML-007:** optimización, cuantización y aceleración después de medir la precisión.

---

## 13. Roadmap indicativo

Estimación inicial sujeta al tamaño del equipo, la disponibilidad de datos y el inventario de dispositivos:

- **Semanas 1–2:** inventario MDM, inspección del VPS, prueba de cámara/runtime, protocolo de captura y decisión PWA frente a híbrida.
- **Semanas 3–5:** cámara, worker, anotaciones y tracking básico.
- **Semanas 6–9:** motor diagnóstico, estados y offline.
- **Semanas 10–13:** API, sincronización, registro de modelos y seguridad.
- **Semanas 14–19:** piloto real, evaluación, correcciones y publicación controlada.

El entrenamiento específico no puede completarse de forma seria hasta tener datos reales etiquetados. Las fases de software y recopilación de datos pueden avanzar en paralelo.

---

## 14. Cómo debe trabajar Claude Code con este documento

Claude Code debe tratar este archivo como contexto y especificación inicial, no como autorización para inventar información ni para implementar toda la plataforma en un único cambio.

### Reglas de trabajo

1. Inspeccionar primero el repositorio existente y su documentación. No sobrescribir proyectos o decisiones ya implementados sin entenderlos.
2. Crear un resumen del estado actual: estructura, tecnologías, pruebas, riesgos y discrepancias con este documento.
3. Distinguir requisitos acordados, decisiones pendientes y propuestas.
4. No inventar hardware, credenciales, URLs, endpoints, resultados de pruebas ni datos de entrenamiento.
5. No descargar ni enviar imágenes privadas a servicios externos.
6. No instalar CUDA hasta confirmar el hardware y las versiones compatibles.
7. No entrenar con carpetas vacías ni usar datos sintéticos como prueba de calidad real.
8. No publicar un modelo sin evaluación sobre datos reservados y revisión de falsos negativos.
9. No afirmar que una prueba se ha superado si no se ha ejecutado y registrado su resultado.
10. Mantener los secretos fuera del repositorio; añadir `.env.example` con valores ficticios claramente marcados.
11. Añadir tests junto con la implementación y ejecutar los relevantes después de cada cambio.
12. Trabajar por fases pequeñas y revisables; mostrar los archivos modificados, comandos ejecutados, resultados y riesgos.
13. Si una decisión requiere información desconocida, detenerse y proponer una prueba o pregunta concreta, en lugar de asumir.
14. Preservar trazabilidad de versiones, migraciones y contratos.
15. Mantener un `docs/DECISIONS.md` con las decisiones arquitectónicas y su justificación.

### Primera tarea solicitada a Claude Code

**No implementar aún toda la plataforma.** Ejecutar únicamente una fase de reconocimiento y preparación:

1. Inspeccionar el repositorio y el entorno real.
2. Identificar OS, Python, CPU, RAM, disco y disponibilidad de GPU en el VPS.
3. Detectar si existe código previo, datos o modelos.
4. Crear o actualizar documentación de estado.
5. Proponer un plan de implementación por hitos con dependencias y pruebas.
6. Preparar el scaffold ML y scripts de diagnóstico solo después de confirmar que no se sobrescribe trabajo existente.
7. No entrenar ni descargar modelos hasta que el usuario confirme el plan y la política de procedencia/licencias.

### Formato de informe esperado por cada fase

- Objetivo.
- Archivos inspeccionados.
- Decisiones tomadas y supuestos.
- Archivos creados/modificados.
- Comandos ejecutados.
- Pruebas ejecutadas y resultados reales.
- Riesgos, limitaciones y trabajo pendiente.
- Próximo hito propuesto.

---

## 15. Decisiones pendientes que deben cerrarse con evidencia

1. Inventario exacto de dispositivos MDM.
2. PWA frente a Capacitor/nativa, después del benchmark.
3. Capacidad del VPS y viabilidad de entrenamiento local.
4. Taxonomía definitiva de objetos e incidencias.
5. Dataset mínimo y umbrales de aceptación por clase.
6. Licencia aprobada para el detector y su distribución comercial.
7. Requisitos corporativos de retención, cifrado y auditoría.
8. Qué tipos de evidencia se permiten enviar al análisis remoto.
9. Resolución de entrada y frecuencia de inferencia por perfil de dispositivo.
10. Procedimiento de aprobación y rollback de modelos.

## 16. Referencias técnicas oficiales para verificar antes de implementar

Las versiones, licencias y opciones pueden cambiar. Consultar documentación vigente al implementar:

- Ultralytics: https://docs.ultralytics.com/
- Modelos YOLO26: https://docs.ultralytics.com/models/yolo26/
- Exportación ONNX: https://docs.ultralytics.com/integrations/onnx
- ONNX Runtime Web: https://onnxruntime.ai/docs/get-started/with-javascript/web.html
- CVAT: https://docs.cvat.ai/
- React: https://react.dev/
- Vite: https://vite.dev/
- FastAPI: https://fastapi.tiangolo.com/
- MDN `getUserMedia`: https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getUserMedia
- IndexedDB: https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API

---

## 17. Resultado esperado de la v1

La v1 no debe prometer una IA que diagnostique cualquier problema. Debe entregar una plataforma controlada y medible que:

- detecte objetos dentro de un catálogo validado;
- guíe la captura de evidencias;
- utilice reglas e inventario para construir hipótesis;
- se abstenga cuando no haya evidencia suficiente;
- funcione offline en los casos que estén preparados para ello;
- registre y sincronice inspecciones con seguridad;
- ejecute inferencia local con rendimiento medido;
- permita entrenar y distribuir nuevas versiones a partir de datos revisados;
- conserve la trazabilidad de cada resultado.

**Principio de cierre:** priorizar evidencia, reproducibilidad y evaluación real por encima de añadir complejidad o declarar capacidades no demostradas.
