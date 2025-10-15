# ───────────────────────────────────────
# Stage 1: Build Caddy với plugin Cloudflare
# ───────────────────────────────────────
FROM golang:1.25.3-alpine AS builder

RUN apk add --no-cache git binutils

RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest

RUN LDFLAGS="-s -w" xcaddy build \
    --with github.com/caddy-dns/cloudflare@latest \
    --output /tmp/caddy

RUN strip /tmp/caddy


# ───────────────────────────────────────
# Stage 2: Runtime
# ───────────────────────────────────────
FROM alpine:latest

RUN apk add --no-cache ca-certificates libcap mailcap wget

RUN mkdir -p /config/caddy /data/caddy /etc/caddy /usr/share/caddy /srv

RUN wget -O /etc/caddy/Caddyfile "https://github.com/caddyserver/dist/raw/33ae08ff08d168572df2956ed14fbc4949880d94/config/Caddyfile" && \
    wget -O /usr/share/caddy/index.html "https://github.com/caddyserver/dist/raw/33ae08ff08d168572df2956ed14fbc4949880d94/welcome/index.html"

COPY --from=builder /tmp/caddy /usr/bin/caddy

RUN chmod +x /usr/bin/caddy && \
    setcap cap_net_bind_service=+ep /usr/bin/caddy

ENV XDG_CONFIG_HOME=/config
ENV XDG_DATA_HOME=/data

LABEL org.opencontainers.image.title="Caddy" \
      org.opencontainers.image.description="Caddy + Cloudflare DNS plugin (lightweight)" \
      org.opencontainers.image.url="https://caddyserver.com" \
      org.opencontainers.image.documentation="https://caddyserver.com/docs" \
      org.opencontainers.image.vendor="Light Code Labs" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.source="https://github.com/caddyserver/caddy"

EXPOSE 80 443 443/udp 2019
WORKDIR /srv

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
