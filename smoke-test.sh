#!/usr/bin/env sh
set -eu

# ---- Config -----------------------------------------------------------
BACKEND_URL="${BACKEND_URL:-http://localhost:8080}"
FRONTEND_URL="${FRONTEND_URL:-http://localhost:9000}"
MAX_RETRIES="${MAX_RETRIES:-30}"
RETRY_DELAY="${RETRY_DELAY:-2}"

# Endpoint -> friendly name
ENDPOINTS="
${BACKEND_URL}/healthz|Backend healthz
${BACKEND_URL}/api/random|Backend api/random
${FRONTEND_URL}/fortunes|Frontend fortunes
"

# ---- Helpers ------------------------------------------------------------
log()  { printf '[smoke-test] %s\n' "$1"; }
fail() { printf '[smoke-test] ❌ %s\n' "$1" >&2; }

wait_for() {
  url="$1"
  name="$2"
  attempt=1

  while [ "$attempt" -le "$MAX_RETRIES" ]; do
    if curl -fsS -o /dev/null "$url"; then
      log "$name is up ($url)"
      return 0
    fi
    log "waiting for $name... (attempt $attempt/$MAX_RETRIES)"
    sleep "$RETRY_DELAY"
    attempt=$((attempt + 1))
  done

  fail "$name did not become ready after $((MAX_RETRIES * RETRY_DELAY))s: $url"
  return 1
}

# ---- Run ------------------------------------------------------------------
overall_status=0

while IFS='|' read -r url name; do
  [ -z "$url" ] && continue
  if ! wait_for "$url" "$name"; then
    overall_status=1
  fi
done <<EOF
$ENDPOINTS
EOF

if [ "$overall_status" -ne 0 ]; then
  fail "Smoke test FAILED"
  exit 1
fi

log "All smoke tests passed"
exit 0