# Taxonomía de clases — detección visual

Catálogo de equipos/componentes que el detector debe aprender a localizar en imagen. Este documento **crecerá**: según el propio documento de análisis (sección 7.2), no se fijan IDs definitivos hasta tener el esquema final, y cualquier clase nueva necesita una definición operacional clara y ejemplos reales antes de darse por confirmada — no basta con proponerla.

Cuando se añadan clases en el futuro, seguir el mismo formato: id provisional, nombre, definición, de dónde sale, estado, fecha.

## Catálogo actual (2026-11-03)

| ID provisional | Clase | Definición | De dónde sale | Estado |
|---:|---|---|---|---|
| 0 | `display` | Pantalla o monitor | Documento de análisis v1 | Confirmada |
| 1 | `kiosk` | Kiosco físico (mueble con pantalla integrada) | `DeviceType.KIOSKO_FISICO` (Queue Hub) | Propuesta — sin ejemplos reales todavía |
| 2 | `tablet` | Tablet (panel de operador u otro uso) | `DeviceType.APP_MOVIL` (Queue Hub) | Propuesta — sin ejemplos reales todavía |
| 3 | `av_camera` | Cámara audiovisual | Documento de análisis v1 | Confirmada |
| 4 | `video_bar` | Barra de videoconferencia | Documento de análisis v1 / `Equipment.kind = "Sala de videoconferencia"` (Experience OS) | Confirmada |
| 5 | `speaker` | Altavoz | `Equipment.kind = "Altavoz"` (Experience OS) | Propuesta — sin ejemplos reales todavía |
| 6 | `computer` | Ordenador/reproductor (la caja que mueve una pantalla) | `Equipment.kind = "Ordenador"` (Experience OS) | Propuesta — sin ejemplos reales todavía |
| 7 | `rack` | Armario rack | Documento de análisis v1 | Confirmada |
| 8 | `network_switch` | Switch de red (incluye routers por ahora, ver nota) | Documento de análisis v1 / `Equipment.kind = "Router"` (Experience OS) | Confirmada, con nota abierta |
| 9 | `cable` | Cable visible | Documento de análisis v1 | Confirmada |
| 10 | `connector` | Conector visible | Documento de análisis v1 | Confirmada |

## Notas abiertas (a resolver con imágenes reales, no antes)

1. **Router vs. switch:** THE Hub los trata como cosas distintas (`"Router"` ≠ `"Switch"` en `Equipment.kind`), pero de momento se quedan juntos en `network_switch` — separarlos sin ejemplos reales de cada uno sería adivinar. Revisar en cuanto haya fotos de ambos: si se distinguen bien a simple vista en las fotos reales, se separan antes de etiquetar nada (cambiar el esquema después de etiquetar es mucho más caro).
2. **`kiosk` y `tablet`:** incluidas en el catálogo a petición de Fernando, pero siguen sin una definición operacional con ejemplos (regla de la sección 7.2 del documento) — confirmarlas de verdad en cuanto lleguen las primeras fotos.

## Fuentes

- Documento de análisis v1 (`analisis_plataforma_inspeccion_visual_claude_code.md`, sección 7.2): catálogo inicial de 7 clases.
- Esquema de Prisma de Experience OS (`Equipment.kind`, texto libre ya en uso en producción): "Sala de videoconferencia", "Router", "Altavoz", "Cámara", "Ordenador", "Otro".
- Esquema de Prisma de Queue Hub (`enum DeviceType`): `KIOSKO_FISICO`, `PANTALLA_SALA`, `APP_MOVIL`, `INTEGRACION_SISTEMA`.
