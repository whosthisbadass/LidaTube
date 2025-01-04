#!/bin/sh
set -e

#
# 1. Grab real ISP IP before redsocks takes over
#
REAL_IP=$(curl -s https://ifconfig.me || echo "unknown")
echo "Your ISP public IP is ${REAL_IP}"
echo

unset REAL_IP

#
# 2. Parse env variables for the proxy
#
: "${SOCKS5_PROXY:=10.0.1.228:8118}"
: "${SOCKS5_TYPE:=socks5}"

SOCKS5_IP="$(echo "$SOCKS5_PROXY" | cut -d: -f1)"
SOCKS5_PORT="$(echo "$SOCKS5_PROXY" | cut -d: -f2)"

cat <<EOF
=========================================
Setting up Redsocks with the following:
Proxy IP:    $SOCKS5_IP
Proxy Port:  $SOCKS5_PORT
Proxy Type:  $SOCKS5_TYPE
=========================================
EOF

#
# 3. Dynamically create /etc/redsocks.conf
#
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

#
# 4. Configure iptables to redirect all outbound TCP traffic to Redsocks
#
echo "Configuring iptables to redirect all TCP traffic..."
iptables -t nat -N REDSOCKS
iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports 12345
iptables -t nat -A OUTPUT -p tcp -j REDSOCKS

echo "Starting Redsocks..."
redsocks -c /etc/redsocks.conf &

# Give Redsocks a moment to initialize
sleep 2

#
# 5. Check proxied IP (this should be different if your proxy is external)
#
PROXY_IP=$(curl -s https://ifconfig.me || echo "unknown")
echo "Your Proxied ISP public IP is now ${PROXY_IP}"
echo

unset PROXY_IP

# 6. Finally, run the original script to start the app
exec ./thewicklowwolf-init.sh
