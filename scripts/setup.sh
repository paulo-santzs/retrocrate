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
echo "The container was created. Its first entry installs the packages in the manifest."
echo "Run this from a normal interactive Linux terminal and wait for setup to finish:"
echo "  distrobox enter retrocrate"
echo "Then, if needed, export the app launchers with: ./scripts/export-apps.sh"
