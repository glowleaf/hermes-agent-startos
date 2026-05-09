#!/bin/bash
# Update Hermes Agent from upstream Nous Research repo
# Run via the "Update Hermes Agent" action in StartOS UI
set -e

HERMES_DIR="/opt/hermes-agent"
UPDATE_LOG="/var/log/hermes-update.log"

echo "[$(date -u)] Starting Hermes Agent update from upstream..." | tee "$UPDATE_LOG"

# Verify we're in the Hermes directory
if [ ! -d "$HERMES_DIR" ]; then
  echo "ERROR: Hermes directory not found at $HERMES_DIR" | tee -a "$UPDATE_LOG"
  exit 1
fi

cd "$HERMES_DIR"

# Set up upstream remote (Nous Research, NOT this wrapper repo)
if ! git remote get-url upstream &>/dev/null; then
  echo "Adding upstream remote: https://github.com/NousResearch/hermes-agent.git" | tee -a "$UPDATE_LOG"
  git remote add upstream https://github.com/NousResearch/hermes-agent.git
fi

# Fetch the latest from upstream
echo "Fetching latest from upstream..." | tee -a "$UPDATE_LOG"
git fetch upstream main 2>&1 | tee -a "$UPDATE_LOG"

# Get current and upstream HEAD hashes
CURRENT_HASH=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
UPSTREAM_HASH=$(git rev-parse upstream/main 2>/dev/null || echo "unknown")

if [ "$CURRENT_HASH" = "$UPSTREAM_HASH" ]; then
  echo "Already up to date (HEAD: $CURRENT_HASH)" | tee -a "$UPDATE_LOG"
  echo "No update needed." | tee -a "$UPDATE_LOG"
  # Still do a soft restart to pick up any volume-level changes
  echo "Restarting services..." | tee -a "$UPDATE_LOG"
  kill 1 2>/dev/null || true
  exit 0
fi

# Merge upstream changes (use ours for any conflicts - we keep our wrapper modifications)
echo "Merging upstream changes..." | tee -a "$UPDATE_LOG"
echo "  Current:  $CURRENT_HASH" | tee -a "$UPDATE_LOG"
echo "  Upstream: $UPSTREAM_HASH" | tee -a "$UPDATE_LOG"
git checkout main 2>/dev/null || true
git merge upstream/main --no-edit -X ours 2>&1 | tee -a "$UPDATE_LOG"

# Update Python dependencies
echo "Updating Python package..." | tee -a "$UPDATE_LOG"
if command -v uv &>/dev/null; then
  uv pip install -e ".[all]" --no-cache-dir 2>&1 | tee -a "$UPDATE_LOG"
elif command -v pip &>/dev/null; then
  pip install -e ".[all]" --break-system-packages --no-cache-dir 2>&1 | tee -a "$UPDATE_LOG"
else
  echo "WARNING: Neither uv nor pip found. Skipping Python update." | tee -a "$UPDATE_LOG"
fi

# Rebuild the Web UI
echo "Rebuilding Web UI..." | tee -a "$UPDATE_LOG"
if [ -d "web" ]; then
  cd web
  npm install --prefer-offline --no-audit 2>&1 | tee -a "$UPDATE_LOG"
  npm run build 2>&1 | tee -a "$UPDATE_LOG"
  cd "$HERMES_DIR"
fi

# Copy built web assets to the dist directory
echo "Copying web assets..." | tee -a "$UPDATE_LOG"
mkdir -p hermes_cli/web_dist 2>/dev/null || true
if [ -d "web/dist" ]; then
  cp -r web/dist/* hermes_cli/web_dist/ 2>/dev/null || true
fi

echo "" | tee -a "$UPDATE_LOG"
echo "✓ Update complete!" | tee -a "$UPDATE_LOG"
echo "  New version: $(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')" | tee -a "$UPDATE_LOG"
echo "  Previous:    $(echo $CURRENT_HASH | head -c 8)" | tee -a "$UPDATE_LOG"

# Restart the gateway (PID 1 is tini → hermes dashboard)
echo "Restarting Hermes to apply update..." | tee -a "$UPDATE_LOG"
kill 1 2>/dev/null || true

exit 0
