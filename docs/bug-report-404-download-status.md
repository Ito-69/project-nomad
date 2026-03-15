# Bug report: Download stays "open" when URL returns 404

**Repository:** [Crosstalk-Solutions/project-nomad](https://github.com/Crosstalk-Solutions/project-nomad)  
**Submit at:** https://github.com/Crosstalk-Solutions/project-nomad/issues/new

---

## Свързани issues (проверено)

- **#269** (closed) — „Stale URL: devdocs_en_react_2026-01.zim returns 404“ — поправиха само URL-а; там също се споменава „No UI indication“ и „Failed job blocks re-queue“. Нашият bug е по-общ: при **всяка** 404 UI/DB не се обновяват.
- **#127** (closed) — „Curated collection URLs can become stale“ — Phase 1 беше „report failed downloads to the user in the UI“. Този report описва конкретно че това все още не е имплементирано: download остава „отворен“ вместо да се маркира като failed.

**Заключение:** Няма отворен issue със същата формулировка. Има смисъл да се отвори нов, като в описанието се цитира #127 (и при желание #269).

---

## Title

**When a ZIM download returns 404, the download should be marked as failed instead of staying open/active**

---

## Description

When a download job fails with **HTTP 404** (e.g. the ZIM file URL from the catalog no longer exists on the server), the UI continues to show the download as **active**:

- **Content Explorer (Wikipedia):** The blue "Downloading Wikipedia..." bar stays visible; in the DB, `wikipedia_selections.status` remains `downloading` instead of being set to `failed`.
- **Kiwix Library (Browse):** The file appears under "Active Downloads" with 0% progress and never clears.

The Bull queue job correctly fails and is moved to `failed` (and may retry), but the **application state** (DB and/or whatever the UI reads) is not updated to reflect the failure. So the user sees a stuck download with no indication that it failed due to 404.

---

## Steps to reproduce

1. Start a download for a ZIM whose URL returns 404 (e.g. an outdated catalog entry: `wikipedia_en_all_maxi_2024-01.zim`, or `devdocs_en_react_2026-01.zim` from Kiwix Library).
2. Observe: the download starts (progress bar / "Active Downloads" entry appears).
3. The worker fails with `Request failed with status code 404` (visible in admin container logs).
4. **Actual:** The download bar / Active Downloads entry remains visible and never shows "Failed" or disappears.
5. **Expected:** On 404 (or any job failure), the download should be marked as failed in the UI and removed from "active" state (e.g. update DB status to `failed`, clear or update the active-downloads view).

---

## Expected behavior

- When a download job fails (including 404), the backend should update the relevant state (e.g. `wikipedia_selections.status` or the equivalent for library downloads) to `failed` (or similar).
- The UI should show the failure (e.g. "Download failed" or remove the entry from "Active Downloads") so the user knows they need to pick another file or source.

---

## Actual behavior

- The job fails in the Bull queue (logs: `Job failed: ..., Error: Request failed with status code 404`).
- The UI still shows "Downloading..." or the file in "Active Downloads" at 0%, with no failure message.
- Only manual intervention (clearing the failed job from Redis and, for Wikipedia, updating `wikipedia_selections.status` to `failed` in the DB) restores the UI.

---

## Environment

- **Deployment:** Docker Compose (image `ghcr.io/crosstalk-solutions/project-nomad:latest`).
- **Observed in:** Content Explorer (Wikipedia selection) and Kiwix Library "Browse" downloads.
- **Queue:** Bull (Redis); failed jobs end up in `bull:downloads:failed`.

---

## Suggested fix (for maintainers)

In the download job handler (when the job fails with 404 or other errors):

1. **Wikipedia / Content Explorer:** Update `wikipedia_selections` (or equivalent) so the row for this download has `status = 'failed'` (and optionally store the error reason if desired).
2. **Kiwix Library / Active Downloads:** Ensure the UI’s "Active Downloads" is driven by actual queue state (active + completed/failed). When a job fails, it should no longer appear as "active"; if the UI caches or derives from another store, that store should be updated on job failure so the download is shown as failed or removed from the active list.

Thank you for maintaining Project N.O.M.A.D.

---

## Какво да попълниш във формуляра за bug report

Ако използваш официалния template с полетата от скрийншота, ето какво да сложиш:

### Docker Version
```
Docker version 28.5.2, build v28.5.2
```
*(или изхода от `docker --version` при теб)*

### Do you have a dedicated GPU?
**No** (или Yes ако имаш)

### GPU Model (if applicable)
*(празно ако нямаш)*

### System Specifications
```
CPU: [напиши модел, напр. от lscpu]
RAM: [напр. 16 GB]
Available Disk Space: [напр. 500 GB свободно в storage/zim]
GPU (if any): None
```
*Важно: при download проблеми „Available Disk Space“ е най-релевантно.*

### Service Status (if relevant)
```
nomad_admin           Up 12 minutes (healthy)
nomad_redis           Up 20 minutes (healthy)
nomad_mysql           Up 20 minutes (healthy)
nomad_updater         Up 20 minutes
nomad_kiwix_server    Up 44 minutes
```
*(или пълен изход от: `docker ps --format "table {{.Names}}\t{{.Status}}"` за контейнерите project-nomad)*

### Relevant Logs
```
[ info ] [downloads] Processing job: 036896ff409c00ac of type: run-download
[ error ] [downloads] Job failed: 036896ff409c00ac, Error: Request failed with status code 404
[ info ] [downloads] Processing job: 036896ff409c00ac of type: run-download
[ error ] [downloads] Job failed: 036896ff409c00ac, Error: Request failed with status code 404
```
*(или последните редове от `docker logs nomad_admin --tail=50` където се вижда същият pattern за друг job)*

### Browser Console Errors (if UI issue)
```
N/A — the issue is backend state: the UI shows "Downloading" because the status in DB/Redis is not updated to "failed" after a 404. No errors appear in the browser console.
```
*(or paste any actual errors from F12 if you have them)*

### Additional Context (ready-to-paste)

Copy the block below into the **Additional Context** field:

```
Related: #127 (graceful error handling), #269 (stale devdocs URL — same symptom).

**Suggested fix (for maintainers)**

In the download job handler (when the job fails with 404 or other errors):

1. **Wikipedia / Content Explorer:** Update `wikipedia_selections` (or equivalent) so the row for this download has `status = 'failed'` (and optionally store the error reason if desired).
2. **Kiwix Library / Active Downloads:** Ensure the UI's "Active Downloads" is driven by actual queue state (active + completed/failed). When a job fails, it should no longer appear as "active"; if the UI caches or derives from another store, that store should be updated on job failure so the download is shown as failed or removed from the active list.
```
