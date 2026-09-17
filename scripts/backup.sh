#!/usr/bin/env bash
set -euo pipefail
OUT_DIR="${1:-backups}"; mkdir -p "$OUT_DIR"
STAMP=$(date +%Y%m%d_%H%M%S)
FILE="$OUT_DIR/tripare_${STAMP}.dump"
PGPASSWORD="${POSTGRES_PASSWORD:-tripare}" pg_dump -h "${PGHOST:-localhost}" -p "${PGPORT:-5432}" -U "${PGUSER:-tripare}" -d "${PGDATABASE:-tripare}" -Fc -f "$FILE"
echo "Backup created: $FILE"
