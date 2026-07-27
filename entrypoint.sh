#!/bin/sh
set -e

if [ -z "$USERNAME" ]; then
    echo "USERNAME is not set"
    exit 1
fi

if [ -z "$TOTP_SECRET" ]; then
    echo "TOTP_SECRET is not set"
    exit 1
fi

TOTP=$(oathtool --totp -b "$VPN_TOTP_SECRET")

cat > auth.txt <<EOF
$VPN_USERNAME
$TOTP
EOF

chmod 600 auth.txt

exec openvpn --config config.ovpn --auth-user-pass auth.txt