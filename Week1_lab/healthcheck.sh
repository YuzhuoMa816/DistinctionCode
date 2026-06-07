#!/bin/bash

# ==============================
# Configurable variables
# ==============================

LOG_FILE="/var/log/healthcheck.log"
DISK_THRESHOLD=80
MEMORY_THRESHOLD=85
SERVICE_NAME="nginx"
CHECK_PATH="/"

# ==============================
# Logging functions
# ==============================
log() {
    local status="$1"
    local message="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $status: $message" >> "$LOG_FILE"
}


log "INFO" "Health check script started."


# ==============================
# Check nginx status
# ==============================


if systemctl is-active --quiet "$SERVICE_NAME"; then
    log "OK" "Nginx service is running"
else
    log "ACTION" "Nginx was down -- Restarting"
    systemctl restart "$SERVICE_NAME"
    if [ "$?" -eq 0 ]; then
        log "OK" "Nginx service restarted successfully"
    else
        log "ERROR" "Nginx service failed to restart"
        exit 1
    fi
fi


# ==============================
# Check disk usage 
# ==============================
disk_usage=$(df -P "$CHECK_PATH" | awk 'NR==2 {gsub("%", "", $5); print $5}')

if [[ "$disk_usage" -gt "$DISK_THRESHOLD" ]]; then
    log "WARNING" "Disk usage is high: ${disk_usage}% on $CHECK_PATH"
fi

# ==============================
# Check memory usage 
# ==============================

mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
mem_available=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)

mem_used_percent=$(( (mem_total - mem_available) * 100 / mem_total ))

if [[ "$mem_used_percent" -gt "$MEMORY_THRESHOLD" ]]; then
    log "WARNING" "Memory usage is high: ${mem_used_percent}%"
fi