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

## Reverse proxy (Traefik, etc.)

The Command Center can run behind a reverse proxy on your domain. The main UI and Chat work from in-app links. Links to the other apps (Kiwix, CyberChef, Notes, Kolibri) are built inside the container and may open the main page instead of the app when behind a proxy. **Workaround:** open those apps via direct URL (your domain or NOMAD host IP, ports 8090, 8100, 8200, 8300).

---

## Symlinks for Kiwix (Information Library)

NOMAD creates the **Kiwix** container with a bind mount to **`/opt/project-nomad/storage/zim`** on the host. If your project directory is **not** at `/opt/project-nomad` (e.g. you run from `~/Docker/project-nomad`), that path does not exist and Kiwix will see an empty `/data` and fail to start.

**Fix:** create a symlink so `/opt/project-nomad/storage/zim` points at your real ZIM directory.

Replace `YOUR_USER` and path with your actual project path:

```bash
# 1) Create base directory
sudo mkdir -p /opt/project-nomad/storage

# 2) Remove existing zim dir if present (e.g. from a previous install)
sudo rm -rf /opt/project-nomad/storage/zim

# 3) Symlink to your project's ZIM storage (use your real path)
sudo ln -s /home/YOUR_USER/Docker/project-nomad/storage/zim /opt/project-nomad/storage/zim

# 4) Restart Kiwix so it picks up the data
docker restart nomad_kiwix_server
```

Then check that the container stays up and loads ZIM files:

```bash
docker ps | grep nomad_kiwix
docker logs --tail=20 nomad_kiwix_server
```

---

## Custom maps (e.g. Europe)

NOMAD’s built-in map regions are US-only. To use **Europe** (or another region) from [Protomaps](https://protomaps.com/) basemaps:

1. **Get a planet or build `.pmtiles`**  
   - Either download a planet file from the [builds list](https://maps.protomaps.com/builds) (e.g. `20260313.pmtiles`) and use it locally, or  
   - Use the **pmtiles** CLI to extract a region from a remote or local planet file.

2. **Extract Europe with Docker** (example; replace the URL if you use another build):
   ```bash
   mkdir -p pmtiles-work
   cd pmtiles-work

   # From remote planet (if the URL supports range requests):
   docker run --rm -v "$PWD":/data protomaps/go-pmtiles:v1.30.1 \
     extract \
     https://maps.protomaps.com/builds/YYYYMMDD.pmtiles \
     /data/europe.pmtiles \
     --bbox=-10,34,31,72 \
     --maxzoom=14
   ```
   If the remote URL returns 404 or does not support range requests, download the planet file first, put it in `pmtiles-work/`, and run `extract` with a local path, e.g. `/data/20260313.pmtiles`.

3. **Copy the result into NOMAD’s map storage** (path may require `sudo` depending on ownership):
   ```bash
   cd ..   # back to project root
   sudo cp pmtiles-work/europe.pmtiles storage/maps/pmtiles/europe.pmtiles
   sudo chown "$USER:users" storage/maps/pmtiles/europe.pmtiles   # optional: match your user and group
   ```

4. NOMAD will pick up any `.pmtiles` file in `storage/maps/pmtiles/`; no HTTP server or “Download Map File” step is needed if you place the file there.

---

## Updater and project path

The **updater** service mounts the project directory as `/opt/project-nomad` so it can rewrite `compose.yml` when updating. Set **`PROJECT_NOMAD_HOST_PATH`** in `.env` to the **absolute path** of this repo (e.g. `/home/you/Docker/project-nomad`). If unset, it defaults to `/opt/project-nomad`.

---

## What is not in this repo

- **`.env`** – contains secrets; use `.env.example` as a template and never commit `.env`.
- **`storage/`** – ZIM files, maps, MySQL/Redis data, logs; all ignored via `.gitignore`.
- **`pmtiles-work/`** and **`*.pmtiles`** – working files and map tiles; recreated or copied as needed.

---

## Storage permissions

The **admin** container runs as your user (`user: NOMAD_UID:NOMAD_GID`). So that the UI can both **manage apps** (start/stop Kiwix, Ollama, etc. via the Docker socket) and **create files you can delete** (in `storage/`), use your host user UID and the **docker** group GID in `.env`:

- `NOMAD_UID=1000` – your user UID (e.g. 1000 for `ito`)
- `NOMAD_GID=131` – your host **docker** group GID (so the container can access `/var/run/docker.sock`). Find it with `getent group docker`.

With `1000:131`, storage files are owned by you and the Apps page correctly shows installed apps and allows Install/Start/Stop.

**If you already have root-owned files in `storage/`** (from before setting `user:`), fix once with:

```bash
sudo scripts/fix-storage-permissions.sh
```

Do **not** chown `mysql/` or `redis/` – those must stay UID 999 for the database and Redis containers.

---

## Useful commands

```bash
# Start
docker compose up -d

# Stop
docker compose down

# View logs
docker compose logs -f admin

# Restart after changing .env or compose
docker compose up -d
```

---

## License

Upstream Project N.O.M.A.D. is licensed under the [Apache License 2.0](https://github.com/Crosstalk-Solutions/project-nomad/blob/main/LICENSE). This Compose setup follows the same; adapt and use as you like.
