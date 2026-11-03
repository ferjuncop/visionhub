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

## Pendiente — Unificación de stack con Experience OS / Queue Hub

Auditados ambos proyectos hermanos (mismo VPS). Patrones reutilizables encontrados:
- Next.js + React + TypeScript + Tailwind + Prisma + PostgreSQL + Auth.js (JWT), pnpm.
- Multi-tenant por `tenantId` en cada tabla relevante + wrapper de autorización por petición (`withAuthz` en Queue Hub).
- Registro de eventos de auditoría (`recordEvent`, nunca lanza error) — encaja con el requisito de trazabilidad del documento de análisis.
- Autenticación con TOTP (2FA) y rate limiting ya implementados en Queue Hub, reutilizables para el requisito de SSO/OIDC corporativo.
- Infraestructura: contenedores con prefijo propio por proyecto, red Docker propia, puertos solo en `127.0.0.1`, `deploy.sh` con imagen anterior de respaldo y rollback automático si falla el health check, backups con cron.
- Agentes nativos ya construidos en Queue Hub (Android con APK/Device Owner, Windows con PowerShell/NSIS) — lecciones ya aprendidas sobre MDM y depuración ADB, relevantes si la PWA no basta para este proyecto.

**Sin decidir todavía:** si el backend/API de VisionHub se construye en Next.js (reutilizando todo lo anterior) en vez de FastAPI, y si la app móvil de cámara sigue la recomendación original del documento (Vite, por el peso del Web Worker + ONNX Runtime Web + modo offline) o también se intenta en Next.js. El entrenamiento/exportación de modelos (PyTorch/Ultralytics/ONNX) es Python en cualquier escenario, porque ninguno de los otros proyectos hace ML.
