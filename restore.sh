#!/bin/bash
# Restore: extract tar from stdin to /data
set -e
rm -rf /data/*
tar xzf - -C /data 2>/dev/null || true
