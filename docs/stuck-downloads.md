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

---

## Wikipedia “Complete (Full)” 404 after update

If Easy Startup shows **`wikipedia_en_all_maxi_2024-01.zim`** and **Download failed: 404**, the bundled Wikipedia manifest is outdated: that file no longer exists on Kiwix.

**Fix (local MySQL patch)** — use a build that exists (check [Kiwix Wikipedia folder](https://download.kiwix.org/zim/wikipedia/) for the latest `wikipedia_en_all_maxi_*.zim`), then:

```sql
-- 1) Manifest: option index 5 is usually "all-maxi" (Complete Wikipedia Full)
UPDATE collection_manifests SET spec_data = JSON_SET(
  spec_data,
  '$.options[5].url', 'https://download.kiwix.org/zim/wikipedia/wikipedia_en_all_maxi_2026-02.zim',
  '$.options[5].version', '2026-02',
  '$.options[5].size_mb', 123981
) WHERE type = 'wikipedia';

-- 2) Saved selection row (if present)
UPDATE wikipedia_selections SET
  url = 'https://download.kiwix.org/zim/wikipedia/wikipedia_en_all_maxi_2026-02.zim',
  filename = 'wikipedia_en_all_maxi_2026-02.zim',
  status = 'none'
WHERE option_id = 'all-maxi';
```

Then clear any stuck `bull:downloads` job (see above), **`docker compose restart admin`**, and start the Wikipedia download again from the UI.

**Note:** An app update may refetch the manifest and bring back an old URL; if 404 returns, repeat the patch with the current Kiwix filename.
