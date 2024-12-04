---
title: UVMS installation using Docker
description: Contains installation instructions for a Docker based setup
---

# Docker

!!! warning
    The Docker based setup is not recommended for production use

There are two ways to test a Docker based setup;
[docker-compose](#docker-compose) and
[Maven fabric8 Docker](#build-uvms-images-from-the-umvs-docker-repo) plugin. The
latter is intended for development usage, but can be an option if there's a
strong preference for building the images from scratch.

After installation the following will be running. (*Volumes are not strictly
necessary, see Ephemeral tip*)

``` mermaid
architecture-beta
    group host(server)[Host]
    group docker(cloud)[Docker] in host

    group wf(cloud)[Wildfly container] in docker
    service wildfly(server)[Wildfly] in wf

    group postgres(cloud)[PostgreSQL container] in docker
    service db(database)[Database] in postgres

    db:L -- R:wildfly
    service disk2(disk)[Volume] in host
    disk2:T -- B:wildfly
    service disk1(disk)[Volume] in host
    disk1:T -- B:db
```

With the exception of JMS for the `docker-compose` option, the following table
of port mappings apply:

| Service | What | Port (host:container)|
| --- | --- | --- |
| Wildfly | Management GUI | 29990:9990 |
| | HTTP | 28080:8080 |
| | HTTPS | 28443:8443 |
| | JMS | 5445:5445 |
| | JMS | 5455:5455 |
| PostgreSQL | | 25432:5432 |

## Docker-compose

!!! note "Prerequisites"
    * Docker installed
    * docker-compose installed

### Install

??? tip "Ephemeral mode"
    To run in an "ephemeral" mode the `volumes` part in
    `docker-compose-{{ uvms_version }}.yml` can be removed.

    ``` diff
    11,13d10
    <     volumes:
    <       - /app/logs:/app/logs
    <       - /opt/jboss/wildfly/standalone/log:/opt/jboss/wildfly/standalone/log
    ```

``` bash title="Download and start UVMS stack through docker-compose"
wget https://repo1.maven.org/maven2/fish/focus/uvms/docker/docker-compose/{{ uvms_version }}/docker-compose-{{ uvms_version }}.yml
docker-compose -f ./docker-compose-{{ uvms_version }}.yml up -d # (1)
```

1. `-f` flag points to the yaml file downloaded in the step above. `-d` for
   detach mode, i.e. the containers will continue running in the background.

Wait for the Docker images to be downloaded and the containers then to start up
and finally for Wildfly to load and start all of the UVMS modules.

1. Run
    ``` bash
    docker-compose -f ./docker-compose-{{ uvms_version }}.yml logs -f
    ```

    Look for something similar to `WildFly Full 26.0.0.Final (WildFly Core
    18.0.0.Final) started in 12345ms` in the logs

1. Access the GUI at [http://localhost:28080](http://localhost:28080),
   credentials: `vms_admin_com`/`password`

!!! warning
    Using `docker-compose up` always starts the system from a clean slate. This
    means that any data in the database is lost if the command is used after the
    first start.

    Use `docker-compose stop` and `docker-compose start` to stop and start an
    already running system

### Stop and clean up

Once done the UVMS stack can be cleaned up with:

``` bash title="Clean up UVMS stack"
docker-compose -f ./docker-compose-{{ uvms_version }}.yml down --volumes # (1)
```

1. By default, named volumes in your compose file are not removed when you run
   `docker-compose down`. If you want to remove the volumes, you need to add the
   `--volumes` flag.

## Build UVMS images from the UMVS-Docker repo

!!! note "Prerequisites"
    * Docker installed
    * Java 11
    * Maven

### Install

1. `git` clone repo: [UVMS-Docker](https://github.com/FocusFish/UVMS-Docker)
1. Then run
    ``` bash title="Build all Docker images and start an empty UVMS instance"
    cd UVMS-Docker \
    && mvn clean install -Pdocker -DskipITs \
    && cd unionvms-test \
    && mvn docker:start \
    && cd ..
    ```
1. With a `BUILD SUCCESS` from the above step the Docker containers should now
   be up and running. Verify with: `docker ps`
1. Access the GUI at [http://localhost:28080](http://localhost:28080),
   credentials: `vms_admin_com`/`password`

### Stop and clean up

``` bash title="Stop Docker containers and clean up"
docker stop postgres-release-1 wildfly-unionvms-1 \
&& docker system prune -f --volumes
```

