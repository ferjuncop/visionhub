# Progreso

## 2026-11-03 — Auditoría inicial y cimentación del repositorio

**Qué se ha hecho:**
- Leído el documento de análisis completo.
- Auditado el VPS: CPU (6 núcleos), RAM (7.7 GB, poca libre en el momento de medir), sin GPU, disco (84 GB libres), software ya instalado (Python 3.12, Docker, Node 22, pnpm, git).
- Auditados los proyectos hermanos `experience-os` y `queuehub` para identificar tecnologías reutilizables (ver `docs/DECISIONS.md`).
- Creado el repositorio git local, con `CLAUDE.md` propio, `docs/DECISIONS.md`, `docs/PROGRESO.md`, `docs/IDEAS.md` y `.gitignore`.
- Preparada una clave SSH propia (`visionhub_deploy`) para subir a GitHub, siguiendo el mismo patrón que los otros dos proyectos (una clave de despliegue por repositorio).

**Cómo probarlo:**
- `cd /root/visionhub && git log --oneline` debe mostrar el primer commit.
- Todavía no hay nada que ejecutar o abrir en un navegador: es solo la base del repositorio.

**Pendiente / riesgos:**
- Falta añadir la clave pública `visionhub_deploy.pub` como Deploy Key (con permiso de escritura) en la configuración del repositorio de GitHub antes de poder hacer el primer `git push`.
- Pendiente de decidir: unificar stack con Next.js (como Experience OS/Queue Hub) o seguir la propuesta original del documento (Vite + FastAPI) — ver `docs/DECISIONS.md`.
- Pendiente de decidir: dónde entrenar modelos (este VPS con límites, u otra máquina).
