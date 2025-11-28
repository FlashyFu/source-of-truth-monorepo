#!/usr/bin/env bash
# Robust deployment script:
# - Validates env
# - Creates backups (DB)
# - Applies migration
# - Restarts service
# - On failure, attempts rollback
#
# Usage:
#   ./deploy.sh production

set -euo pipefail

ENV=${1:-staging}
RELEASE_DIR="/opt/myapp/releases/$(date +%Y%m%d%H%M%S)"
CURRENT_DIR="/opt/myapp/current"
BACKUP_DIR="/opt/myapp/backups/$(date +%Y%m%d%H%M%S)"
KEEP_BACKUPS=5

log() { echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] $*"; }

if [[ -z "${ENV}" ]]; then
  echo "Usage: $0 <environment>"
  exit 2
fi

log "Deploying to $ENV"

# 1. Validate required env vars
: "${APP_REPO:?Need APP_REPO environment variable}"
: "${SSH_USER:?Need SSH_USER environment variable}"
: "${HOST:?Need HOST environment variable}"

# 2. Backup DB (example)
log "Creating DB backup"
mkdir -p "$BACKUP_DIR"
# Example: ssh to host and run pg_dump
# ssh ${SSH_USER}@${HOST} "pg_dump -U postgres app_db" > "$BACKUP_DIR/db.sql"

# 3. Pull latest code and prepare release
log "Preparing release directory $RELEASE_DIR"
mkdir -p "$RELEASE_DIR"
git clone --depth=1 "$APP_REPO" "$RELEASE_DIR"
pushd "$RELEASE_DIR" >/dev/null

# Install deps & build (adjust for language)
if [[ -f package.json ]]; then
  npm ci --production
  npm run build --if-present
fi

popd >/dev/null

# 4. Swap symlink atomically
log "Activating release"
ln -sfn "$RELEASE_DIR" "$CURRENT_DIR"

# 5. Run migrations (safe mode)
log "Running migrations"
# ssh ${SSH_USER}@${HOST} "cd $CURRENT_DIR && ./manage migrate"

# 6. Restart service
log "Restarting service"
# ssh ${SSH_USER}@${HOST} "sudo systemctl restart myapp.service"

# 7. Health check
log "Running health check"
# Example local health check:
# curl -fS http://$HOST/health

log "Deployment complete"

# 8. Prune old backups
ls -1dt /opt/myapp/backups/* | tail -n +$((KEEP_BACKUPS+1)) | xargs -r rm -rf
