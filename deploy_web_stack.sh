#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created .env from .env.example. Review values before exposing publicly."
fi

set -a
source ./.env
set +a

if [ "${JWT_SECRET:-replace-with-strong-secret}" = "replace-with-strong-secret" ]; then
  echo "ERROR: Set a real JWT_SECRET in .env before deploying."
  exit 1
fi

echo "Building and starting backend/frontend/database..."
sudo docker compose --env-file .env up -d --build backend frontend postgres

echo "Applying database schema and seed (idempotent)..."
sudo docker compose --env-file .env exec -T postgres \
  psql -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB:-mtc_cafeteria}" \
  < backend/sql/schema.sql
sudo docker compose --env-file .env exec -T postgres \
  psql -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB:-mtc_cafeteria}" \
  < backend/sql/seed.sql

echo
echo "Stack status:"
sudo docker compose --env-file .env ps
echo
echo "Frontend URL: http://$(hostname -I | awk '{print $1}'):${FRONTEND_PORT:-8086}"
echo "Backend health: http://$(hostname -I | awk '{print $1}'):${BACKEND_PORT:-3001}/health"
