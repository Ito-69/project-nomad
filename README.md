# Project NOMAD – Docker Compose setup

This repo is a **Docker Compose–based** deployment of [Project N.O.M.A.D.](https://github.com/Crosstalk-Solutions/project-nomad) (Node for Offline Media, Archives, and Data). It runs the Command Center and its core services (MySQL, Redis, Dozzle, updater) without using the official install script, so you can host it on any system with Docker and keep config in version control.

**Upstream:** [Crosstalk-Solutions/project-nomad](https://github.com/Crosstalk-Solutions/project-nomad) — Command Center image: `ghcr.io/crosstalk-solutions/project-nomad:latest` (no separate compose repo upstream; this project wraps it).

**Tested host:** NixOS with Docker Compose v2. Should work on any Linux host with Docker.

---

## What you get

- **NOMAD Command Center** (UI) on port `8180` (configurable)
- **MySQL** and **Redis** for the app
- **Dozzle** for container logs (port `9999`)
- **Updater** sidecar for in-place updates  
Apps (Kiwix, Kolibri, Ollama, etc.) are installed and managed from the UI; their containers are created by NOMAD at runtime.

---

## Requirements

- Docker and Docker Compose (v2)
- Enough disk for app data (ZIM files, maps, etc.)

---

## Quick start

1. **Clone or copy this repo** to your machine (e.g. `~/Docker/project-nomad`).

2. **Create environment file** from the example and set secrets:
   ```bash
   cp .env.example .env
   ```
   Edit `.env`:
   - **APP_KEY:** generate with `openssl rand -hex 32` and paste the result.
   - **DB_PASSWORD**, **MYSQL_ROOT_PASSWORD:** set strong passwords.
   - **NOMAD_URL:** set the URL clients will use (e.g. `http://YOUR_SERVER_IP:8180`).
   - **PROJECT_NOMAD_HOST_PATH:** set to the **absolute** path of this repo (e.g. `/home/you/Docker/project-nomad`) so the updater can find `compose.yml`.

3. **Create storage directories** so the admin container can write logs and data:
   ```bash
   mkdir -p storage/logs
   chmod 775 storage storage/logs
   ```

4. **Start the stack:**
   ```bash
   docker compose up -d
   ```
   Open the UI at `http://localhost:8180` (or your `NOMAD_URL`).

---

## Documentation

Detailed guides are in **`docs/`**:

| Topic | File |
|-------|------|
| Reverse proxy (LAN or Traefik) | [docs/reverse-proxy.md](docs/reverse-proxy.md) |
| Traefik deploy | [docs/traefik.md](docs/traefik.md) |
| Publishing to GitHub | [docs/github-publish.md](docs/github-publish.md) |
| LAN `.env` template | [`.env.lan.example`](.env.lan.example) |
| Traefik `.env` template | [`.env.traefik.example`](.env.traefik.example) |
| Kiwix symlinks (Information Library) | [docs/kiwix-symlinks.md](docs/kiwix-symlinks.md) |
| Updater and project path | [docs/updater.md](docs/updater.md) |
| Storage permissions | [docs/storage-permissions.md](docs/storage-permissions.md) |
| Stuck downloads (404) | [docs/stuck-downloads.md](docs/stuck-downloads.md) |

---

## What is not in this repo

- **`.env`** – secrets and your IPs/domains; use `.env.example` or `.env.lan.example`.
- **`storage/`**, **`mysql/`**, **`redis/`** – runtime data (gitignored).
- **`pmtiles-work/`**, **`*.pmtiles`** – large map files (gitignored).

See [docs/github-publish.md](docs/github-publish.md) for what to commit when publishing.

---

## License

Upstream Project N.O.M.A.D. is licensed under the [Apache License 2.0](https://github.com/Crosstalk-Solutions/project-nomad/blob/main/LICENSE). This Compose setup follows the same; adapt and use as you like.
