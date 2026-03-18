# Project NOMAD – Docker Compose setup

This repo is a **Docker Compose–based** deployment of [Project N.O.M.A.D.](https://github.com/Crosstalk-Solutions/project-nomad) (Node for Offline Media, Archives, and Data). It runs the Command Center and its core services (MySQL, Redis, Dozzle, updater) without using the official install script, so you can host it on any system with Docker and keep config in version control.

**Upstream:** [Crosstalk-Solutions/project-nomad](https://github.com/Crosstalk-Solutions/project-nomad)

**Tested host:** This stack is installed and run on a **NixOS** host and works without issues (Docker + Docker Compose v2).

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
| Reverse proxy (Traefik, etc.) | [docs/reverse-proxy.md](docs/reverse-proxy.md) |
| Kiwix symlinks (Information Library) | [docs/kiwix-symlinks.md](docs/kiwix-symlinks.md) |
| Custom maps (e.g. Europe) | [docs/custom-maps.md](docs/custom-maps.md) |
| Updater and project path | [docs/updater.md](docs/updater.md) |
| Storage permissions | [docs/storage-permissions.md](docs/storage-permissions.md) |
| Stuck downloads (404) | [docs/stuck-downloads.md](docs/stuck-downloads.md) |
| Bug report (404 / Comprehensive tier) | [docs/bug-report-comprehensive-download-404.md](docs/bug-report-comprehensive-download-404.md) |

---

## What is not in this repo

- **`.env`** – contains secrets; use `.env.example` as a template and never commit `.env`.
- **`storage/`** – ZIM files, maps, MySQL/Redis data, logs; all ignored via `.gitignore`.
- **`pmtiles-work/`** and **`*.pmtiles`** – working files and map tiles; recreated or copied as needed.

---

## License

Upstream Project N.O.M.A.D. is licensed under the [Apache License 2.0](https://github.com/Crosstalk-Solutions/project-nomad/blob/main/LICENSE). This Compose setup follows the same; adapt and use as you like.
