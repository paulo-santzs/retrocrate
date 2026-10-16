#!/usr/bin/env bash
set -Eeuo pipefail

BOX_NAME="retrocrate"
APPS=(
  /usr/share/applications/com.libretro.RetroArch.desktop
  /usr/share/applications/dolphin-emu.desktop
  /usr/share/applications/PPSSPPSDL.desktop
  /usr/share/applications/mame.desktop
)

if [[ "$(uname -s)" != Linux ]]; then
  echo "This script must run on Linux." >&2
  exit 1
fi
if ! command -v distrobox >/dev/null 2>&1; then
  echo "Distrobox was not found." >&2
  exit 1
fi
if ! distrobox list | grep -Eq '(^|[[:space:]])retrocrate([[:space:]]|$)'; then
  echo "Container '$BOX_NAME' was not found. Run ./scripts/setup.sh --apply first." >&2
  exit 1
fi

for desktop_file in "${APPS[@]}"; do
  if distrobox enter "$BOX_NAME" -- test -f "$desktop_file"; then
    distrobox enter "$BOX_NAME" -- distrobox-export --app "$desktop_file"
    printf 'Exported %s\n' "${desktop_file##*/}"
  else
    printf 'Skipped missing app file: %s\n' "$desktop_file" >&2
  fi
done
