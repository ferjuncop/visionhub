#!/usr/bin/env bash
# deploy.sh — Construye y despliega VisionHub en el VPS.
# Mismo patrón que Queue Hub (ver /root/queuehub/deploy.sh).
#
# Uso:  cd /root/visionhub && ./deploy.sh
#
# Qué hace:
#   1. Se asegura de que vh-postgres está arriba.
#   2. Construye la imagen nueva (la app actual sigue funcionando mientras tanto).
#   3. Guarda la imagen anterior como "vh-app:previous" para poder volver atrás.
#   4. Sustituye el contenedor vh-app, en la red vh-net, solo en 127.0.0.1.
#   5. Aplica las migraciones de Prisma ya revisadas en git (prisma migrate deploy
#      solo aplica migraciones existentes, nunca crea ni adivina nada).
#   6. Comprueba /api/health y ejecuta los tests. Si algo falla, vuelve sola
#      a la versión anterior.
#
# Secretos: nunca van dentro de la imagen.
#   - .env         → se monta en el contenedor en modo solo lectura.
#   - .env.docker  → DATABASE_URL apuntando al contenedor "vh-postgres" por nombre
#                    (red vh-net, no por el puerto publicado en 127.0.0.1). Se monta
#                    como /app/.env.production.local (Next.js la lee al arrancar).
#                    Si no existe, se crea a partir de las variables de .env.
set -euo pipefail

APP=vh-app
DIR="$(cd "$(dirname "$0")" && pwd)"
NETWORK=vh-net
PORT=3400
HEALTH_URL="http://127.0.0.1:${PORT}/api/health"

cd "$DIR"

[ -f .env ] || { echo "ERROR: falta $DIR/.env"; exit 1; }

if [ ! -f .env.docker ]; then
  echo "→ Creando .env.docker con la DATABASE_URL hacia vh-postgres"
  set -a; source .env; set +a
  ( umask 077
    echo "DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@vh-postgres:5432/${POSTGRES_DB}" > .env.docker )
fi

echo "→ Comprobando que vh-postgres está en marcha..."
docker compose -p vh --env-file .env -f infrastructure/docker-compose.yml up -d --wait > /dev/null

echo "→ Construyendo imagen (versión $(git rev-parse --short HEAD 2>/dev/null || echo 'sin-git'))..."
docker build -t "$APP:candidate" .

if docker image inspect "$APP:latest" >/dev/null 2>&1; then
  docker tag "$APP:latest" "$APP:previous"
fi
docker tag "$APP:candidate" "$APP:latest"

run_container() {
  docker rm -f "$APP" >/dev/null 2>&1 || true
  docker run -d --name "$APP" \
    --restart unless-stopped \
    --network "$NETWORK" \
    -p "127.0.0.1:${PORT}:3000" \
    --memory 384m \
    -v "$DIR/.env:/app/.env:ro" \
    -v "$DIR/.env.docker:/app/.env.production.local:ro" \
    "$1" >/dev/null
}

wait_healthy() {
  for _ in $(seq 1 30); do
    if curl -fs -o /dev/null "$HEALTH_URL"; then return 0; fi
    sleep 2
  done
  return 1
}

run_migrations() {
  docker exec "$APP" sh -c 'set -a; . ./.env.production.local; npx prisma migrate deploy'
}

smoke_test() {
  docker exec "$APP" sh -c 'set -a; . ./.env.production.local; npx vitest run'
}

rollback() {
  if docker image inspect "$APP:previous" >/dev/null 2>&1; then
    echo "→ Volviendo a la versión anterior..."
    docker tag "$APP:previous" "$APP:latest"
    run_container "$APP:latest"
    wait_healthy && echo "✓ Versión anterior restaurada." || echo "✗ La versión anterior tampoco responde: revisar a mano."
  fi
}

cleanup_old_images() {
  docker image prune -f >/dev/null 2>&1 || true
}

echo "→ Sustituyendo el contenedor..."
run_container "$APP:latest"

if ! wait_healthy; then
  echo "✗ La versión nueva no responde. Últimos registros:"
  docker logs "$APP" --tail 50 || true
  rollback
  cleanup_old_images
  exit 1
fi

echo "→ Aplicando migraciones de Prisma..."
if ! run_migrations; then
  echo "✗ Las migraciones fallaron. Últimos registros:"
  docker logs "$APP" --tail 50 || true
  rollback
  cleanup_old_images
  exit 1
fi

echo "✓ Despliegue correcto: $HEALTH_URL responde."

echo "→ Pruebas automatizadas..."
if ! smoke_test; then
  echo "✗ Alguna prueba falló. Últimos registros:"
  docker logs "$APP" --tail 50 || true
  rollback
  cleanup_old_images
  exit 1
fi
echo "✓ Todas las pruebas pasan."
docker logs "$APP" --tail 30
cleanup_old_images
