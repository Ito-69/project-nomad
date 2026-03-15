#!/usr/bin/env bash
# Download Wikipedia Full (all articles + images) via wget into storage/zim.
# File: wikipedia_en_all_maxi_2026-02.zim (~115 GB). Resume supported with -c.

set -e
ZIM_DIR="/home/ito/Docker/project-nomad/storage/zim"
URL="https://download.kiwix.org/zim/wikipedia/wikipedia_en_all_maxi_2026-02.zim"
FILE="${ZIM_DIR}/wikipedia_en_all_maxi_2026-02.zim"

mkdir -p "$ZIM_DIR"
cd "$ZIM_DIR"

echo "Downloading Wikipedia Full to $FILE"
echo "Size: ~115 GB. You can stop and resume later with the same command."
wget -c --progress=bar:force:noscroll -O "$FILE" "$URL"

echo "Done: $FILE"
