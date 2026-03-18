# Storage permissions

The **admin** container runs as your user (`user: NOMAD_UID:NOMAD_GID`). So that the UI can both **manage apps** (start/stop Kiwix, Ollama, etc. via the Docker socket) and **create files you can delete** (in `storage/`), use your host user UID and the **docker** group GID in `.env`:

- `NOMAD_UID=1000` – your user UID (e.g. 1000 for `ito`)
- `NOMAD_GID=131` – your host **docker** group GID (so the container can access `/var/run/docker.sock`). Find it with `getent group docker`.

With `1000:131`, storage files are owned by you and the Apps page correctly shows installed apps and allows Install/Start/Stop.

**If you already have root-owned files in `storage/`** (from before setting `user:`), fix once with:

```bash
sudo scripts/fix-storage-permissions.sh
```

Do **not** chown `mysql/` or `redis/` – those must stay UID 999 for the database and Redis containers.
