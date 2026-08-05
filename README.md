# CasaOS App Store — Fchazal Store

CasaOS custom app store: `store.yml` at the root plus one folder per app under
`Apps/`.

## Apps

### youtube — yt-dlp download API

A Dockerized yt-dlp HTTP API: fetch video properties, list formats/qualities,
and download videos, audio and subtitles into a subdirectory of `$DATA_DIR`.

The container image is **built on the CasaOS server** from the
[youtube-downloader](https://github.com/fchazal/youtube-downloader) repository
(no registry needed). If you host that repo elsewhere, update the `build.context`
URL in `Apps/youtube/docker-compose.yml`. Alternatively, publish the image and
replace the `build` block with `image: <registry>/yt-dlp-api:latest`.

### journal — journal personnel

Self-hosted personal journaling PWA: mood & energy, daily note, per-type blocks,
weight tracking. Markdown storage (Obsidian-compatible), works offline.
Built from the [journaling-app](https://github.com/fchazal/journaling-app)
repository on the CasaOS server.

## Install on CasaOS

1. Push this repo to your personal git host (e.g. GitHub).
2. In CasaOS open **App Store** → custom app store (the "+" / settings icon).
3. Paste the repo URL, e.g. `https://github.com/fchazal/casaos-store.git`.
4. Install the **youtube** app (first install builds the image, a few minutes).
5. Open `http://<casaos-host>:8000`.

Downloads land in `/DATA/AppData/youtube/data/<subdir>/...`.

## Layout

```
.
├── store.yml                     # store identity
└── Apps/
    ├── youtube/
    │   ├── docker-compose.yml    # compose + x-casaos store metadata
    │   └── icon.png              # app icon
    └── journal/
        ├── docker-compose.yml    # compose + x-casaos store metadata
        └── icon.png              # app icon
```

Applications live in their own repositories (`youtube-downloader`,
`journaling-app`).
