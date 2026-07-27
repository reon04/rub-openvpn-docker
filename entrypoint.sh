#!/bin/sh
set -eu

IFACE="${IFACE:-tun0}"

cleanup() {
    echo "[INFO] Stopping OpenVPN..."

    if [ -n "${DOWN_CMD:-}" ]; then
        echo "[INFO] Running DOWN_CMD..."
        sh -c "$DOWN_CMD" || true
    fi

    if [ -n "${OPENVPN_PID:-}" ]; then
        kill "$OPENVPN_PID" 2>/dev/null || true
        wait "$OPENVPN_PID" 2>/dev/null || true
    fi
}

trap cleanup INT TERM EXIT

: "${USERNAME:?USERNAME is required}"
: "${TOTP_SECRET:?TOTP_SECRET is required}"

TOTP="$(oathtool --totp -b "$TOTP_SECRET")"

cat > auth.txt <<EOF
$USERNAME
$TOTP
EOF

chmod 600 auth.txt

openvpn --config config.ovpn --auth-user-pass auth.txt --dev "$IFACE" &

OPENVPN_PID=$!

echo "[INFO] Waiting for $IFACE..."

until ip link show "$IFACE" >/dev/null 2>&1; do
    if ! kill -0 "$OPENVPN_PID" 2>/dev/null; then
        echo "[ERROR] OpenVPN exited before $IFACE was created."
        wait "$OPENVPN_PID"
        exit 1
    fi

    sleep 1
done

if [ -n "${UP_CMD:-}" ]; then
    echo "[INFO] Running UP_CMD..."
    sh -c "$UP_CMD"
fi

wait "$OPENVPN_PID"