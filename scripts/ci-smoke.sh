#!/usr/bin/env bash
set -Eeuo pipefail

# The Ubuntu runner is headless. `script` in the workflow gives Distrobox the
# pseudo-terminal it expects for the first interactive initialization.
./scripts/doctor.sh

distrobox enter retrocrate -- bash -lc '
  set -e
  for package in retroarch dolphin-emu ppsspp mame libretro-mgba libretro-snes9x libretro-genesis-plus-gx libretro-mupen64plus-next libretro-beetle-psx libretro-ppsspp libretro-mame; do
    pacman -Q "$package"
  done
'

./scripts/export-apps.sh
