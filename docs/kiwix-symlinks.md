# Symlinks for Kiwix (Information Library)

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
