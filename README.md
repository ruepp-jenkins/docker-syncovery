# General

This is a private hobby project. It does nothing more than pack the Syncovery software into a docker container.

It is **not affiliated with, endorsed by or supported by [Syncovery](https://www.syncovery.com/)** - all rights to Syncovery itself belong to its makers. For questions about the software (and for your license) please turn to them, not to me.

I built this purely for my own setup and simply share it in case someone else finds it useful. Everyone is free to use it, but it comes as it is: no guarantee, no warranty and no support. Use it at your own risk.

# Project

Github: https://github.com/MyUncleSam/docker-syncovery

Docker: https://hub.docker.com/repository/docker/stefanruepp/syncoverycl

# Paths

| Path | Description |
| --- | --- |
| `/config` | Contains the syncovery config files (can be moved with `SYNCOVERY_HOME`) |
| `/tmp` | Default temporary folder for syncovery |
| `/machine-id` | Stores the persistent machine-id (see [Machine ID](#machine-id) below) |

If your syncovery should work with files on the host filesystem, make sure to bind them into your container (see examples below, just extend the volumes / -v parts).

# Environment variables

| Variable | Default | Description | Examples |
| --- | --- | --- | --- |
| `TZ` | `Europe/Berlin` | Timezone used by syncovery (see [Time / Date](#time--date) below) | `Europe/Berlin`, `Africa/Windhoek`, `America/Costa_Rica` |
| `SYNCOVERY_HOME` | `/config` | Location of the syncovery config files (changing should work but was never tested - so use at your own risk) | `/config`, `/data/syncovery` |
| `SYNCOVERY_SET_*` | none | Any syncovery setting you want to apply (see [Syncovery settings](#syncovery-settings) below) | `SYNCOVERY_SET_WEBPORT=1234`, `SYNCOVERY_SET_WEBUSER=myuser` |

Using the `SYNCOVERY_SET_*` prefix you can set nearly every syncovery setting. The prefix is removed and the rest is handed over to `SyncoveryCL SET` as `/<setting>=<value>` - all of them within one single call.

Example - move the web GUI to another port and use your own credentials:

```yaml
environment:
  SYNCOVERY_SET_WEBPORT: 1234
  SYNCOVERY_SET_WEBUSER: myuser
  SYNCOVERY_SET_WEBPASS: mypassword
```

results in:

```sh
SyncoveryCL SET /WEBPASS=mypassword /WEBPORT=1234 /WEBUSER=myuser
```

For details and a list of what can be set have a look at the official syncovery documentation: https://www.syncovery.com/linux-docs/

# Syncovery settings

A few things to keep in mind when using the `SYNCOVERY_SET_*` variables from above:

- The settings are applied on **every** start, so the environment variables always win over what is stored in the config file. If you prefer to manage a setting in the web interface, do not put it into the environment.
- On the very first start (as long as no config file exists yet) the container sets `/WEBSERVER=0.0.0.0` on its own so the web GUI is reachable from outside. This is nothing you should have to change.
- Setting names keep their spelling, so `SYNCOVERY_SET_S3PartSize` becomes `/S3PartSize` - write them exactly as syncovery documents them.
- If you change `WEBPORT`, remember to adjust your port mapping (`ports:` / `-p`) accordingly.
- Values of settings containing `PASS` are masked in the container log.

The available settings are documented by syncovery itself: https://www.syncovery.com/linux-docs/

# Time / Date

If you do not change your timezone (see environment variables) syncovery will user Europe/Berlin as default timezone. But if you want to make sure syncovery is using the correct time and date, you need to specify your timezone.
List of possible timezones: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones

Examples:

- Europe/Berlin
- Africa/Windhoek
- America/Costa_Rica

# Ports

This image exposes the following ports:

| Port | Description |
| --- | --- |
| `8999` | Web GUI (HTTP) |
| `8889` | Cloud authentication |

Those are the ports syncovery serves after a default start. The following ones are deliberately **not** exposed - they are switched off out of the box and their port number is freely configurable in syncovery, so an `EXPOSE` would only promise a default that does not exist. If you need one of them, map it yourself (e.g. `-p 8943:8943`):

| Port | Description |
| --- | --- |
| `8949` | Remote service |

# Machine ID

Syncovery uses the machine-id for credential encryption. If the machine-id changes (e.g. after a container recreation), stored credentials become invalid.

The container automatically manages `/etc/machine-id` and `/var/lib/dbus/machine-id`. On first start a new ID is generated and stored in `/machine-id/machine-id`. On subsequent starts the stored ID is reused.

Mount `/machine-id` as a volume to make the ID survive container recreations and image updates:

```yaml
volumes:
  - ./machine-id:/machine-id
```

# Docker compose (example)

```yaml
services:
  syncoverycl:
    container_name: syncoverycl
    hostname: syncoverycl
    restart: unless-stopped
    image: stefanruepp/syncoverycl
    volumes:
      - ./config:/config
      - ./machine-id:/machine-id
      - /:/server:ro
    environment:
      TZ: Europe/Berlin
    ports:
      - 8999:8999
      - 8889:8889
```

# Docker run (example)

```sh
docker run -d --name=syncovery -v /opt/docker/syncovery/machine-id:/machine-id -v /opt/docker/syncovery/config:/config -v /:/server:ro -p 8999:8999 stefanruepp/syncoverycl
```

# Tags

Several different tags are built to give you the possibility to use any specific version. But be careful, I do not have a docker subscription, so versions could disappear. As I only build the newest versions they are then lost and are not coming back.

# Opening webinterface

1. Run "Docker compose" or "Docker run".
2. Go to http://docker-host:8999 - for guardian http://docker-host:8900 and remote service http://docker-host:8949 (do **not** use `localhost` / `127.0.0.1`, see [Do not use localhost](#do-not-use-localhost) below - the container prints usable addresses on every start)
3. Login (use default credentials from syncovery documentation, they should be)
   - Username: default
   - Password: pass

## Do not use localhost

Syncovery skips the login if the web GUI is opened via `localhost` or `127.0.0.1`. Inside a container this only half works: the GUI loads, but it keeps asking for a login you cannot get past. Every other address behaves completely normal - the ip of the container, the ip of your docker host, your LAN ip or any domain name (even one resolving to `127.0.0.1`).

To make that easier the container prints all addresses it knows on every start:

```
Web GUI addresses:
  http://172.20.0.2:8999                     (this container)
  http://172.20.0.1:8999                     (your docker host, needs a published port)
  http://syncovery.c.loopdns.de:8999         (public dns name for 127.0.0.1)
NOTE: syncovery skips the login when the web GUI is opened via localhost or
NOTE: 127.0.0.1 - inside a container that only half works, the GUI loads but
NOTE: keeps asking for the login. Use one of the addresses above instead,
NOTE: any other ip or name works normally - see readme.
NOTE: for a name pointing to another local address than 127.0.0.1 you can
NOTE: create an account on https://loopdns.de and add your own entries.
```

| Address | Description |
| --- | --- |
| `this container` | The address docker handed to the container. Reachable from the docker host itself, no port mapping needed. One line per network the container is attached to (with `--network host` the addresses of the host are printed instead). |
| `your docker host` | The gateway of the docker network, which is your docker host. Works as soon as the port is published with the same number on both sides (`-p 8999:8999`) - a different host port (`-p 18999:8999`) cannot be detected from inside the container. |
| `syncovery.c.loopdns.de` | A public dns name (resolvable by anyone, it is a normal internet service) pointing to `127.0.0.1`. The request therefore ends up on the machine your browser runs on - just like localhost does - but syncovery sees a name instead of `localhost` and lets you log in normally. Use it on the machine the port is published on. |

The port is taken from `SYNCOVERY_SET_WEBPORT`, otherwise from your syncovery configuration, otherwise `8999`.

If you want such a name for one of the other addresses (your container ip, your docker host, ...) you can create an account on [loopdns.de](https://loopdns.de) and point your own names to your local addresses. If none of the printed addresses fits (e.g. you open the GUI from another computer) simply use the ip or hostname of your docker host - anything but `localhost` / `127.0.0.1` is fine.

# Running SyncoveryCL commands

Beside the web interface syncovery can also be controlled purely from the command line. The tool lives at `/syncovery/SyncoveryCL` inside the image and as the image has no entrypoint you can simply append your command:

```sh
docker run --rm -v ./config:/config -v ./machine-id:/machine-id \
    stefanruepp/syncoverycl /syncovery/SyncoveryCL /LIST
```

Mount the same volumes your container uses, otherwise the command works on an empty configuration.

Commands which talk to the **running** scheduler (`/STATUS`, `/CONTSTATUS`, `/RUNX=MyJob`, ...) have to be run inside your existing container instead - use `docker exec syncoverycl /syncovery/SyncoveryCL /STATUS`, a throwaway container only answers `Cannot communicate with scheduler`.

All available commands (creating jobs, running them, changing settings, ...) are documented by syncovery itself: https://www.syncovery.com/linux-docs/

# Github

repository of this container: https://github.com/MyUncleSam/docker-syncovery

# Automatic builds

All builds are done automatically using a self hosted Jenkins environment. The build steps and configuration is defined in the `Jenkinsfile` and can be read from Jenkins to create a pipeline project from it.

If a build fails it is automatically repeated once after a minute - most failures are temporary (syncovery.com or docker hub not reachable).

As the steps differ between arm64 and amd64 architecture all needed steps to build the image are in the `scripts` folder.

## Requirements

- Jenkins
- Jenkins agent with installed docker
- Plugin UrlTrigger
- Plugin Discord Notifier

## Variables

The build script logs into docker bevore building the image. For this you need to set in you agent these variables:

| Variable | Description |
| --- | --- |
| `DOCKER_USERNAME` | Your docker hub username |
| `DOCKER_API_PASSWORD` | Your docker hub api password, stored as jenkins credential of the same name |
| `DISCORD_WEBHOOK` | Webhook url used to send the build notifications |

## Agent

You need at least one agent with the label `docker` which has an installed and working docker environment.
