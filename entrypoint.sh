#!/bin/bash
set -e

HERMES_HOME="${HERMES_HOME:-/data/.hermes}"
CONFIG_FILE="/data/start9/config.json"
mkdir -p "$HERMES_HOME"

# Apply config from StartOS UI (written by embassy.js)
if [ -f "$CONFIG_FILE" ]; then
  echo "Applying config from $CONFIG_FILE..."
  PROVIDER=$(python3 -c "import json; d=json.load(open('$CONFIG_FILE')); print(d.get('provider',''))" 2>/dev/null || echo "")
  MODEL=$(python3 -c "import json; d=json.load(open('$CONFIG_FILE')); print(d.get('model',''))" 2>/dev/null || echo "")
  BASE_URL=$(python3 -c "import json; d=json.load(open('$CONFIG_FILE')); print(d.get('base_url',''))" 2>/dev/null || echo "")
  API_KEY=$(python3 -c "import json; d=json.load(open('$CONFIG_FILE')); print(d.get('api_key',''))" 2>/dev/null || echo "")

  if [ -n "$PROVIDER" ]; then
    hermes config set model.provider "$PROVIDER" >/dev/null 2>&1 || true
    echo "  provider=$PROVIDER"
  fi
  if [ -n "$MODEL" ]; then
    hermes config set model.default "$MODEL" >/dev/null 2>&1 || true
    echo "  model=$MODEL"
  fi
  if [ -n "$BASE_URL" ]; then
    hermes config set model.base_url "$BASE_URL" >/dev/null 2>&1 || true
    echo "  base_url=$BASE_URL"
  fi
  if [ -n "$API_KEY" ]; then
    case "$PROVIDER" in
      openrouter)   echo "OPENROUTER_API_KEY=$API_KEY" >> "$HERMES_HOME/.env" ;;
      anthropic)    echo "ANTHROPIC_API_KEY=$API_KEY" >> "$HERMES_HOME/.env" ;;
      deepseek)     echo "DEEPSEEK_API_KEY=$API_KEY" >> "$HERMES_HOME/.env" ;;
      nous)         echo "NOUS_API_KEY=$API_KEY" >> "$HERMES_HOME/.env" ;;
      openai)       echo "OPENAI_API_KEY=$API_KEY" >> "$HERMES_HOME/.env" ;;
      openai-codex) echo "OPENAI_API_KEY=$API_KEY" >> "$HERMES_HOME/.env" ;;
      opencode-go)  echo "OPENCODE_GO_API_KEY=$API_KEY" >> "$HERMES_HOME/.env" ;;
    esac
  fi
fi

# Also apply env var overrides (legacy support)
if [ -n "${HERMES_MODEL_PROVIDER:-}" ]; then
  hermes config set model.provider "$HERMES_MODEL_PROVIDER" >/dev/null 2>&1 || true
fi
if [ -n "${HERMES_MODEL_DEFAULT:-}" ]; then
  hermes config set model.default "$HERMES_MODEL_DEFAULT" >/dev/null 2>&1 || true
fi

# Start gateway in background
echo "Starting Hermes Gateway..."
hermes gateway >/tmp/hermes-gateway.log 2>&1 &

# Start dashboard bound to all interfaces on 8787
echo "Starting Hermes Dashboard on 0.0.0.0:8787..."
exec hermes dashboard --host 0.0.0.0 --port 8787 --insecure --no-open
