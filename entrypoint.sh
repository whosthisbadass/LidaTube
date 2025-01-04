#!/bin/sh
set -e

# Fallback to 10.0.1.228:8118 if no SOCKS5_PROXY is provided
: "${SOCKS5_PROXY:=10.0.1.228:8118}"
# Optional: let the user specify the proxy type (socks5, http-connect, etc.). Defaults to socks5.
: "${SOCKS5_TYPE:=socks5}"

# Parse SOCKS5_PROXY into IP and PORT
SOCKS5_IP="$(echo "$SOCKS5_PROXY" | cut -d: -f1)"
SOCKS5_PORT="$(echo "$SOCKS5_PROXY" | cut -d: -f2)"

echo "========================================="
echo "Setting up Redsocks with the following:"
echo "SOCKS5 IP:    $SOCKS5_IP"
echo "SOCKS5 PORT:  $SOCKS5_PORT"
echo "SOCKS5 TYPE:  $SOCKS5_TYPE"
echo "========================================="

# Dynamically create /etc/redsocks.conf
cat <<EOF > /etc/redsocks.conf
base {
    /* debug logs, turn off in production if you prefer */
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

echo "Configuring iptables to redirect all outbound TCP traffic to Redsocks..."
# Create a new chain for Redsocks
iptables -t nat -N REDSOCKS
# Redirect all TCP traffic to port 12345 (where Redsocks listens)
iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports 12345
# Apply that chain to all TCP traffic in the OUTPUT chain
iptables -t nat -A OUTPUT -p tcp -j REDSOCKS

echo "Starting Redsocks..."
redsocks -c /etc/redsocks.conf &

# Finally, run the original LidaTube entrypoint script to start your app
exec ./thewicklowwolf-init.sh
