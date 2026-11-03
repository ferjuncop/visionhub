# VisionHub — plataforma de inspección visual móvil

Este proyecto es independiente de Experience OS y de Queue Hub (otros proyectos de Fernando en el mismo VPS). No heredar sus reglas salvo que se mencionen aquí explícitamente.

## Qué es

Plataforma web móvil para que técnicos inspeccionen salas audiovisuales, pantallas, racks y conectividad con la cámara del dispositivo, con inferencia visual local y diagnóstico progresivo por reglas. Especificación completa en `analisis_plataforma_inspeccion_visual_claude_code.md` (documento maestro, no modificar sin que Fernando lo pida).

## Cómo trabajar con Fernando

- Fernando es experto en audiovisual/digital signage, no programador tradicional. Explicar en lenguaje claro, sin jerga innecesaria.
- Antes de programar algo grande, resumir en 3-5 frases y esperar confirmación.
- Al terminar cada tarea: qué se hizo, cómo probarlo paso a paso, qué queda pendiente o qué riesgos hay.
- Pasos pequeños, cada uno termina en algo probable. No añadir funcionalidad no pedida (anotarla en `docs/IDEAS.md`).
- Commit al final de cada paso, mensaje claro en español.
- Actualizar `docs/PROGRESO.md` al final de cada paso.
- Decisiones de arquitectura van a `docs/DECISIONS.md` (fecha, decisión, motivo).

## Reglas que no se rompen (del propio documento de análisis, sección 14)

1. No inventar hardware, credenciales, URLs, resultados de pruebas ni datos de entrenamiento.
2. No descargar ni enviar imágenes privadas a servicios externos.
3. No instalar CUDA hasta confirmar GPU y versiones compatibles (ahora mismo: VPS sin GPU, ver `docs/DECISIONS.md`).
4. No entrenar con carpetas vacías ni usar datos sintéticos como prueba de calidad real.
5. No publicar un modelo sin evaluación sobre datos reservados.
6. No declarar una prueba como superada si no se ha ejecutado y registrado su resultado.
7. Secretos fuera del repositorio; `.env.example` con valores ficticios.
8. Tests junto con la implementación; ejecutarlos tras cada cambio relevante.
9. Observación, hipótesis y causa confirmada son conceptos distintos — no mezclarlos en el código ni en la UI.
10. El análisis remoto es opt-in, nunca vídeo continuo a la nube por defecto.

## Entorno

- VPS Ubuntu 24.04 compartido con otros servicios (Experience OS, Queue Hub, n8n, Ollama, ComfyUI...). No tocar nada que no sea de este proyecto. Confirmar antes de `sudo`, Nginx o reiniciar servicios ajenos.
- Contenedores propios (cuando existan) con nombres que empiecen por `vh-`, red Docker propia, puertos solo en `127.0.0.1`.
- Capacidad real medida el 2026-11-03: 6 núcleos, ~7.7 GB RAM (con poca disponible según carga del momento), sin GPU. Ver `docs/DECISIONS.md`.

## Stack

Pendiente de decisión final — ver `docs/DECISIONS.md`. En evaluación: reutilizar el stack ya probado en producción (Next.js + Prisma + PostgreSQL + Auth.js, como Experience OS y Queue Hub) para todo lo que no sea el motor de visión, frente a la propuesta original del documento de análisis (Vite + FastAPI). El entrenamiento/exportación de modelos es Python (PyTorch/Ultralytics/ONNX) en cualquier caso.
