# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository automates building and publishing multi-architecture Docker images for **Syncovery** (enterprise backup/sync software) as `stefanruepp/syncoverycl` on Docker Hub. It supports both AMD64 and ARM64 via Docker buildx.

## Build Commands

The build is orchestrated by Jenkins but can be triggered manually:

```bash
# Full build (requires Docker credentials in environment)
bash scripts/start.sh

# Initialize Docker buildx and login
bash scripts/docker_initialize.sh

# Fetch current Syncovery version info
bash scripts/syncovery.sh

# Cleanup buildx cache after build
bash scripts/docker_cleanup.sh
```

There are no tests or linting steps — this is a pure Docker image build project.

## Architecture

**Build pipeline flow:**
1. Jenkins triggers on URL changes (Syncovery version files or Ubuntu base image updates, checked every 30 min)
2. `scripts/start.sh` → `docker_initialize.sh` (Docker login + buildx setup) → `syncovery.sh` (fetch version) → `docker buildx build` (multi-platform)
3. Inside the Dockerfile build: `scripts/dockerfile/build.sh` runs `apt-get.sh`, `tzdata.sh`, `platforms/{amd64,arm64}.sh`, `syncovery.sh`, `cleanup.sh`
4. Container runtime entry point: `scripts/dockerfile/files/start.sh`

**Branch behavior:**
- `master`/`main`: Publishes with `latest` tag + version-specific tags (e.g., `ubuntu-v<version>`, `<main-version>`)
- Other branches: Publishes as test images prefixed with the branch name

**Version detection:** `scripts/syncovery.sh` fetches version strings from `https://www.syncovery.com/linver_x86_64-Web.tar.gz.txt` and `https://www.syncovery.com/linver_aarch64-Web.tar.gz.txt`, then exports `SYNCOVERY_VERSION`, `SYNCOVERY_MAIN_VERSION`, and download links for both architectures as environment variables used in the `docker buildx build` `--build-arg` flags.

The values are read by line number (`awk 'NR==5'` for the version, `NR==3` for the download link), so the script validates them before they are used — everything here ends up in a docker tag or a build argument:
- `curl -fsS` makes an HTTP error a hard failure instead of handing the HTML error page to `awk`.
- `SYNCOVERY_VERSION` has to match `^([0-9]+)(\.[0-9]+)+$`; the capture group is `SYNCOVERY_MAIN_VERSION` (`11.16.2` → `11`).
- Both download links have to start with `https://`.

Any of these failing aborts the build with a message naming the value it got.

## Container Details

- **Base image:** Ubuntu 24.04
- **Default credentials:** username `default`, password `pass`

**Exposed ports** (`EXPOSE` in the `Dockerfile`):

| Port | Purpose |
| --- | --- |
| 8999 | Web GUI (HTTP) |
| 8889 | Cloud authentication |

Everything else (HTTPS, guardian 8900, remote service 8949) is deliberately not `EXPOSE`d — users map those themselves.

**Volumes:**

| Path | Purpose |
| --- | --- |
| `/config` | Persistent syncovery config (relocatable via `SYNCOVERY_HOME`) |
| `/tmp` | Temporary folder |
| `/machine-id` | Persistent machine-id (see Machine ID below) |

**Environment variables** (defaults declared as `ENV` in the `Dockerfile`, documented as a table in `README.md`):

| Variable | Default | Purpose |
| --- | --- | --- |
| `TZ` | `Europe/Berlin` | Timezone (build-time default baked in by `scripts/dockerfile/tzdata.sh`, honoured at runtime by glibc) |
| `SYNCOVERY_HOME` | `/config` | Location of the syncovery config files |
| `SYNCOVERY_SET_*` | none | Arbitrary syncovery settings, see Syncovery Settings below |

## Syncovery Settings

`apply_settings()` in `scripts/dockerfile/files/start.sh` collects every environment variable named `SYNCOVERY_SET_<setting>` (via `compgen -v`), strips the prefix and passes them all to `SyncoveryCL SET` as `/<setting>=<value>` in a **single** call — the syntax documented at https://www.syncovery.com/linux-docs/ (`SyncoveryCL SET /WEBSERVER=localhost /WEBUSER=username /WEBPORT=port ...`).

Notes for future changes:
- The prefix is stripped verbatim, so setting names keep their case (`SYNCOVERY_SET_S3PartSize` → `/S3PartSize`). Do not upper/lowercase them.
- Arguments are built in a bash array and quoted on expansion, so values may contain spaces.
- User-provided settings are applied on **every** start, not only on the first one — the environment always wins over `${SYNCOVERY_HOME}/.Syncovery/Syncovery.cfg`.
- Values of settings whose name contains `PASS` are masked in the startup log (e.g. `WEBPASS`), the real value is still passed to `SyncoveryCL`.
- `/WEBSERVER=0.0.0.0` is added by `apply_settings()` only while `${SYNCOVERY_HOME}/.Syncovery/Syncovery.cfg` does not exist yet **and** the user has not set `SYNCOVERY_SET_WEBSERVER` themselves (which would otherwise produce a duplicate argument). This preserves the behaviour from before the `SYNCOVERY_SET_*` prefix: an existing installation keeps whatever binding is stored in its config. There is deliberately no `ENV SYNCOVERY_SET_WEBSERVER` in the `Dockerfile` — it would always be set and would therefore be applied on every start.
- No setting has a default. If no `SYNCOVERY_SET_*` variable is set and the config file already exists, `SyncoveryCL SET` is not called at all.
- Changing `SYNCOVERY_SET_WEBPORT` does not change the `EXPOSE`d ports — the port mapping has to be adjusted by the user.

## Web GUI Addresses

Syncovery skips the login when the web GUI is opened via `localhost` / `127.0.0.1`. Inside a container that detection only half works: the GUI loads but keeps asking for a login that never succeeds. Every other address (container ip, docker host, any domain name - even one resolving to `127.0.0.1`) behaves normally. This is syncovery behaviour and cannot be fixed from here, so the container only points the user at the addresses that do work.

`scripts/dockerfile/files/webgui-hint.sh` runs at the end of `start()` in `scripts/dockerfile/files/start.sh` (after `SyncoveryCL start`, so the config file exists) and prints:
- one line per address docker gave the container, read from `getent hosts $(hostname)` - docker writes one `/etc/hosts` entry per attached network. Empty with `--network host` / `--network none`, then `hostname -I` is used as fallback and the addresses are labelled `(this host)`.
- the gateway of the default route (`/proc/net/route`, little endian hex) - the docker host on a bridge network. Deliberately **not** printed when no docker managed address was found, because with `--network host` the default gateway is the router of the host, not the host itself.
- `syncovery.c.loopdns.de` (constant `WEBGUI_LOOPDNS` in the script) - a public dns name, resolvable by anyone (loopdns.de is a normal internet service, not a local-only resolver), pointing to `127.0.0.1`. The request ends up on the loopback interface of the machine running the browser, but Syncovery sees a name instead of `localhost` and the login works.
- a closing note that names for **other** local addresses (container ip, docker host, ...) can be created with an account on `https://loopdns.de` (constant `WEBGUI_LOOPDNS_SITE`).

The port comes from `SYNCOVERY_SET_WEBPORT`, then from the config, then the default `8999`. `${SYNCOVERY_HOME}/.Syncovery/Syncovery.cfg` is a **sqlite database** (tables `SECTIONS` / `DATA`), not an ini file — the web port is `Port1` in section `WEBSERVER` (the binding is `IP1` there). It is read with `sqlite3 "file:...?mode=ro"` so the running Syncovery is not disturbed; `sqlite3` is installed by `scripts/dockerfile/apt-get.sh` anyway.

Notes for future changes:
- The image has no `iproute2`, the addresses are collected with what the base image ships (`hostname`, `getent`, `awk`, `/proc/net/route`).
- The ipv4 filter is written out as `[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+` on purpose: mawk 1.3.4 (the `awk` of the base image) does not reliably match the equivalent `([0-9]+\.){3}` interval form and silently drops addresses.
- The printed port is always the port **inside** the container. A different host port (`-p 18999:8999`) cannot be detected from in here.
- The hint is informational only, it never fails the start.

## Healthcheck

The `Dockerfile` has a `HEALTHCHECK` running `pgrep -x SyncoveryCL`. It exists because `scripts/dockerfile/files/start.sh` waits on the backgrounded `tail -f`, not on Syncovery — a daemon that dies leaves PID 1 alive and the container would otherwise look healthy forever.

Deliberately a process check and **not** a request against the web GUI: the port, the binding and whether the web server runs at all can be changed inside Syncovery without any environment variable, so an HTTP check would mark working containers of existing users unhealthy after an image update. The trade-off is that a hung-but-alive daemon is not detected. `pgrep` comes from `procps` in the base image.

## Machine ID

Syncovery uses the machine-id for credential encryption — a changed ID invalidates stored credentials. `scripts/dockerfile/files/machine-id.sh` runs at container startup (before Syncovery) and:
1. Generates a new ID from `/proc/sys/kernel/random/uuid` (dashes stripped) if `/machine-id/machine-id` is missing or empty
2. Writes the ID to `/etc/machine-id` and `/var/lib/dbus/machine-id` on every start

Mount `/machine-id` as a volume to persist the ID across container recreations and image updates. Always keep this volume alongside `/config`.

The script warns at startup when `/machine-id` is not on a volume of the user's own. Because the `Dockerfile` declares `VOLUME [ ... "/machine-id" ]`, docker always mounts *something* there, so `mountpoint` alone is not enough: the check reads `/proc/self/mountinfo` and treats an anonymous volume (source `/var/lib/docker/volumes/<64 hex chars>/_data`) the same as no volume at all, since it is discarded together with the container.

## Documentation

When making changes, always update both `README.md` (user-facing) and `CLAUDE.md` (AI guidance) to reflect the change.

## Jenkins Requirements

- Jenkins agent with `docker` label
- `DOCKER_API_PASSWORD` credential in Jenkins store (for Docker Hub push)
- UrlTrigger plugin for automatic rebuilds on upstream version changes
- Discord webhook for build notifications
