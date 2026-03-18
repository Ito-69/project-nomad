# Stuck downloads (404)

If **Active Downloads** shows a file at 0% and new downloads never start, the download worker is usually blocked by a job that fails with **404** (the ZIM file no longer exists on Kiwix or the catalog is outdated). The failed job is retried by Bull and blocks the queue.

**1. Confirm in admin logs:**

```bash
docker compose logs admin --tail=50 | grep -E 'downloads|404|Job failed'
```

If you see `Job failed: <id>, Error: Request failed with status code 404`, note the job id (e.g. `036896ff409c00ac`).

**2. Remove the stuck job from Redis** (replace `JOB_ID` with the id from the logs):

```bash
docker exec nomad_redis redis-cli LREM bull:downloads:active 1 JOB_ID
docker exec nomad_redis redis-cli ZREM bull:downloads:failed JOB_ID
docker exec nomad_redis redis-cli ZREM bull:downloads:wait JOB_ID
docker exec nomad_redis redis-cli DEL bull:downloads:JOB_ID bull:downloads:JOB_ID:lock
```

**3. Restart admin** so it drops in-memory state:

```bash
docker compose restart admin
```

After that, try a different tier (e.g. Essential or Standard) or wait for an upstream catalog update; the Comprehensive tier may reference a ZIM that was removed from Kiwix.
