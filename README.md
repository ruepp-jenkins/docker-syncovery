# Project

Github: https://github.com/MyUncleSam/docker-syncovery

Docker: https://hub.docker.com/repository/docker/stefanruepp/syncoverycl

# License

MIT License

Copyright (c) 2020 Stefan Ruepp https://github.com/MyUncleSam/docker-syncovery

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

# Paths

There are only two paths which are used:

- /config: contains the syncovery config files
- /tmp: default temporary folder for syncovery

If your syncovery should work with files on the host filesystem, make sure to bind them into your container (see examples below, just extend the volumes / -v parts).

# Environment variables (with default values)

- TZ=Europe/Berlin
  - Set your timezone here (see Time / Date below)
- SYNCOVERY_HOME=/config
  - Changes the default location of syncovery config files (changing should work but was never tested - so use at your own risk)

# Time / Date

If you do not change your timezone (see environment variables) syncovery will user Europe/Berlin as default timezone. But if you want to make sure syncovery is using the correct time and date, you need to specify your timezone.
List of possible timezones: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones

Examples:

- Europe/Berlin
- Africa/Windhoek
- America/Costa_Rica

# Ports

This image uses the default ports:

- Syncovery: 8999

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
      - /:/server:ro
    environment:
      TZ: Europe/Berlin
    ports:
      - 8999:8999
      - 8889:8889
```

# Docker run (exmample)

```sh
docker run -d --name=syncovery -v /opt/docker/syncovery/config:/config -v /:/server:ro -p 8999:8999 stefanruepp/syncoverycl
```

# Tags

Several different tags are built to give you the possibility to use any specific version. But be careful, I do not have a docker subscription, so versions could disappear. As I only build the newest versions they are then lost and are not coming back.

# Opening webinterface

1. Run "Docker compose" or "Docker run".
2. Go to http://docker-host:8999 (if docker runs local: http://localhost:8999) - for guardian http://docker-host:8900 and remote service http://docker-host:8949
3. Login (use default credentials from syncovery documentation, they should be)
   - Username: default
   - Password: pass

# Github

repository of this container: https://github.com/MyUncleSam/docker-syncovery

# Automatic builds

All builds are done automatically using a self hosted Jenkins environment. The build steps and configuration is defined in the `Jenkinsfile` and can be read from Jenkins to create a pipeline project from it.

As the steps differ between arm64 and amd64 architecture all needed steps to build the image are in the `scripts` folder.

## Requirements

- Jenkins
- Jenkins agent with installed docker
- Plugin UrlTrigger

## Variables

The build script logs into docker bevore building the image. For this you need to set in you agent these variables:

- DOCKER_USERNAME
- DOCKER_PASSWORD (docker api password)

## Agent

You need at least one agent with the label `docker` which has an installed and working docker environment.
