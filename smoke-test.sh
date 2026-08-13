#!/usr/bin/env bash
set -uo pipefail

# ---- Config -----------------------------------------------------------
BACKEND_URL="${BACKEND_URL:-http://localhost:8080}"
FRONTEND_URL="${FRONTEND_URL:-http://localhost:9000}"
MAX_RETRIES="${MAX_RETRIES:-30}"
RETRY_DELAY="${RETRY_DELAY:-2}"

# Endpoint -> friendly name
declare -A ENDPOINTS=(
  ["${BACKEND_URL}/healthz"]="Backend healthz"
  ["${BACKEND_URL}/api/random"]="Backend api/random"
  ["${FRONTEND_URL}/fortunes"]="Frontend fortunes"
)

# ---- Helpers ------------------------------------------------------------
log()  { printf '[smoke-test] %s\n' "$1"; }
fail() { printf '[smoke-test] ❌ %s\n' "$1" >&2; }

wait_for() {
  local url="$1"
  local name="$2"
  local attempt=1

  while (( attempt <= MAX_RETRIES )); do
    if curl -fsS -o /dev/null "$url"; then
      log "✅ $name is up ($url)"
      return 0
    fi
    log "waiting for $name... (attempt $attempt/$MAX_RETRIES)"
    sleep "$RETRY_DELAY"
    ((attempt++))
  done

  fail "$name did not become ready after $((MAX_RETRIES * RETRY_DELAY))s: $url"
  return 1
}

# ---- Run ------------------------------------------------------------------
overall_status=0

for url in "${!ENDPOINTS[@]}"; do
  name="${ENDPOINTS[$url]}"
  if ! wait_for "$url" "$name"; then
    overall_status=1
  fi
done

if (( overall_status != 0 )); then
  fail "Smoke test FAILED"
  exit 1
fi

log "🎉 All smoke tests passed"
exit 0