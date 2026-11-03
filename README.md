# VisionHub

Plataforma de inspección visual móvil con inferencia local. Especificación funcional y técnica completa en [`analisis_plataforma_inspeccion_visual_claude_code.md`](./analisis_plataforma_inspeccion_visual_claude_code.md).

Estado y decisiones: [`docs/PROGRESO.md`](./docs/PROGRESO.md) y [`docs/DECISIONS.md`](./docs/DECISIONS.md).

## Stack

Next.js (App Router) + React + TypeScript + Tailwind + Prisma + PostgreSQL + Auth.js, pnpm. Ver `docs/DECISIONS.md` para el motivo.

## Desarrollo local

```bash
pnpm install
pnpm dev
```

La app arranca en el puerto configurado en `package.json` (no el 3000, que ya usa otro servicio de este VPS).
