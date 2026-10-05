# CasaOS App Store — Fchazal Store

CasaOS custom app store. Structure expected by CasaOS (AppManagement):

```
.
├── category-list.json            # categories offered by this store
└── Apps/
    ├── youtube/
    │   ├── docker-compose.yml    # compose + x-casaos store metadata
    │   └── icon.png              # app icon
    ├── journal/
    │   ├── docker-compose.yml    # compose + x-casaos store metadata
    │   └── icon.png              # app icon
    └── blog/
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

### blog — carnet littéraire

Self-hosted literary blog / carnet (Suppléments d’âme & Bouts d’humanité):
texts, essays, drawings and p5.js works. Markdown content (Obsidian-compatible),
RSS/JSON feeds, Webmentions, likes, server-side rendering.
Built from the [fchazal.net](https://github.com/fchazal/casaos-store)
project (Vike + React + Fastify) on the CasaOS server.

CasaOS does **not** build images from a compose `build:` section — it only pulls
(or reuses) pre-built images by name. The compose files here reference the
images as they exist in the CasaOS server's Docker daemon
(`yt-dlp-api:latest`, `journaling-app:latest`, `fchazal-net:latest`).

## Build & deploy images on CasaOS (remote build)

CasaOS installs the app from the `image:` name. If the image is not already on
the server, CasaOS tries to pull it from a registry and fails with
`no such image`. Since these apps are built from source repos, the build
script syncs source code to the remote server and builds there — no local
Docker required.

```bash
# sync sources and build on the remote server:
./build-and-load.sh user@casaos-host

# options:
#   -p <port>          SSH port (default: 22)
#   -u                 use sudo for docker on the server
#   -r <remote-path>   remote build directory (default: /tmp/casaos-build)
#   -a <app>           build only this app (youtube, journal, blog); repeatable

# example with custom port and sudo:
./build-and-load.sh -p 2222 -u user@casaos-host

# example with custom remote path:
./build-and-load.sh -r /opt/builds user@casaos-host

# build a single app:
./build-and-load.sh -a blog user@casaos-host
```

The script uses `rsync` to copy the source repos (`../youtube-downloader`,
`../journaling-app`, and `../../PERSONAL/fchazal.net`) to the remote server,
then runs `docker buildx build --platform linux/amd64` there. Re-run after any
change to an app repo.

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
4. Install the **youtube** / **journal** / **blog** apps (first install builds the image,
   which takes a few minutes; network access to GitHub is required).
   For **blog**, also set the `./content` volume (your synced Markdown/Obsidian
   content) and the `SITE_URL` environment variable.
