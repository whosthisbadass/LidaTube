#!/bin/sh
set -e

# Default to 10.0.1.228:8118 if not provided
: "${SOCKS5_PROXY:=10.0.1.228:8118}"
# Optional: let users specify proxy type via env var, default = "socks5"
: "${SOCKS5_TYPE:=socks5}"

# Parse SOCKS5_PROXY into IP and PORT
SOCKS5_IP="$(echo "$SOCKS5_PROXY" | cut -d: -f1)"
SOCKS5_PORT="$(echo "$SOCKS5_PROXY" | cut -d: -f2)"

echo "========================================="
echo "Setting up Redsocks with the following:"
echo "SOCKS5 IP: $SOCKS5_IP"
echo "SOCKS5 PORT: $SOCKS5_PORT"
echo "SOCKS5 TYPE: $SOCKS5_TYPE"
echo "========================================="

# Dynamically create /etc/redsocks.conf
cat <<EOF > /etc/redsocks.conf
base {
    log_debug = on;
    log_info = on;
    daemon = off;
    redirector = iptables;
}

redsocks {
    local_ip = 0.0.0.0;
    local_port = 12345;
    ip = $SOCKS5_IP;
    port = $SOCKS5_PORT;
    type = $SOCKS5_TYPE;
}
EOF

# Configure iptables to redirect all outbound TCP to Redsocks on port 12345
echo "Configuring iptables for Redsocks..."
iptables -t nat -N REDSOCKS
iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports 12345
iptables -t nat -A OUTPUT -p tcp -j REDSOCKS

# Start redsocks
echo "Starting Redsocks..."
redsocks -c /etc/redsocks.conf &

# Finally, run the original entrypoint script
exec ./thewicklowwolf-init.sh
