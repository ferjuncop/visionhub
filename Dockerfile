# Dockerfile — VisionHub
#
# Mismo patrón que Queue Hub: una "cocina" para instalar y compilar
# (deps + builder) y una "caja final" (runner) para ejecutar. El runner
# se queda con el proyecto completo (no solo .next), así los comandos de
# mantenimiento (prisma migrate deploy, el seed, los tests) funcionan con
# "docker exec" directamente, sin descargar nada nuevo de internet.

FROM node:22-slim AS deps
RUN apt-get update -y && apt-get install -y openssl && rm -rf /var/lib/apt/lists/* \
  && corepack enable
WORKDIR /app
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm install --frozen-lockfile

FROM node:22-slim AS builder
RUN apt-get update -y && apt-get install -y openssl && rm -rf /var/lib/apt/lists/* \
  && corepack enable
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npx prisma generate
RUN pnpm build

FROM node:22-slim AS runner
RUN apt-get update -y && apt-get install -y openssl && rm -rf /var/lib/apt/lists/* \
  && corepack enable
WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app ./

EXPOSE 3000
CMD ["pnpm", "start"]
