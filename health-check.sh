#!/bin/bash
# Health check: confirm the Hermes WebUI is responding
curl -sf http://127.0.0.1:8787/ > /dev/null 2>&1
exit $?
