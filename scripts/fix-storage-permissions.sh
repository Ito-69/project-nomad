#!/usr/bin/env bash
# Fix ownership of storage and related dirs so the host user (ito) can delete/manage
# files from the UI or command line. Containers (root) can still write.
# Run with: sudo /path/to/fix-storage-permissions.sh
# Do NOT chown mysql/ or redis/ – those must stay 999 for the containers.

set -e
PROJECT_DIR="${PROJECT_DIR:-/home/ito/Docker/project-nomad}"
USER="${RUN_AS_USER:-ito}"
GROUP="${RUN_AS_GROUP:-users}"

if [[ "$(id -u)" != 0 ]]; then
  echo "Run with sudo so ownership can be changed."
  exit 1
fi

echo "Fixing ownership to ${USER}:${GROUP} in ${PROJECT_DIR}"
echo "  - storage/ (zim, maps, logs, ollama, etc.)"
echo "  - nomad-disk-info.json (if present)"
echo ""

# storage – everything the UI and user need to manage
if [[ -d "$PROJECT_DIR/storage" ]]; then
  chown -R "${USER}:${GROUP}" "$PROJECT_DIR/storage"
  echo "  chown -R ${USER}:${GROUP} storage/"
fi

# optional: disk info file/dir used by admin
for f in "$PROJECT_DIR/nomad-disk-info.json" "$PROJECT_DIR/storage/nomad-disk-info.json"; do
  if [[ -e "$f" ]]; then
    chown -R "${USER}:${GROUP}" "$f"
    echo "  chown ${USER}:${GROUP} $f"
  fi
done

echo "Done. You can now delete content from the UI or from the host as ${USER}."
echo "Note: New downloads from NOMAD UI will again be root-owned; re-run this script if needed."
