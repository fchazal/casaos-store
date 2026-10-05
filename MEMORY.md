# MEMORY.md — CasaOS App Store Project

## Project Overview

- **Name:** CasaOS App Store — Fchazal Store
- **Repository:** `fchazal/casaos-store` on GitHub
- **Purpose:** Custom app store for CasaOS (personal cloud/home server OS). Provides app definitions (Docker Compose + metadata) that CasaOS fetches to populate its App Store UI.
- **Not a traditional app.** This repo is purely declarative: Docker Compose files, JSON metadata, and icons. No application source code lives here.

## Repository Structure

```
.
├── .github/workflows/publish.yml     # CI/CD: publishes store zip as GitHub release
├── .gitignore                         # Ignores .DS_Store
├── README.md                          # Usage documentation
├── MEMORY.md                          # This file
├── build-and-load.sh                  # Build/deploy script (remote build)
├── category-list.json                 # CasaOS store categories
└── Apps/
    ├── journal/
    │   ├── docker-compose.yml         # Compose + x-casaos metadata
    │   └── icon.png                   # App icon
    ├── youtube/
    │   ├── docker-compose.yml         # Compose + x-casaos metadata
    │   └── icon.png                   # App icon
    └── blog/
        ├── docker-compose.yml         # Compose + x-casaos metadata
        └── icon.png                   # App icon
```

## Apps

### youtube (yt-dlp download API)

- **Image:** `yt-dlp-api:latest`
- **Port:** 8000
- **Source repo:** [fchazal/youtube-downloader](https://github.com/fchazal/youtube-downloader)
- **CasaOS ID:** `com.fchazal.youtube`
- **Category:** Personal
- **Architectures:** amd64, arm64
- **Features:** Dockerized yt-dlp HTTP API. Fetch video properties, list formats/qualities, download videos/audio/subtitles into `$DATA_DIR`. Includes ffmpeg and self-updating yt-dlp.
- **Compose volume:** `./data:/data`

### journal (personal journaling PWA)

- **Image:** `journaling-app:latest`
- **Port:** 4000
- **Source repo:** [fchazal/journaling-app](https://github.com/fchazal/journaling-app)
- **CasaOS ID:** `com.fchazal.journal`
- **Category:** Personal
- **Architectures:** amd64, arm64
- **Features:** Self-hosted personal journaling PWA. Mood & energy, daily note, per-type blocks, weight tracking. Markdown storage (Obsidian-compatible), works offline.
- **Compose volume:** `./data:/data`

### blog (personal literary blog)

- **Image:** `fchazal-net:latest`
- **Port:** 3000
- **Source repo:** `/Users/fchazal/Developer/PERSONAL/fchazal.net` (relative to this repo: `../../PERSONAL/fchazal.net`)
- **CasaOS ID:** `com.fchazal.blog`
- **Category:** Personal
- **Architectures:** amd64, arm64
- **Features:** Self-hosted literary blog / carnet (Suppléments d’âme & Bouts d’humanité) — texts, essays, drawings and p5.js works. Markdown content (Obsidian-compatible), RSS/JSON feeds (global + per type), Webmentions, likes, server-side rendering. Built with Vike + React + Fastify.
- **Compose volumes:** `./content:/app/content:ro` (Markdown content), `./data:/app/data` (SQLite likes)
- **Env:** `SITE_URL` (absolute URLs for feeds/webmentions), `WEBMENTION_IO_TOKEN`, `PUBLICATION_WEBHOOK_URL`

## Build & Deployment

### How CasaOS Store Works

- CasaOS uses `go-getter` to fetch custom stores — only **zip archives** or `git::`-prefixed URLs work.
- Store URL (archive): `https://github.com/fchazal/casaos-store/archive/refs/heads/main.zip`
- Categories come from `category-list.json` (currently only "Personal").
- Each app's `x-casaos.category` must match one of those entries.
- CasaOS does **not** use a `store.yml`.

### How Image Building Works

- CasaOS does **not** build images from a compose `build:` section — it only pulls or reuses pre-built images by name.
- The compose files reference images by local name (`yt-dlp-api:latest`, `journaling-app:latest`).
- These images must be pre-loaded into the CasaOS server's Docker daemon.

### Build & Deploy Script (`build-and-load.sh`)

- **Mode:** Remote build (no local Docker required).
- **Flow:**
  1. Uses `rsync` to sync the source repos (`../youtube-downloader`, `../journaling-app`, `../../PERSONAL/fchazal.net`) to the remote server at `/tmp/casaos-build/`.
  2. SSHs into the remote server and runs `docker buildx build --platform linux/amd64 --tag <image> --load <path>` for each app.
- **Options:**
  - `-p <port>` — SSH port (default: 22)
  - `-u` — use sudo for docker on the server
  - `-r <remote-path>` — remote build directory (default: /tmp/casaos-build)
  - `-a <app>` — build only this app (`youtube`, `journal`, `blog`); repeatable
  - Positional: `[user@casaos-host]`
- **Environment variable:** `$CASAOS_HOST` can be used instead of passing `user@casaos-host` as an argument.

### CI/CD (`.github/workflows/publish.yml`)

- **Trigger:** Push to `main` or manual dispatch.
- **Action:** Zips `Apps/`, `category-list.json`, and `README.md` into `store.zip`.
- **Publishes** as a GitHub Release tagged `store` using `softprops/action-gh-release@v2`.
- Does **not** build or push Docker images — that's handled by `build-and-load.sh`.

## CasaOS Compose Metadata (`x-casaos`)

Each `docker-compose.yml` includes an `x-casaos` section consumed by CasaOS:

- `id` — unique app identifier (e.g., `com.fchazal.youtube`)
- `main` — service name in the compose file
- `port_map` — port displayed in CasaOS UI
- `icon` — URL to the app icon (raw GitHub URL)
- `title`, `tagline`, `description` — localized strings
- `category` — must match an entry in `category-list.json`
- `architectures` — supported architectures
- `version`, `update_at` — versioning info
- `website`, `repo`, `support` — links to upstream projects
- `release_notes` — localized release notes

## Key Technical Notes

- The build targets `linux/amd64` for the Docker images.
- Source repos are expected at `../youtube-downloader`, `../journaling-app` and `../../PERSONAL/fchazal.net` (relative to this repo).
- The script uses `rsync -az --delete` to keep remote sources in sync.
- After building, users must reinstall apps in CasaOS to pick up the new images.
- CasaOS host IP/hostname should be set via `$CASAOS_HOST` env var or passed as first positional argument.
