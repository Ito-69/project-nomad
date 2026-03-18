#!/usr/bin/env bash
# Download devdocs_en_react from Kiwix into storage/zim.
# Kiwix has 2025-10 (2.4M) and 2026-02 (2.6M). This script uses the latest: 2026-02.
# The UI may show 2024-01 or 2026-01 – those versions do not exist on Kiwix (404).

set -e
ZIM_DIR="${ZIM_DIR:-/home/ito/Docker/project-nomad/storage/zim}"
VERSION="2026-02"
URL="https://download.kiwix.org/zim/devdocs/devdocs_en_react_${VERSION}.zim"
FILE="${ZIM_DIR}/devdocs_en_react_${VERSION}.zim"

mkdir -p "$ZIM_DIR"
cd "$ZIM_DIR"

echo "Downloading devdocs_en_react_${VERSION}.zim (~2.6 MB) to $FILE"
wget -c --progress=bar:force:noscroll -O "$FILE" "$URL"

echo "Done: $FILE"
echo "Restart Kiwix to pick up the file: docker restart nomad_kiwix_server"
