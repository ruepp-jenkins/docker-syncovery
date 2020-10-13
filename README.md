# Original work by hlince 
The first version was a copy of https://hub.docker.com/r/hlince/syncovery but with up2date SyncoveryCL versions. Now after some time I changed a little bit more (see next topic for details).

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
- Dockerfile.Alpine: Alpine base image (read below!)

I tried to also port it to Alpine which seems to work. But all in all I do not recommend to use it because it is not tested by me anymore. At the moment I update this Dockerfile.Alpine to the newest links. This should make it able to be used as good as the Ubuntu one. My recommendation is, if you want to let it run under Alpine - make your own image :-).

# Opening webinterface
1. Run "Docker compose" or "Docker run".
2. Go to http://docker-host:8999 (if docker runs local: http://localhost:8999)
3. Login
    - Username: default
    - Password: pass

# Github
repository of this container: https://github.com/MyUncleSam/docker-syncovery

hlince original github repository: https://github.com/Howard3/docker-syncovery
