#!/bin/bash
# ============================================================================
# 012-deploy.sh
# Robust bash deployment script with validation, backup, deploy, and rollback
# ============================================================================
#
# HOW TO USE:
#   1. Customize variables in Configuration section
#   2. Make executable: chmod +x deploy.sh
#   3. Run: ./deploy.sh [environment] [version]
#   4. Example: ./deploy.sh production v1.2.3
#
# FEATURES:
#   - Environment-specific configuration
#   - Pre-deployment validation
#   - Automatic backup before deploy
#   - Health check after deployment
#   - Rollback capability
#   - Logging
#
# ============================================================================

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

# Script metadata
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

# Deployment settings
readonly APP_NAME="${APP_NAME:-myapp}"
readonly DEPLOY_USER="${DEPLOY_USER:-deploy}"
readonly DEPLOY_DIR="${DEPLOY_DIR:-/opt/apps/${APP_NAME}}"
readonly BACKUP_DIR="${BACKUP_DIR:-/opt/backups/${APP_NAME}}"
readonly LOG_DIR="${LOG_DIR:-/var/log/${APP_NAME}}"
readonly LOG_FILE="${LOG_DIR}/deploy_${TIMESTAMP}.log"

# Health check settings
readonly HEALTH_CHECK_URL="${HEALTH_CHECK_URL:-http://localhost:3000/health}"
readonly HEALTH_CHECK_RETRIES="${HEALTH_CHECK_RETRIES:-10}"
readonly HEALTH_CHECK_DELAY="${HEALTH_CHECK_DELAY:-5}"

# Notification settings (customize as needed)
readonly SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
readonly NOTIFY_EMAIL="${NOTIFY_EMAIL:-}"

# ============================================================================
# Color Output
# ============================================================================

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# ============================================================================
# Logging Functions
# ============================================================================

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${timestamp} [${level}] ${message}" | tee -a "${LOG_FILE}"
}

log_info() {
    log "INFO" "${BLUE}$*${NC}"
}

log_success() {
    log "SUCCESS" "${GREEN}$*${NC}"
}

log_warn() {
    log "WARN" "${YELLOW}$*${NC}"
}

log_error() {
    log "ERROR" "${RED}$*${NC}"
}

# ============================================================================
# Utility Functions
# ============================================================================

die() {
    log_error "$1"
    exit 1
}

check_command() {
    command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

send_notification() {
    local message="$1"
    local status="${2:-info}"
    
    # Slack notification
    if [[ -n "${SLACK_WEBHOOK_URL}" ]]; then
        local color
        case "${status}" in
            success) color="good" ;;
            error) color="danger" ;;
            *) color="warning" ;;
        esac
        
        curl -s -X POST "${SLACK_WEBHOOK_URL}" \
            -H 'Content-Type: application/json' \
            -d "{\"attachments\":[{\"color\":\"${color}\",\"text\":\"${message}\"}]}" || true
    fi
    
    # Email notification (requires mail command)
    if [[ -n "${NOTIFY_EMAIL}" ]] && command -v mail >/dev/null 2>&1; then
        echo "${message}" | mail -s "[${APP_NAME}] Deployment ${status}" "${NOTIFY_EMAIL}" || true
    fi
}

# ============================================================================
# Validation Functions
# ============================================================================

validate_environment() {
    local env="$1"
    
    case "${env}" in
        development|staging|production)
            log_info "Environment: ${env}"
            ;;
        *)
            die "Invalid environment: ${env}. Use: development, staging, or production"
            ;;
    esac
}

validate_prerequisites() {
    log_info "Validating prerequisites..."
    
    # Check required commands
    check_command git
    check_command docker
    check_command curl
    
    # Check directories
    [[ -d "${DEPLOY_DIR}" ]] || mkdir -p "${DEPLOY_DIR}"
    [[ -d "${BACKUP_DIR}" ]] || mkdir -p "${BACKUP_DIR}"
    [[ -d "${LOG_DIR}" ]] || mkdir -p "${LOG_DIR}"
    
    # Check permissions
    [[ -w "${DEPLOY_DIR}" ]] || die "Cannot write to deploy directory: ${DEPLOY_DIR}"
    [[ -w "${BACKUP_DIR}" ]] || die "Cannot write to backup directory: ${BACKUP_DIR}"
    
    log_success "Prerequisites validated"
}

# ============================================================================
# Backup Functions
# ============================================================================

create_backup() {
    log_info "Creating backup..."
    
    local backup_file="${BACKUP_DIR}/${APP_NAME}_${TIMESTAMP}.tar.gz"
    
    if [[ -d "${DEPLOY_DIR}/current" ]]; then
        tar -czf "${backup_file}" -C "${DEPLOY_DIR}" current
        log_success "Backup created: ${backup_file}"
        echo "${backup_file}"
    else
        log_warn "No current deployment found, skipping backup"
        echo ""
    fi
}

cleanup_old_backups() {
    local keep_count="${1:-5}"
    
    log_info "Cleaning up old backups (keeping last ${keep_count})..."
    
    local backup_count
    backup_count=$(find "${BACKUP_DIR}" -name "${APP_NAME}_*.tar.gz" | wc -l)
    
    if [[ ${backup_count} -gt ${keep_count} ]]; then
        find "${BACKUP_DIR}" -name "${APP_NAME}_*.tar.gz" -type f | \
            sort | head -n -"${keep_count}" | xargs rm -f
        log_success "Cleaned up old backups"
    fi
}

# ============================================================================
# Deployment Functions
# ============================================================================

pull_latest() {
    local branch="${1:-main}"
    
    log_info "Pulling latest code from ${branch}..."
    
    cd "${DEPLOY_DIR}/source"
    git fetch origin
    git checkout "${branch}"
    git pull origin "${branch}"
    
    log_success "Code updated to latest"
}

build_application() {
    log_info "Building application..."
    
    cd "${DEPLOY_DIR}/source"
    
    # Docker build
    docker build -t "${APP_NAME}:${VERSION}" .
    
    log_success "Build completed"
}

deploy_application() {
    log_info "Deploying application..."
    
    # Stop old container
    docker stop "${APP_NAME}" 2>/dev/null || true
    docker rm "${APP_NAME}" 2>/dev/null || true
    
    # Start new container
    docker run -d \
        --name "${APP_NAME}" \
        --restart unless-stopped \
        -p 3000:3000 \
        -e NODE_ENV="${ENVIRONMENT}" \
        --env-file "${DEPLOY_DIR}/.env.${ENVIRONMENT}" \
        "${APP_NAME}:${VERSION}"
    
    # Update current symlink
    ln -sfn "${DEPLOY_DIR}/releases/${VERSION}" "${DEPLOY_DIR}/current"
    
    log_success "Deployment completed"
}

# ============================================================================
# Health Check Functions
# ============================================================================

health_check() {
    log_info "Running health check..."
    
    local retries=0
    
    while [[ ${retries} -lt ${HEALTH_CHECK_RETRIES} ]]; do
        if curl -sf "${HEALTH_CHECK_URL}" > /dev/null 2>&1; then
            log_success "Health check passed"
            return 0
        fi
        
        retries=$((retries + 1))
        log_warn "Health check attempt ${retries}/${HEALTH_CHECK_RETRIES} failed, retrying in ${HEALTH_CHECK_DELAY}s..."
        sleep "${HEALTH_CHECK_DELAY}"
    done
    
    log_error "Health check failed after ${HEALTH_CHECK_RETRIES} attempts"
    return 1
}

# ============================================================================
# Rollback Functions
# ============================================================================

rollback() {
    local backup_file="$1"
    
    log_warn "Initiating rollback..."
    
    if [[ -z "${backup_file}" ]] || [[ ! -f "${backup_file}" ]]; then
        # Find latest backup
        backup_file=$(find "${BACKUP_DIR}" -name "${APP_NAME}_*.tar.gz" -type f | sort -r | head -1)
    fi
    
    if [[ -z "${backup_file}" ]]; then
        die "No backup file found for rollback"
    fi
    
    log_info "Rolling back to: ${backup_file}"
    
    # Stop and remove current container
    docker stop "${APP_NAME}" 2>/dev/null || true
    docker rm "${APP_NAME}" 2>/dev/null || true
    
    # Restore from backup
    rm -rf "${DEPLOY_DIR}/current"
    tar -xzf "${backup_file}" -C "${DEPLOY_DIR}"
    
    # Extract previous version from backup filename (e.g., myapp_20240115_093000.tar.gz)
    local backup_timestamp
    backup_timestamp=$(basename "${backup_file}" .tar.gz | sed "s/${APP_NAME}_//")
    
    # Run container with previous image
    # Note: This assumes the previous Docker image is still available
    # For more robust rollback, consider tagging images by version
    docker run -d \
        --name "${APP_NAME}" \
        --restart unless-stopped \
        -p 3000:3000 \
        -e NODE_ENV="${ENVIRONMENT:-production}" \
        --env-file "${DEPLOY_DIR}/.env.${ENVIRONMENT:-production}" \
        "${APP_NAME}:previous" 2>/dev/null || \
    docker run -d \
        --name "${APP_NAME}" \
        --restart unless-stopped \
        -p 3000:3000 \
        -e NODE_ENV="${ENVIRONMENT:-production}" \
        --env-file "${DEPLOY_DIR}/.env.${ENVIRONMENT:-production}" \
        "${APP_NAME}:latest"
    
    log_success "Rollback completed"
}

# ============================================================================
# Main Deployment Flow
# ============================================================================

main() {
    local environment="${1:-staging}"
    local version="${2:-latest}"
    
    export ENVIRONMENT="${environment}"
    export VERSION="${version}"
    
    log_info "=========================================="
    log_info "Deploying ${APP_NAME}"
    log_info "Environment: ${environment}"
    log_info "Version: ${version}"
    log_info "Timestamp: ${TIMESTAMP}"
    log_info "=========================================="
    
    # Validate
    validate_environment "${environment}"
    validate_prerequisites
    
    # Backup
    local backup_file
    backup_file=$(create_backup)
    
    # Deploy
    if ! (
        pull_latest "${version}"
        build_application
        deploy_application
    ); then
        log_error "Deployment failed"
        
        if [[ -n "${backup_file}" ]]; then
            rollback "${backup_file}"
        fi
        
        send_notification "❌ Deployment of ${APP_NAME} ${version} to ${environment} FAILED" "error"
        exit 1
    fi
    
    # Verify
    if ! health_check; then
        log_error "Health check failed after deployment"
        
        if [[ -n "${backup_file}" ]]; then
            rollback "${backup_file}"
        fi
        
        send_notification "❌ Deployment of ${APP_NAME} ${version} to ${environment} FAILED (health check)" "error"
        exit 1
    fi
    
    # Cleanup
    cleanup_old_backups 5
    
    log_success "=========================================="
    log_success "Deployment completed successfully!"
    log_success "=========================================="
    
    send_notification "✅ Deployment of ${APP_NAME} ${version} to ${environment} SUCCEEDED" "success"
}

# ============================================================================
# Script Entry Point
# ============================================================================

# Show help
if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
    echo "Usage: ${SCRIPT_NAME} [environment] [version]"
    echo ""
    echo "Arguments:"
    echo "  environment   Target environment (development, staging, production)"
    echo "  version       Version/branch to deploy (default: latest)"
    echo ""
    echo "Examples:"
    echo "  ${SCRIPT_NAME} staging v1.2.3"
    echo "  ${SCRIPT_NAME} production main"
    echo ""
    echo "Environment Variables:"
    echo "  APP_NAME              Application name (default: myapp)"
    echo "  DEPLOY_DIR            Deployment directory"
    echo "  BACKUP_DIR            Backup directory"
    echo "  HEALTH_CHECK_URL      Health check endpoint"
    echo "  SLACK_WEBHOOK_URL     Slack webhook for notifications"
    exit 0
fi

# Rollback command
if [[ "${1:-}" == "rollback" ]]; then
    rollback "${2:-}"
    exit 0
fi

# Run main deployment
main "$@"

# ============================================================================
# PRODUCTION CHECKLIST:
# - [ ] Test in staging environment first
# - [ ] Ensure backup storage has sufficient space
# - [ ] Configure monitoring/alerting
# - [ ] Set up notification webhooks
# - [ ] Create runbook for manual intervention
# - [ ] Test rollback procedure
# - [ ] Document environment-specific configurations
# - [ ] Set up log rotation for deployment logs
# ============================================================================
