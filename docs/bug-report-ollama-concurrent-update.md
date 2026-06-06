# Bug report: Service update fails when Update is triggered concurrently (nomad_ollama)

**Upstream repo:** [Crosstalk-Solutions/project-nomad](https://github.com/Crosstalk-Solutions/project-nomad)

**Filed as:** [#931 – nomad_ollama service update fails on concurrent Update clicks (Docker 304/400)](https://github.com/Crosstalk-Solutions/project-nomad/issues/931) (2026-05-21)

**Maintainer note (2026-06-06):** Backend already rejects a second update while one is in progress; the main gap is UI (disable Update + show pull progress during large pulls). Fix for failed-update rollback is in review upstream.

**When to use:** Copy or adapt this into a GitHub issue if updating **AI Assistant (nomad_ollama)** appears stuck on "Pulling image…", shows "Update failed" in Installation Activity, or the UI still offers an update after the container was recreated.

---

## Summary

Updating `nomad_ollama` via the Command Center **Update** button can fail when the update workflow runs more than once at the same time (e.g. user clicks Update again while a large image pull is in progress). `DockerService` does not appear to serialize per-service updates, leading to Docker API race errors. The UI can look "stuck" during a multi‑GB image pull even when work is still in progress.

## Environment

- **NOMAD version:** 1.32.0 (admin image `ghcr.io/crosstalk-solutions/project-nomad:latest`)
- **Service:** `nomad_ollama` (AI Assistant)
- **Target image:** `ollama/ollama:0.24.0` (~6.5 GB)
- **Host:** Linux, Docker Compose deployment, **no NVIDIA GPU** (CPU-only Ollama — unrelated to the failure)

## Steps to reproduce

1. Install AI Assistant (`nomad_ollama`) at an older tag (e.g. `ollama/ollama:0.22.1`).
2. Wait until Command Center shows an available update (e.g. `0.22.1 → 0.24.0`).
3. Click **Update** once; wait until Installation Activity shows `Pulling image ollama/ollama:0.24.0...` (can take several minutes).
4. Click **Update** again (or click Update on another service and return) before the first update completes.
5. Optionally use **Force Reinstall** while an update is in flight.

## Observed

**UI / Installation Activity**

- Stays on `Pulling image ollama/ollama:0.24.0...` for a long time (expected for large image, but no progress indicator).
- Eventually may show `Update failed. Check server logs for details.`
- `CheckServiceUpdatesJob` can still report `0.22.1 → 0.24.0` after a failed attempt until a later successful run.
- **Force Reinstall** recreated the container from the DB record (`ollama/ollama:0.22.1`) even while `0.24.0` was already pulled locally.

**Admin logs (`storage/logs/admin.log`) — concurrent stop/rename errors**

```
[DockerService] [nomad_ollama] update-pulling: Pulling image ollama/ollama:0.24.0...
[DockerService] [nomad_ollama] update-stopping: Stopping current container...
[DockerService] [nomad_ollama] update-stopping: Stopping current container...
[DockerService] [nomad_ollama] update-stopping: Stopping current container...
[DockerService] [nomad_ollama] update-rollback: Update failed. Check server logs for details.
[DockerService] Update failed for nomad_ollama: (HTTP code 304) container already stopped
[DockerService] Update failed for nomad_ollama: (HTTP code 400) unexpected - Renaming a container with the same name as its current name
```

Same pattern seen on earlier versions (e.g. `0.18.x` → `0.18.3`) with identical HTTP 304/400 errors when `update-stopping` was logged three times within milliseconds.

**Outcome after retries:** A subsequent single update eventually logged `Successfully updated nomad_ollama to 0.24.0` and the running container reported `{"version":"0.24.0"}` via the Ollama API.

## Expected

1. **Serialization:** Only one update (or reinstall) per `service_name` at a time; duplicate requests should be ignored or queued.
2. **UI:** Disable the Update button (and show progress) while `installation_status` is not `idle`, especially during image pull.
3. **Idempotent Docker steps:** Stopping an already-stopped container and rename/create should not fail the whole job (or should use a single atomic recreate pattern).
4. **Force Reinstall:** Should not downgrade to an older `container_image` from DB if a newer image tag is already present locally / update was in progress.

## Suggested fix (upstream)

- Add a per-service mutex / lock in `DockerService` for `update` and `forceReinstall`.
- Return HTTP 409 or a clear message if an update is already running.
- In the frontend, disable Update while installation/update activity is active.
- Consider `docker compose`-style recreate (remove + create with new image) instead of stop → rename → create when parallel requests are possible.

## Workarounds (user side)

1. Click **Update** only once; wait 5–15 minutes for large Ollama images.
2. Check logs: `grep nomad_ollama storage/logs/admin.log | tail -30`
3. Verify container: `docker inspect nomad_ollama --format '{{.Config.Image}}'`
4. If stuck, stop clicking Update; when pull finishes, try one more Update or restart the `nomad_admin` container after confirming the new image exists: `docker images ollama/ollama`

---

*Filed from a self-hosted Compose deployment; adjust versions if your case differs.*
