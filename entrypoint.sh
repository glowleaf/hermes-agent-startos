#!/bin/bash
set -e

HERMES_HOME="${HERMES_HOME:-/data/.hermes}"
mkdir -p "$HERMES_HOME"

# Initialize config if missing
if [ ! -f "$HERMES_HOME/config.yaml" ]; then
  echo "First run: initializing Hermes config..."
  hermes setup --non-interactive || true
fi

# Apply environment model overrides if provided
if [ -n "$HERMES_MODEL_PROVIDER" ]; then
  hermes config set model.provider "$HERMES_MODEL_PROVIDER" || true
fi
if [ -n "$HERMES_MODEL_DEFAULT" ]; then
  hermes config set model.default "$HERMES_MODEL_DEFAULT" || true
fi

# Start gateway in background (optional messaging interfaces)
echo "Starting Hermes Gateway..."
hermes gateway >/tmp/hermes-gateway.log 2>&1 &

# Ensure Web UI assets are available (build on first run if needed)
hermes setup webui >/tmp/hermes-webui.log 2>&1 || true

# Start dashboard bound to all interfaces on 8787
echo "Starting Hermes Dashboard on 0.0.0.0:8787..."
exec hermes dashboard --host 0.0.0.0 --port 8787 --insecure --no-open
