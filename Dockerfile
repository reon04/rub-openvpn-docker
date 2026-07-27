FROM alpine:3.22

RUN apk add --no-cache openvpn oath-toolkit bash

WORKDIR /app
COPY * .
RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]