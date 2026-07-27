# rub-openvpn-docker

A lightweight Docker image that establishes an OpenVPN connection to the Ruhr University Bochum (RUB) VPN using username and TOTP authentication.

The container automatically generates the current TOTP code from the configured secret and authenticates against the VPN during startup.

## Deployment

### Using Host Networking

If you want to make the VPN accessible to your entire local network instead of only Docker containers, you can run the container using Docker's host network mode. This allows the Docker host to act as a gateway for other devices in your local network.

To enable other devices to access the VPN, you must configure a static route on your router (or on the individual client devices) that points the desired VPN networks to the Docker host's IP address. Additionally, the host's firewall needs to be configured using commands provided via the env vars `TUN_UP_CMD` and `TUN_DOWN_CMD`. See the example below for details.

### Docker Compose

```yaml
services:
  rubvpn:
    container_name: rubvpn
    image: ghcr.io/reon04/rub-openvpn-docker:latest
    restart: unless-stopped
    environment:
      USERNAME: "<rub-loginid>"
      TOTP_SECRET: "<base32-secret>"
      IFACE: "tun0"
      UP_CMD: >- # optional
        iptables -A FORWARD -i tun0 -j ACCEPT;
        iptables -A FORWARD -o tun0 -j ACCEPT;
        iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE;
        ip6tables -A FORWARD -i tun0 -j ACCEPT;
        ip6tables -A FORWARD -o tun0 -j ACCEPT;
        ip6tables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
      DOWN_CMD: >- # optional
        iptables -D FORWARD -i tun0 -j ACCEPT;
        iptables -D FORWARD -o tun0 -j ACCEPT;
        iptables -t nat -D POSTROUTING -o tun0 -j MASQUERADE;
        ip6tables -D FORWARD -i tun0 -j ACCEPT;
        ip6tables -D FORWARD -o tun0 -j ACCEPT;
        ip6tables -t nat -D POSTROUTING -o tun0 -j MASQUERADE
    network_mode: "host" # optional
    devices:
      - /dev/net/tun:/dev/net/tun
    cap_add:
      - NET_ADMIN
```

### Environment Variables

| Variable | Description |
|----------|-------------|
| `USERNAME` | Your RUB-LoginID. |
| `TOTP_SECRET` | The Base32 encoded TOTP secret used to generate the one-time password during authentication. |
| `IFACE` | The name of the TUN interface created by OpenVPN. Defaults to `tun0` if not specified. |
| `UP_CMD` | A shell command that is executed after the VPN tunnel has been established and the TUN interface is available. This is typically used to configure firewall rules, enable forwarding, or perform other networking tasks. |
| `DOWN_CMD` | A shell command that is executed immediately before the OpenVPN process is stopped. It is typically used to remove any firewall rules or other configuration that was added by `UP_CMD`. |

## License

This project is licensed under the [MIT License](LICENSE).