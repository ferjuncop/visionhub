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
- Pendiente de decidir: dónde entrenar modelos (este VPS con límites, u otra máquina).

## 2026-11-03 — Hito 1: scaffold de la app (Next.js), login y cámara en directo

**Qué se ha hecho:**
- Decidido y registrado el stack definitivo: Next.js (App Router) reutilizando los patrones de Experience OS/Queue Hub (ver `docs/DECISIONS.md`).
- Creada la app Next.js con TypeScript y Tailwind (`create-next-app`), con `prisma`, `@prisma/client`, `next-auth@5 (beta)`, `bcryptjs`, `vitest`, `tsx` — versiones fijadas igual que Queue Hub para máxima compatibilidad.
- Esquema de Prisma mínimo: `User` (con rol ADMIN/TECHNICIAN) y `AuditEvent` (registro de actividad, nunca lanza error — mismo patrón que Queue Hub). **Nota:** no se ha incluido `Tenant`; el documento de análisis no lo pide (parece una herramienta de una sola organización, no un SaaS multi-cliente). Señalado como supuesto a confirmar en `docs/DECISIONS.md`.
- Contenedor propio `vh-postgres` (PostgreSQL 17, solo en `127.0.0.1:55434`, límite de memoria 256 MB) en `infrastructure/docker-compose.yml`.
- Login con email/contraseña (Auth.js, sesión JWT de 8 horas) y página `/camera` protegida que pide la cámara real del dispositivo con `getUserMedia` (sin IA todavía, eso es un hito posterior).
- Usuario de prueba creado: `admin@visionhub.local`.
- Un archivo de Next.js (`middleware.ts`) tuvo que renombrarse a `proxy.ts`: esta versión de Next.js (16.4.4) ya no admite la convención antigua.

**Pruebas ejecutadas y resultado real:**
- `pnpm lint` → sin errores.
- `pnpm vitest run` → 1 test en verde (`recordEvent` nunca lanza error aunque falle la base de datos).
- Arrancado `pnpm dev` de verdad y probado con peticiones HTTP reales (no solo "debería funcionar"):
  - `GET /` sin sesión → redirige a `/login` (307). Con sesión → a `/camera`.
  - Login con la contraseña correcta → `302` y sesión válida (`/api/auth/session` devuelve el usuario).
  - Login con contraseña incorrecta → no entra, `/camera` sigue redirigiendo a `/login`, y queda un `auth.login_failed` en la tabla `AuditEvent` (comprobado por consulta SQL directa, no solo leyendo el código).
  - Login correcto queda como `auth.login_ok` en `AuditEvent`.

**Cómo probarlo tú mismo:**
1. `cd /root/visionhub && cp .env.example .env` y edítalo si quieres otra contraseña (ya hay un `.env` real generado, con secretos propios, que no está en git).
2. `docker compose -p vh --env-file .env -f infrastructure/docker-compose.yml up -d --wait` (si no está ya levantado).
3. `pnpm install && pnpm dev` — abre `http://<IP-del-VPS>:3400` en el navegador del móvil (necesita HTTPS para la cámara en la mayoría de navegadores si no es `localhost`; para probar en el propio VPS por SSH con túnel, o desde el móvil en la misma red, esto es una limitación a resolver en el siguiente hito).
4. Entra con `admin@visionhub.local` / `inspeccion2026`. Debería llevarte a `/camera` y pedir permiso de cámara.

**Pendiente / riesgos para el siguiente hito:**
- Falta la prueba final en un móvil real (ver más abajo, ya hay HTTPS listo para hacerla).
- No hay TOTP/2FA ni OIDC corporativo todavía (SEC-109, fase posterior).
- No hay overlays, IA, ni guardado offline (eso es P1: CAM-102, AI-103, DATA-105).
- Confirmar con Fernando si de verdad no hace falta modelo `Tenant` (ver nota arriba).

## 2026-11-03 — HTTPS real en visionhub.juncopineiro.com

**Qué se ha hecho:**
- Fernando creó el DNS de `visionhub.juncopineiro.com` apuntando al VPS.
- Añadida la configuración de Nginx (`infrastructure/nginx/visionhub.juncopineiro.com.conf`), como proxy hacia el `next dev` del puerto 3400 — es una configuración **temporal de desarrollo**, no la de producción (eso llega cuando haya un contenedor `vh-app` como el de Queue Hub).
- Certificado HTTPS real emitido con Certbot (Let's Encrypt), igual que en Queue Hub/Experience OS. Redirección automática de HTTP a HTTPS.

**Pruebas ejecutadas y resultado real:**
- `nginx -t` → configuración válida antes de recargar.
- `curl https://visionhub.juncopineiro.com/login` → 200, con cookies de Auth.js ya marcadas como `Secure` (la app detectó sola que va por HTTPS a través del proxy).
- `curl http://visionhub.juncopineiro.com/login` → 301 a HTTPS.
- Un primer intento justo tras el cambio de `middleware.ts` a `proxy.ts` dio un 404 puntual (Turbopack recompilando esa ruta); se repitió la prueba tres veces más y salió 200 siempre — no era un fallo real, quedó anotado para no confundirlo con un bug si vuelve a pasar tras cambiar archivos en caliente.

**Pendiente:** la prueba real desde el navegador del móvil de Fernando (pedir permiso de cámara y ver la imagen en directo) — siguiente paso inmediato.
