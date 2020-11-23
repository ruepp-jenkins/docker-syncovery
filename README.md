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
- Changed distribution from CentOS to Ubuntu 20.04.
- Update to newer versions of SyncoveryCL
- Removed support for unraid (unable to test as I do not have one)

# Paths
There are only two paths which are used:
- /config: contains the syncovery config files
- /tmp: default temporary folder for syncovery

If your syncovery should work with files on the host filesystem, make sure to bind them into your container (see examples below, just extend the volumes / -v parts).

# Environment variables (with default values)
- TZ=Europe/Berlin
    - Set your timezone here (see Time / Date below)

# Time / Date
If you do not change your timezone (see environment variables) syncovery will user Europe/Berlin as default timezone. But if you want to make sure syncovery is using the correct time and date, you need to specify your timezone.
List of possible timezones: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones

Examples:
- Europe/Berlin
- Africa/Windhoek
- America/Costa_Rica

# Docker compose (example)

    version: '2.2'
    services:
       syncovery:
           restart: unless-stopped
           image: stefanruepp/syncoverycl
           volumes:
               - /opt/docker/syncovery/config:/config
               - /opt/docker/syncovery/tmp:/tmp
           ports:
                - 8999:8999

# Docker run (exmample)

    docker run -d --name=syncovery -v /opt/docker/syncovery/config:/config -v /opt/docker/syncovery/tmp:/tmp -p 8999:8999 stefanruepp/syncoverycl

# Dockerfiles

Inside this repository are two dockerfiles:
- Dockerfile: Ubuntu based image
- Alpine/Dockerfile: Alpine base image (read below!)

Alpine Dockerfile was built by me to have a smaller image. But all in all it is not smaller and feels a little bit dirty. For now it is generated in an own tag. Feel free to use it but it is not supported or tested by me. I highly suggest to use the normal ubuntu image!

# Opening webinterface
1. Run "Docker compose" or "Docker run".
2. Go to http://docker-host:8999 (if docker runs local: http://localhost:8999)
3. Login
    - Username: default
    - Password: pass

# Github
repository of this container: https://github.com/MyUncleSam/docker-syncovery

hlince original github repository: https://github.com/Howard3/docker-syncovery
