FROM alpine:3.24

RUN apk add --no-cache openvpn oath-toolkit-oathtool iptables ip6tables iproute2 bash

WORKDIR /app
COPY * .
RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]