#!/bin/bash
set -e

# Hermes Agent config setter
# Reads config JSON from piped stdin and writes to /data/start9/config.json
CONFIG_FILE="/data/start9/config.json"
mkdir -p "$(dirname "$CONFIG_FILE")"
cat > "$CONFIG_FILE"
echo "Config saved"
