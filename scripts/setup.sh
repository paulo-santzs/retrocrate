#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
GPU="none"
APPLY=false

usage() {
  cat <<'EOF'
Usage: ./scripts/setup.sh [--gpu none|nvidia] [--apply]

Without --apply, RetroCrate only previews the Distrobox plan.
Pass --apply to create the container.
EOF
}

while (($#)); do
  case "$1" in
    --gpu)
      (($# >= 2)) || { echo "Missing value for --gpu." >&2; exit 2; }
      GPU="$2"
      shift 2
      ;;
    --apply)
      APPLY=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "$GPU" in
  none) MANIFEST="$ROOT_DIR/distrobox.ini" ;;
  nvidia) MANIFEST="$ROOT_DIR/distrobox-nvidia.ini" ;;
  *) echo "--gpu must be either 'none' or 'nvidia'." >&2; exit 2 ;;
esac

if [[ "$(uname -s)" != Linux ]]; then
  echo "RetroCrate setup runs on a Linux host. Windows/macOS are not supported as native hosts." >&2
  exit 1
fi

if ! command -v distrobox >/dev/null 2>&1; then
  echo "Distrobox was not found. Install Distrobox and Podman or Docker on the Linux host first." >&2
  exit 1
fi

minimum_distrobox_version="1.8.2.4"
installed_distrobox_version="$(distrobox version 2>&1 | grep -Eo '[0-9]+(\.[0-9]+){2,3}' | head -n 1 || true)"
if [[ -z "$installed_distrobox_version" ]]; then
  echo "Could not determine the installed Distrobox version." >&2
  exit 1
fi
oldest_version="$(printf '%s\n%s\n' "$minimum_distrobox_version" "$installed_distrobox_version" | sort -V | head -n 1)"
if [[ "$oldest_version" != "$minimum_distrobox_version" ]]; then
  echo "Distrobox $installed_distrobox_version is too old; RetroCrate requires $minimum_distrobox_version or newer." >&2
  echo "Update Distrobox on the host, then run this script again." >&2
  exit 1
fi
echo "Distrobox $installed_distrobox_version detected (minimum: $minimum_distrobox_version)."

if ! command -v podman >/dev/null 2>&1 && ! command -v docker >/dev/null 2>&1; then
  echo "No Podman or Docker command was found. Install and configure one container engine first." >&2
  exit 1
fi

echo "Manifest: $MANIFEST"
echo "GPU integration: $GPU"
echo "Preview (no changes will be made):"
distrobox assemble create --file "$MANIFEST" --dry-run

if [[ "$APPLY" != true ]]; then
  echo
  echo "Preview only. To create the container, run this command on Linux:"
  if [[ "$GPU" == nvidia ]]; then
    echo "  ./scripts/setup.sh --gpu nvidia --apply"
  else
    echo "  ./scripts/setup.sh --apply"
  fi
  exit 0
fi

echo
echo "Creating RetroCrate. This downloads an Arch Linux image and installs the listed packages."
distrobox assemble create --file "$MANIFEST"
echo
if [[ -t 0 && -t 1 ]]; then
  echo "Completing first entry and package installation..."
  distrobox enter retrocrate -- bash -lc 'true'
  "$ROOT_DIR/scripts/export-apps.sh"
  echo
  echo "RetroCrate is ready. RetroArch, Dolphin, PPSSPP and MAME were exported to the host app launcher."
else
  echo "The container was created. Complete its first package installation from an interactive terminal:"
  echo "  distrobox enter retrocrate"
  echo "Then export the app launchers with: $ROOT_DIR/scripts/export-apps.sh"
fi
