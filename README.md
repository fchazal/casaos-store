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

Both apps `build` their image from the app repo's git URL. If you host those
repos elsewhere, update the `build.context` URLs. Alternatively, publish the
images and replace `build` with `image: <registry>/...:latest`.

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
