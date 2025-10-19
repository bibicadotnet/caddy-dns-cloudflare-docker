# caddy-dns-cloudflare-docker

Truy cập API Tokens

- Nhấn “Create Token”
- Chọn Template: Edit zone DNS
- Nhấn Continue to summary → Create Token
- Sao chép token

Khai báo tại docker file

```
services:
  caddy:
    image: bibica/caddy-dns-cloudflare
    container_name: caddy
    restart: always
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - ./caddy_data:/data
      - ./caddy_config:/config
    environment:
      - CLOUDFLARE_API_TOKEN=xxxxxxxxxxxxxx
    ports:
      - 80:80
      - 443:443
      - 443:443/udp
```
- Thay API Token vào `CLOUDFLARE_API_TOKEN`

Khai báo tại Caddyfile

```
{
  acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
}
```
