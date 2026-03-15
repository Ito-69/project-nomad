#!/usr/bin/env bash
# Download devdocs_en_man_2026-01.zim (~28 MB) from Kiwix into storage/zim.
# Use this to replace a broken/empty copy that causes Kiwix to crash.

set -e
ZIM_DIR="/home/ito/Docker/project-nomad/storage/zim"
URL="https://download.kiwix.org/zim/devdocs/devdocs_en_man_2026-01.zim"
FILE="${ZIM_DIR}/devdocs_en_man_2026-01.zim"

mkdir -p "$ZIM_DIR"
cd "$ZIM_DIR"

echo "Downloading devdocs_en_man_2026-01.zim (~28 MB) to $FILE"
wget -c --progress=bar:force:noscroll -O "$FILE" "$URL"

echo "Done: $FILE"
echo "If Kiwix container uses root, run: sudo chown root:root $FILE"
echo "Then: docker restart nomad_kiwix_server"
