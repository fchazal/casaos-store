#!/usr/bin/env bash
set -euo pipefail

# Usage: ./build-and-load.sh [-p <port>] [-u] [-r <remote-path>] [-a <app>]... [user@casaos-host]
# Builds the app images for linux/amd64 on the remote server and loads them
# into the CasaOS server's Docker daemon. Source repos are rsync'd to the
# remote server before building (no local Docker required).
# -u : use sudo for docker on the server (needs passwordless sudo:
#      `sudo -n docker ps` must work; otherwise run `usermod -aG docker $USER`).
# -r : remote base path to sync sources into (default: /tmp/casaos-build).
# -a : build only this app (can be repeated). Available: youtube, journal, blog.
#      If omitted, all apps are built.

PORT=22
SUDO=""
REMOTE_BASE="/tmp/casaos-build"
SELECTED_APPS=()
while [[ "$#" -gt 0 && "${1:-}" == -* ]]; do
  case "$1" in
    -p) PORT="$2"; shift 2 ;;
    -u) SUDO="sudo "; shift ;;
    -r) REMOTE_BASE="$2"; shift 2 ;;
    -a) SELECTED_APPS+=("$2"); shift 2 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done

HOST="${1:-${CASAOS_HOST:?set CASAOS_HOST or pass user@host as first arg}}"

# app definitions: name -> source dir (relative to this repo) -> image tag
NAMES=(youtube journal blog)
APP_DIRS=(../youtube-downloader ../journaling-app ../../PERSONAL/fchazal.net)
IMAGES=(yt-dlp-api:latest journaling-app:latest fchazal-net:latest)

# filter to selected apps
if [[ ${#SELECTED_APPS[@]} -gt 0 ]]; then
  FILTERED_DIRS=()
  FILTERED_IMAGES=()
  for sel in "${SELECTED_APPS[@]}"; do
    found=false
    for i in "${!NAMES[@]}"; do
      if [[ "${NAMES[$i]}" == "$sel" ]]; then
        FILTERED_DIRS+=("${APP_DIRS[$i]}")
        FILTERED_IMAGES+=("${IMAGES[$i]}")
        found=true
        break
      fi
    done
    if ! $found; then
      echo "unknown app: $sel (available: ${NAMES[*]})" >&2; exit 1
    fi
  done
  APP_DIRS=("${FILTERED_DIRS[@]}")
  IMAGES=("${FILTERED_IMAGES[@]}")
fi

ssh_cmd() {
  ssh -p "$PORT" "$HOST" "$@"
}

rsync_cmd() {
  rsync -az --delete -e "ssh -p $PORT" "$@"
}

echo "==> creating $HOST:$REMOTE_BASE"
ssh_cmd "mkdir -p '$REMOTE_BASE'"

echo "==> syncing sources to $HOST:$REMOTE_BASE"
for src in "${APP_DIRS[@]}"; do
  dest="$(basename "$src")"
  echo "    rsync $src"
  rsync_cmd "$src/" "$HOST:$REMOTE_BASE/$dest/"
done

echo "==> building images on $HOST"
for i in "${!APP_DIRS[@]}"; do
  dest="$(basename "${APP_DIRS[$i]}")"
  img="${IMAGES[$i]}"
  echo "    build --platform linux/amd64 $dest -> $img"
  ssh_cmd "${SUDO}docker buildx build --platform linux/amd64 --tag '$img' --load '$REMOTE_BASE/$dest'"
done

echo "==> done. Réinstalle les apps dans CasaOS (App Store)."
