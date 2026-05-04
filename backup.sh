#!/bin/bash
# Backup: tar the /data directory to stdout
set -e
if [ -d /data ] && [ "$(ls -A /data 2>/dev/null)" ]; then
    tar czf - -C /data .
else
    # Create empty backup for fresh installs
    tar czf - -T /dev/null
fi
