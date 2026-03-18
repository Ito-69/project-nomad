# Bug report: Computing & Technology - Comprehensive download fails (404)

**Upstream repo:** [Crosstalk-Solutions/project-nomad](https://github.com/Crosstalk-Solutions/project-nomad)

**When to use:** Copy or adapt this into a GitHub issue if the Content Explorer download for "Computing & Technology - Comprehensive" (or similar tier) gets stuck at 0% and admin logs show `Job failed: ..., Error: Request failed with status code 404`.

---

## Summary

Downloading **Computing & Technology - Comprehensive** from the Content Explorer never progresses. The first (or another) file in the pack returns **404** from Kiwix. The failed job is retried by Bull and blocks the queue, so no other downloads start.

## Observed

- **UI:** Active Downloads shows e.g. `devdocs_en_react_2024-01.zim` or `devdocs_en_react_2026-01.zim` at 0%.
- **Admin logs:** `[downloads] Job failed: <job_id>, Error: Request failed with status code 404`
- **Kiwix:** The catalog references ZIM versions that are not present on `download.kiwix.org`. For example:
  - `devdocs_en_react_2024-01.zim` → **404**
  - `devdocs_en_react_2026-01.zim` → **404**
  - Available on Kiwix for devdocs/react are: `devdocs_en_react_2025-10.zim`, `devdocs_en_react_2026-02.zim`

So the **content catalog** used by NOMAD for this tier is out of date or points to wrong version numbers.

## Expected

Either:

1. **Catalog update:** The list of ZIM files for "Computing & Technology - Comprehensive" (and other tiers) should point only to URLs that exist on Kiwix (e.g. use 2025-10 or 2026-02 for React, not 2024-01 or 2026-01), and be updated when Kiwix retires/renames files.

2. **Failure handling:** When a download returns 404, the job could be marked as failed without infinite retries (or removed from the queue) so the queue does not stay blocked and other downloads can proceed.

## Workarounds (user side)

- Clear the stuck job from Redis and restart admin (see [docs/stuck-downloads.md](stuck-downloads.md)).
- Download a specific ZIM manually with wget (e.g. [scripts/download-devdocs-react.sh](../scripts/download-devdocs-react.sh)) and place it in `storage/zim/`.

---

*This file is for reference when opening an upstream issue; it is not meant to be sent as-is. Adjust version numbers and file names if your case differs.*
