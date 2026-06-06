# NOMAD via Traefik (or similar reverse proxy)

NOMAD is a **single portal** (`nomad.example.com`). You click an app in the UI → it opens. Settings → Service Logs → opens Dozzle. No manual bookmarks.

## How NOMAD builds links

| Action | UI behaviour | Traefik needs |
|--------|--------------|---------------|
| Open app | `NOMAD_APP_*_URL` from `.env` → e.g. `https://kiwix.example.com` | HTTP route on :443 |
| Service Logs | hardcoded `nomad.example.com:9999` | TCP+TLS on :9999 |

Apps are configured via `configure-app-urls.mjs` (runs on every admin start). Dozzle is **not** in MySQL.

## Architecture

```
Browser → Traefik (proxy host) → NOMAD Docker host
          :443  nomad.example.com      → :8180  admin
          :443  kiwix.example.com      → :8090  kiwix
          :9999 nomad.example.com      → :9999  dozzle (TCP+TLS)
```

## Deploy on proxy host

1. **DNS** — A records to proxy host: `nomad`, `kiwix`, `cyberchef`, `flatnotes`, `kolibri` subdomains
2. **Avoid port conflicts** — do not publish :8090 on the proxy host for other services
3. **Static Traefik** — entrypoint `dozzle: ":9999"` + port `9999:9999` (see [traefik-static-config.snippet.yaml](../traefik-static-config.snippet.yaml))
4. **Dynamic config** — merge [traefik-nomad-apps.snippet.yaml](../traefik-nomad-apps.snippet.yaml); replace `NOMAD_BACKEND` and `*.example.com`
5. **Commit to Git** on the proxy host — uncommitted changes are lost on Docker restart
6. **Verify:**
   ```bash
   curl -sk -o /dev/null -w "%{http_code}\n" https://kiwix.example.com
   curl -sk -o /dev/null -w "%{http_code}\n" https://nomad.example.com:9999
   ```

## Deploy on NOMAD host (this repo)

```bash
cp .env.traefik.example .env   # edit domains
docker compose up -d admin
docker logs nomad_admin 2>&1 | grep configure-app-urls
```

## Switch back to LAN

Use [`.env.lan.example`](../.env.lan.example) and `docker compose up -d admin`.
