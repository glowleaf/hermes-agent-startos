#!/bin/bash
# Dynamic port forwarder: discovers hermes-agent container IP and sets up DNAT
# Runs as a systemd oneshot triggered by container events

set -e
CONTAINER_NAME="hermes-agent.embassy"
HOST_PORT="8787"

# Get container IP
CONTAINER_IP=$(podman inspect "$CONTAINER_NAME" --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null || echo "")

if [ -z "$CONTAINER_IP" ]; then
    echo "Container $CONTAINER_NAME not found or has no IP"
    exit 1
fi

echo "Forwarding host:$HOST_PORT -> $CONTAINER_IP:$HOST_PORT"

# Remove any existing DNAT rule for port 8787 (ignore if missing)
iptables -t nat -D PREROUTING -p tcp --dport "$HOST_PORT" -j DNAT --to-destination "$CONTAINER_IP:$HOST_PORT" 2>/dev/null || true
iptables -t nat -D OUTPUT -p tcp --dport "$HOST_PORT" -j DNAT --to-destination "$CONTAINER_IP:$HOST_PORT" 2>/dev/null || true

# Add DNAT rules (PREROUTING for external traffic, OUTPUT for localhost traffic)
iptables -t nat -A PREROUTING -p tcp --dport "$HOST_PORT" -j DNAT --to-destination "$CONTAINER_IP:$HOST_PORT"
iptables -t nat -A OUTPUT -p tcp --dport "$HOST_PORT" -j DNAT --to-destination "$CONTAINER_IP:$HOST_PORT"

# Allow forwarding
iptables -A FORWARD -d "$CONTAINER_IP" -p tcp --dport "$HOST_PORT" -j ACCEPT 2>/dev/null || true

echo "Forwarding active: $HOST_PORT -> $CONTAINER_IP:$HOST_PORT"
exit 0
