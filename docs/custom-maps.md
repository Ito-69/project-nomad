# Custom maps (e.g. Europe)

NOMAD's built-in map regions are US-only. To use **Europe** (or another region) from [Protomaps](https://protomaps.com/) basemaps:

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

3. **Copy the result into NOMAD's map storage** (path may require `sudo` depending on ownership):
   ```bash
   cd ..   # back to project root
   sudo cp pmtiles-work/europe.pmtiles storage/maps/pmtiles/europe.pmtiles
   sudo chown "$USER:users" storage/maps/pmtiles/europe.pmtiles   # optional: match your user and group
   ```

4. NOMAD will pick up any `.pmtiles` file in `storage/maps/pmtiles/`; no HTTP server or "Download Map File" step is needed if you place the file there.
