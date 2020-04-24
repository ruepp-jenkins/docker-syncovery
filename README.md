# TEST ONLY - DO NOT USE!!!

# Original work by hlince 
The first version was a copy of https://hub.docker.com/r/hlince/syncovery but with up2date SyncoveryCL versions. Now after some time I changed a little bit more (see next topic for details).

# Changes to original Image
- Changed distribution from CentOS to Ubuntu 18.04.
- Update to newer versions of SyncoveryCL
- Removed support for 

# Paths
There are only two paths which are used:
- /config: contains the syncovery config files
- /tmp: default temporary folder for syncovery

If your syncovery should work with files on the host filesystem, make sure to bind them into your container (see examples below, just extend the volumes / -v parts).

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

# Opening webinterface
1. Run "Docker compose" or "Docker run".
2. Go to http://docker-host:8999 (if docker runs local: http://localhost:8999)
3. Login
    - Username: default
    - Password: pass

# Github
repository of this container: https://github.com/MyUncleSam/docker-syncovery

hlince original github repository: https://github.com/Howard3/docker-syncovery
