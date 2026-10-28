#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${HOME}/.codespace-maintenance"
LOG_FILE="${LOG_DIR}/maintenance.log"
INTERVAL_SECONDS="${MAINTENANCE_INTERVAL_SECONDS:-60}"
PRUNE_INTERVAL_SECONDS="${PRUNE_INTERVAL_SECONDS:-600}"

mkdir -p "$LOG_DIR"
cd "$ROOT_DIR"

log() {
  printf '[%s] %s\n' "$(date -Is)" "$*" >> "$LOG_FILE"
}

memory_snapshot() {
  awk '/MemTotal:|MemAvailable:|SwapTotal:|SwapFree:/ {printf "%s=%s %s; ", $1, $2, $3} END {print ""}' /proc/meminfo >> "$LOG_FILE"
}

start_stack_if_needed() {
  running_services="$(docker compose ps --status running --services 2>/dev/null || true)"
  if ! grep -qx 'whiterabbitneo' <<<"$running_services" || ! grep -qx 'open-webui' <<<"$running_services"; then
    log 'one or more services are not running; starting Compose stack'
    docker compose up -d >> "$LOG_FILE" 2>&1 || log 'Compose start failed; will retry'
  fi
}

safe_prune() {
  log 'pruning stopped containers, dangling images, and unused build cache'
  docker container prune -f >> "$LOG_FILE" 2>&1 || true
  docker image prune -f >> "$LOG_FILE" 2>&1 || true
  docker builder prune -f >> "$LOG_FILE" 2>&1 || true
}

last_prune=0
log 'maintenance daemon started; model files and Docker volumes will never be pruned'

while :; do
  start_stack_if_needed
  memory_snapshot

  now="$(date +%s)"
  if (( now - last_prune >= PRUNE_INTERVAL_SECONDS )); then
    safe_prune
    last_prune="$now"
  fi

  log 'keepalive'
  sleep "$INTERVAL_SECONDS"
done