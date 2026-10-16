#!/usr/bin/env bash
set -Eeuo pipefail

BOX_NAME="retrocrate"

if [[ "$(uname -s)" != Linux ]]; then
  echo "This script must run on Linux." >&2
  exit 1
fi
if ! command -v distrobox >/dev/null 2>&1; then
  echo "Distrobox was not found." >&2
  exit 1
fi

cat <<EOF
This removes only the Distrobox container named '$BOX_NAME'.
RetroCrate uses your host home directory; this script will not delete ROMs,
BIOS files, saves, configuration, or any host directories.
EOF
read -r -p "Type '$BOX_NAME' to continue: " confirmation
if [[ "$confirmation" != "$BOX_NAME" ]]; then
  echo "Cancelled; nothing was removed."
  exit 0
fi

distrobox rm --name "$BOX_NAME"
echo "Container '$BOX_NAME' removal requested. Host files were left untouched."
