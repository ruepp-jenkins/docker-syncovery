# Original work by hlince 
The first version was a copy of https://hub.docker.com/r/hlince/syncovery but with up2date SyncoveryCL versions. Now after some time I changed a little bit more (see next topic for details).

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

# Changes to original Image
The complete project changed over time and it can no longer be compared to the original source.

# Features
This version comes with:
- Syncovery
- Guardian
- Remove Service

So you can use all components as you need

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
- DEBIAN_FRONTEND=noninteractive
    - NO EFFECTS, only needed for build process
- SETUP_TEMP=/tmp/installers/
    - NO EFFECTS, only needed for build process

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
- Guardian: 8900
- RemoteService: 8949

# Docker compose (example)

    version: '3.5'
    services:
       syncoverycl:
           container_name: syncoverycl
           hostname: syncoverycl
           restart: unless-stopped
           image: stefanruepp/syncoverycl
           volumes:
               - ./config:/config
               - ./tmp:/tmp
               - /:/server:ro
           environment:
                TZ: Europe/Berlin
           ports:
                - 8999:8999
                - 8900:8900
                - 8949:8949

# Docker run (exmample)

    docker run -d --name=syncovery -v /opt/docker/syncovery/config:/config -v /opt/docker/syncovery/tmp:/tmp -p 8999:8999 stefanruepp/syncoverycl

# Tags

Several different tags are built to give you the possibility to use any specific version. But be careful, I do not have a docker subscription, so versions could disappear. As I only build the newest versions they are then lost and are not coming back.

At the moment I build Ubuntu and Alpine images (attention: Alpine is no longer supported nor tested anymore - use at your own risk). Both system gets a main version tag like 'Ubuntu-v9' and a version tag like 'Ubuntu-9.35c'. And of course there is always the 'latest' tag as known by other images.

# Opening webinterface
1. Run "Docker compose" or "Docker run".
2. Go to http://docker-host:8999 (if docker runs local: http://localhost:8999) - for guardian http://docker-host:8900 and remote service http://docker-host:8949
3. Login
    - Username: default
    - Password: pass

# Github
repository of this container: https://github.com/MyUncleSam/docker-syncovery

hlince original github repository: https://github.com/Howard3/docker-syncovery

# Automatic builds
Since 2021 this docker images are built using https://www.jenkins.io/ (this is my first jenkins integration, so if you have some advices - please let me know).

To achive that the following urls are used to parse the most up2date versions:
- https://www.syncovery.com/linver_x86_64-Web.tar.gz.txt
- https://www.syncovery.com/linver_guardian_x86_64.tar.gz.txt
- https://www.syncovery.com/linver_rs_x86_64.tar.gz.txt

## Using jenkins inside docker
As I do not want to install jenkins directly on my server I have choosen to use it from the official docker container. But this brings some problems which needed to be solved like to install dependencies. The solution I found online was to make an own image, inherit from the original jenkins image and install all needed components. But I didn't like it and wanted to use the original directly to aovid to manage another image. So I cam up with the following solution:

### custom_entry.sh
What it is doing:
  1. install needed dependencies, in this case docker
  2. login to docker to be able to upload to hub.docker.com
  3. call the original entrypoint

```bash
#!/bin/bash

# Install docker
/usr/bin/apt-get update && apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common gnupg-agent
/usr/bin/curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
/usr/bin/apt-key fingerprint 0EBFCD88

add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/debian \
       $(lsb_release -cs) \
       stable"

/usr/bin/apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io

# Istall other things
apt-get install -y jq

# Login to docker (you need to place a file with your password into the home directory - see below)
cat /var/jenkins_home/docker_password.txt | docker login --username <your_hub_docker_com_username> --password-stdin

# execute the original entrypoint to start jenkins
/sbin/tini -- /usr/local/bin/jenkins.sh
```

### docker-compose.yml
Inside the docker-compose.yml I changed only the following:
  - change the entry path, to be able to execute my `custom_entry.sh` on start
  - run it as root as docker needs root to function inside the container
  - mount the needed paths (one of them is the docker.sock to be able to do docker stuff from inside the container)

```docker-compose.yml
version: '3.5'
services:
        jenkins:
                container_name: jenkins
                hostname: jenkins
                domainname: domain.tld
                image: jenkins/jenkins
                volumes:
                        - ./jenkins_home:/var/jenkins_home
                        - /var/run/docker.sock:/var/run/docker.sock
                restart: unless-stopped
                environment:
                        TZ: Europe/Berlin
                user: "0:0"
                entrypoint: /var/jenkins_home/ruepp/custom_entry.sh
```

## Project
Jenkins is triggered by the URLTrigger (plugin). This plugin checks if there is a new version. If there is one, a bash script extracts all needes version and download links. These information are then provided as additional build arguments to the docker build command. Using them the Dockerfile is always downloading the correct and most up2date versions to be able to build the image.

- Build Triggers
  - GitHub project: `https://github.com/MyUncleSam/docker-syncovery/`
  - URLTrigger
    - URL: `https://www.syncovery.com/linver_x86_64-Web.tar.gz.txt`
    - Inspect URL content:
      - Monitor a change of the content
    - Schedule: `H/15 * * * *` (every 15 minutes)
  - Build environment
    - Generate environment variables from script (Environment Script Plugin)
      - Unix script
      - Script content:<br />
```bash
#!/bin/bash
SYNCOVERY_REGEX='https://www\.syncovery\.com/release/SyncoveryCL-x86_64-(([1-9][0-9]?)\.[0-9]{1,2}[a-z]{0,2})-Web\.tar\.gz'
REMOTE_REGEX='https://www\.syncovery\.com/release/SyncoveryRS-x86_64-([1-9][0-9]?\.[0-9]{1,2}[a-z]{0,2})\.tar\.gz'
GUARD_REGEX='https://www\.syncovery\.com/release/SyncoveryGuardian-x86_64-([1-9][0-9]?\.[0-9]{1,2}[a-z]{0,2})\.tar\.gz'

SYNCOVERY=$(curl -s 'https://www.syncovery.com/linver_x86_64-Web.tar.gz.txt' 2> /dev/null)
REMOTE=$(curl -s 'https://www.syncovery.com/linver_rs_x86_64.tar.gz.txt' 2> /dev/null)
GUARD=$(curl -s 'https://www.syncovery.com/linver_guardian_x86_64.tar.gz.txt' 2> /dev/null)

# internal parameters
MAIN_VERSION=""
SYNCOVERY_VERSION=""
SYNCOVERY_DOWNLOADLINK=""
REMOTE_VERSION=""
REMOTE_DOWNLOADLINK=""
GUARD_VERSION=""
GUARD_DOWNLOADLINK=""

# syncovery
if [[ $SYNCOVERY =~ $SYNCOVERY_REGEX ]]; then
    MAIN_VERSION=${BASH_REMATCH[2]}
    SYNCOVERY_VERSION=${BASH_REMATCH[1]}
    SYNCOVERY_DOWNLOADLINK=${BASH_REMATCH[0]}
fi

# remote
if [[ $REMOTE =~ $REMOTE_REGEX ]]; then
    REMOTE_VERSION=${BASH_REMATCH[1]}
    REMOTE_DOWNLOADLINK=${BASH_REMATCH[0]}
fi

# guardian
if [[ $GUARD =~ $GUARD_REGEX ]]; then
    GUARD_VERSION=${BASH_REMATCH[1]}
    GUARD_DOWNLOADLINK=${BASH_REMATCH[0]}
fi

# check if both needed information are available and call jenkins if so
echo MAIN_VERSION=${MAIN_VERSION}
echo SYNCOVERY_VERSION=${SYNCOVERY_VERSION}
echo SYNCOVERY_DOWNLOADLINK=${SYNCOVERY_DOWNLOADLINK}
echo REMOTE_VERSION=${REMOTE_VERSION}
echo REMOTE_DOWNLOADLINK=${REMOTE_DOWNLOADLINK}
echo GUARD_VERSION=${GUARD_VERSION}
echo GUARD_DOWNLOADLINK=${GUARD_DOWNLOADLINK}
```
- Build Triggers
  - GitHub project: `https://github.com/MyUncleSam/docker-syncovery/`
  - This project is parameterized
    - #1
      - Name: `SYNCOVERY_VERSION`
      - Trim the string: `yes`
    - #2
      - Name: `SYNCOVERY_DOWNLOADURL`
      - Trim the string: `yes`
- Source Code Management: Git
  - Repository URL: `https://github.com/MyUncleSam/docker-syncovery.git`
- Build Triggers
  - Trigger builds Remotely (e.g. from scripts)
    - Authentication Token: `choose your own token here - avoid special characters`
- Build
  - Docker Build and Publish
    - Repository Name: `stefanruepp/syncoverycl`
    - Tag: `latest` / `ubuntu-latest` / `ubuntu-v${MAIN_VERSION}` / `ubuntu-${SYNCOVERY_VERSION}` / `alpine-latest` / `alpine-v${MAIN_VERSION}` / `alpine-${SYNCOVERY_VERSION}`
    - Registry credentials: `your hub.docker.com credentials`
    - Build Context: `Ubuntu` / `Apline`
    - Additional Build Arguments: `--build-arg SYNCOVERY_DOWNLOADLINK=${SYNCOVERY_DOWNLOADLINK} --build-arg GUARD_DOWNLOADLINK=${GUARD_DOWNLOADLINK} --build-arg REMOTE_DOWNLOADLINK=${REMOTE_DOWNLOADLINK}`

