# Decisiones de arquitectura

Cada entrada: fecha, decisión, motivo.

## 2026-11-03 — Proyecto independiente de Experience OS

VisionHub no hereda el `CLAUDE.md` global de `/root` (describe Experience OS, un producto distinto). Este archivo (`/root/visionhub/CLAUDE.md`) es la fuente de reglas para este proyecto.

## 2026-11-03 — Capacidad real del VPS medida

- CPU: 6 núcleos on-line (no 128; esa cifra es del hipervisor físico, no de esta VM).
- RAM: 7.7 GB totales; en el momento de medir, ~500 MB libres y 2.9/4 GB de swap en uso por otros servicios del VPS.
- GPU: ninguna (sin NVIDIA, solo VGA genérica de QEMU).
- Disco: 232 GB totales, 84 GB libres.

**Motivo:** el documento de análisis (ML-001) exige confirmar hardware antes de planear entrenamiento o instalar CUDA. Con estos datos, no se instalará CUDA (no hay GPU) y cualquier entrenamiento será CPU-only, con los límites de memoria que eso implica.

**Pendiente de decidir:** si el entrenamiento de modelos se hace en este VPS (con límites estrictos y en horas de bajo uso) o en otra máquina, dejando este VPS solo para inferencia/producción.

## 2026-11-03 — Unificación de stack: Next.js, reutilizando Experience OS y Queue Hub

**Decisión:** VisionHub se construye sobre Next.js (App Router) + React + TypeScript + Tailwind + Prisma + PostgreSQL + Auth.js + pnpm, en vez de la propuesta original del documento (Vite + FastAPI). Se aplica tanto a la app móvil del técnico como al backend/API: un único Next.js, siguiendo el patrón de Queue Hub (una sola app, no separada en apps/mobile-web + apps/api como sugería el documento) salvo que una necesidad real obligue a separar más adelante.

Se reutilizan directamente estos patrones ya probados en producción:
- Multi-tenant por `tenantId` en cada tabla relevante + wrapper de autorización por petición (`withAuthz` en Queue Hub).
- Registro de eventos de auditoría (`recordEvent`, nunca lanza error) para el requisito de trazabilidad.
- Autenticación con TOTP (2FA) y rate limiting de Queue Hub, como base para el SSO/OIDC corporativo.
- Infraestructura: contenedores con prefijo propio (`vh-`), red Docker propia, puertos solo en `127.0.0.1`, patrón de `deploy.sh` con imagen anterior de respaldo y rollback si falla el health check, backups con cron.
- Agentes nativos ya construidos en Queue Hub (Android/Windows) como referencia si la PWA no basta más adelante.

**Motivo:** maximizar la reutilización de código y de lecciones ya aprendidas (auth, auditoría, despliegue, backups) frente a mantener dos stacks de backend distintos para un solo desarrollador. Web Workers, IndexedDB, Cache Storage y ONNX Runtime Web son APIs del navegador independientes del framework, así que Next.js no impide el modo offline ni la inferencia en worker — solo añade un paso extra de configuración de PWA/service worker que no existía con Vite.

**Qué no cambia:** el entrenamiento y la exportación de modelos (PyTorch/Ultralytics/ONNX) siguen siendo Python, en scripts independientes dentro de `ml/`, sin exponerse como servicio web — no hace falta FastAPI para eso.

**Riesgo registrado:** si el rendimiento de cámara/inferencia en Next.js resulta insuficiente en dispositivos reales (TECH-002, benchmark pendiente), revisar esta decisión antes de avanzar más en el motor visual — no después.

## 2026-11-03 — Supuesto: VisionHub no es multi-tenant (a confirmar)

El esquema de Prisma del Hito 1 no incluye un modelo `Tenant`, a diferencia de Experience OS y Queue Hub. El documento de análisis (sección 9.2) lista `User/Role`, `Site`, `Room`, etc. sin mencionar `Tenant`, lo que sugiere una herramienta de uso interno de una sola organización, no un SaaS para varios clientes.

**Motivo:** no inventar una entidad que el documento no pide.

**A confirmar con Fernando:** si en el futuro distintas empresas clientes van a usar la misma instalación de VisionHub con datos separados, hay que añadir `tenantId` ahora, antes de que existan más datos y migraciones que reescribir.
