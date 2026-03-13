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

**Version detection:** `scripts/syncovery.sh` fetches version strings from `https://www.syncovery.com/linver_x86_64-Web.tar.gz.txt` and `https://www.syncovery.com/linver_aarch64.tar.gz.txt`, then exports `SYNCOVERY_VERSION`, `SYNCOVERY_MAIN_VERSION`, and download links for both architectures as environment variables used in the `docker buildx build` `--build-arg` flags.

## Container Details

- **Base image:** Ubuntu 24.04
- **Ports:** 8999 (Web GUI), 8889, 8900 (guardian), 8949 (remote service)
- **Volumes:** `/config` (persistent config), `/tmp`, `/machine-id` (persistent machine-id)
- **Default credentials:** username `default`, password `pass`
- **Key env vars:** `TZ` (default: `Europe/Berlin`), `SYNCOVERY_HOME` (default: `/config`)

## Machine ID

Syncovery uses the machine-id for credential encryption — a changed ID invalidates stored credentials. `scripts/dockerfile/files/machine-id.sh` runs at container startup (before Syncovery) and:
1. Generates a new ID from `/proc/sys/kernel/random/uuid` (dashes stripped) if `/machine-id/machine-id` is missing or empty
2. Writes the ID to `/etc/machine-id` and `/var/lib/dbus/machine-id` on every start

Mount `/machine-id` as a volume to persist the ID across container recreations and image updates. Always keep this volume alongside `/config`.

## Documentation

When making changes, always update both `README.md` (user-facing) and `CLAUDE.md` (AI guidance) to reflect the change.

## Jenkins Requirements

- Jenkins agent with `docker` label
- `DOCKER_API_PASSWORD` credential in Jenkins store (for Docker Hub push)
- UrlTrigger plugin for automatic rebuilds on upstream version changes
- Discord webhook for build notifications
