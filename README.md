# CasaOS App Store — Fchazal Store

CasaOS custom app store. Structure expected by CasaOS (AppManagement):

```
.
├── category-list.json            # categories offered by this store
└── Apps/
    ├── youtube/
    │   ├── docker-compose.yml    # compose + x-casaos store metadata
    │   └── icon.png              # app icon
    └── journal/
        ├── docker-compose.yml    # compose + x-casaos store metadata
        └── icon.png              # app icon
```

Note: CasaOS does **not** use a `store.yml`. Categories come from
`category-list.json`, and each app's `x-casaos.category` must match one of
those entries (here: `Personal`).

## Apps

### youtube — yt-dlp download API

A Dockerized yt-dlp HTTP API: fetch video properties, list formats/qualities,
and download videos, audio and subtitles into a subdirectory of `$DATA_DIR`.
Built from the [youtube-downloader](https://github.com/fchazal/youtube-downloader)
repository on the CasaOS server.

### journal — journal personnel

Self-hosted personal journaling PWA: mood & energy, daily note, per-type blocks,
weight tracking. Markdown storage (Obsidian-compatible), works offline.
Built from the [journaling-app](https://github.com/fchazal/journaling-app)
repository on the CasaOS server.

CasaOS does **not** build images from a compose `build:` section — it only pulls
(or reuses) pre-built images by name. The compose files here reference the
images as they exist in the CasaOS server's Docker daemon
(`yt-dlp-api:latest`, `journaling-app:latest`).

## Build & load images on CasaOS (x86_64)

CasaOS installs the app from the `image:` name. If the image is not already on
the server, CasaOS tries to pull it from a registry and fails with
`no such image`. Since these apps are built from local repos, build them for
**amd64** and load them into the server's Docker daemon:

```bash
# local build (x86_64), from this repo directory:
./build-and-load.sh user@casaos-host

# or manually, per app:
docker buildx build --platform linux/amd64 -t yt-dlp-api:latest    --load ../youtube-downloader
docker buildx build --platform linux/amd64 -t journaling-app:latest --load ../journaling-app
docker save yt-dlp-api:latest journaling-app:latest | gzip | ssh user@casaos-host 'gunzip | docker load'
```

Then re-install the app in CasaOS — it will find the local image and skip the
pull. Re-run after any change to an app repo.

## Install on CasaOS

CasaOS fetches the store with `go-getter`, which only handles **zip archives**
(or `git::`-prefixed / `github.com/…` shorthand URLs). A plain
`https://github.com/…/….git` URL is downloaded as a file and the store is
rejected — use the archive URL below.

1. Push this repo to a **public** git host (it is fetched by CasaOS).
2. In CasaOS open **App Store** → custom app store (the "+" / settings icon).
3. Add the store URL (use the archive URL):
   - **archive (recommended):** `https://github.com/fchazal/casaos-store/archive/refs/heads/main.zip`
   - or git-prefixed: `git::https://github.com/fchazal/casaos-store.git`
4. Install the **youtube** / **journal** apps (first install builds the image,
   which takes a few minutes; network access to GitHub is required).
