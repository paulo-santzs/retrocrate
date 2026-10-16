#!/usr/bin/env bash
set -Eeuo pipefail

BOX_NAME="retrocrate"

if [[ "$(uname -s)" != Linux ]]; then
  echo "Host: unsupported here (this diagnostic expects Linux)."
  exit 1
fi

for tool in distrobox; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf 'Host dependency %-10s OK (%s)\n' "$tool" "$(command -v "$tool")"
  else
    printf 'Host dependency %-10s MISSING\n' "$tool"
    exit 1
  fi
done

if command -v podman >/dev/null 2>&1; then
  printf 'Container engine Podman OK (%s)\n' "$(command -v podman)"
elif command -v docker >/dev/null 2>&1; then
  printf 'Container engine Docker OK (%s)\n' "$(command -v docker)"
else
  echo "Container engine missing (install and configure Podman or Docker)."
  exit 1
fi

if ! distrobox list | grep -Eq '(^|[[:space:]])retrocrate([[:space:]]|$)'; then
  echo "Container '$BOX_NAME' was not found. Run ./scripts/setup.sh --apply first."
  exit 1
fi

echo "Container '$BOX_NAME' found. Checking installed launchers..."
ENTER_FLAGS=()
if [[ "${RETROCRATE_DEBUG:-false}" == true ]]; then
  ENTER_FLAGS+=(--verbose)
fi

distrobox enter "${ENTER_FLAGS[@]}" "$BOX_NAME" -- bash -lc '
  missing=0
  for app in retroarch dolphin-emu PPSSPPSDL mame; do
    if command -v "$app" >/dev/null 2>&1; then
      printf "  %-14s %s\\n" "$app" "$(command -v "$app")"
    else
      printf "  %-14s MISSING\\n" "$app"
      missing=1
    fi
  done
  exit "$missing"
'

echo "Basic checks passed. This does not benchmark GPU acceleration or validate game files/firmware."
