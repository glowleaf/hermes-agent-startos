#!/bin/bash
set -e

# Hermes Agent config getter - cat the saved config or output empty
CONFIG_FILE="/data/start9/config.json"
if [ -f "$CONFIG_FILE" ]; then
  cat "$CONFIG_FILE"
else
  echo "{}"
fi
