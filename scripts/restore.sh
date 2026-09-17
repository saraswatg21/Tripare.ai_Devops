#!/usr/bin/env bash
set -euo pipefail
BACKUP="${1:?Usage: $0 <backup.dump> [target_db]}"; TARGET_DB="${2:-tripare_restore}"
export PGPASSWORD="${POSTGRES_PASSWORD:-tripare}"
psql -h "${PGHOST:-localhost}" -p "${PGPORT:-5432}" -U "${PGUSER:-tripare}" -d postgres -v ON_ERROR_STOP=1 \
  -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='${TARGET_DB}' AND pid <> pg_backend_pid();" \
  -c "DROP DATABASE IF EXISTS \"${TARGET_DB}\";" -c "CREATE DATABASE \"${TARGET_DB}\";"
pg_restore -h "${PGHOST:-localhost}" -p "${PGPORT:-5432}" -U "${PGUSER:-tripare}" -d "$TARGET_DB" --no-owner --exit-on-error "$BACKUP"
echo "Restore completed into database: $TARGET_DB"
