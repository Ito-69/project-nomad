# Updater and project path

The **updater** service mounts the project directory as `/opt/project-nomad` so it can rewrite `compose.yml` when updating. Set **`PROJECT_NOMAD_HOST_PATH`** in `.env` to the **absolute path** of this repo (e.g. `/home/you/Docker/project-nomad`). If unset, it defaults to `/opt/project-nomad`.
