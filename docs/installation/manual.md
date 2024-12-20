---
title: Manual UVMS installation
description: Contains installation instructions for manually installing PostgreSQL and UVMS
---

# Manual installation

It is recommended to run PostgreSQL and Wildfly on different machines. This
*how-to* is for a simple setup with one PostgreSQL server and one Wildfly
server. It does not cover more advanced use cases such as backups, replication,
geo-redundancy, general maintenance, etc.

!!! note "Prerequisites"
    * Two machines (VM or bare metal) with ssh access and sudo privileges
    * Connectivity between the machines for Wildfly <-> PostgreSQL (5432)

After installation the following will be running. Note that storage might be
better served through a SAN instead.

``` mermaid
architecture-beta
    group wf(server)[Wildfly host]
    service wildfly(server)[Wildfly] in wf
    service disk2(disk)[Storage] in wf
    disk2:T -- B:wildfly

    group postgres(server)[PostgreSQL host]
    service db(database)[Database] in postgres
    service disk1(disk)[Storage] in postgres
    disk1:T -- B:db

    db:L -- R:wildfly
```

## PostgreSQL server

Versions:

* `PostgreSQL 12`
* `Postgis 2.5.3`

``` bash title="Install PostgreSQL with extensions"
sudo zypper in postgresql-devel
sudo zypper in gcc
sudo zypper in gcc-c++
sudo zypper in autoconf
sudo zypper in automake
sudo zypper in libtool
sudo zypper in libxml2-devel

# Proj4:
sudo zypper install sqlite3
sudo zypper in sqlite3-devel
sudo wget https://download.osgeo.org/proj/proj-6.2.0.tar.gz
sudo tar -xvzf proj-6.2.0.tar.gz
cd proj-6.2.0/
sudo ./configure
sudo make
sudo make check
sudo make install

# GEOS:
sudo wget https://git.osgeo.org/gitea/geos/geos/archive/3.7.3.tar.gz
sudo tar -xvzf 3.7.3.tar.gz
cd geos
sudo ./autogen.sh
sudo ./configure
sudo make
sudo make check
sudo make install

# GDAL:
sudo wget http://download.osgeo.org/gdal/2.4.2/gdal-2.4.2.tar.gz
sudo tar -xvzf gdal-2.4.2.tar.gz
cd gdal-2.4.2
sudo ./autogen.sh
sudo ./configure
sudo make
sudo make install

# sudo /sbin/ldconfig

# PostGIS:
sudo wget https://download.osgeo.org/postgis/source/postgis-2.5.3.tar.gz
sudo tar -xvzf postgis-2.5.3.tar.gz
sudo ./configure --with-geosconfig=/usr/local/bin/geos-config --with-gdalconfig=/usr/local/bin/gdal-config
sudo make
sudo make install

sudo /sbin/ldconfig
```

!!! warning
    Security setup and hardening is not part of this how-to guide. The
    following steps are focused on what UVMS needs, but does not e.g. set a
    postgres password, open ports, etc.

With an empty PostgreSQL it's now time to add a new database and the needed
schemas and users.

1. Download [setup.sql](https://raw.githubusercontent.com/FocusFish/UVMS-Docker/refs/tags/4.3.2/postgres-base/src/main/docker/setup.sql)
1. Change `db71u` to a name of your choosing. *Make sure to replace all of the occurrences*
1. Change all passwords for the tables (`WITH PASSWORD 'XYZ'`)
1. Run the SQL script (with `psql` or a GUI such as `pgadmin`, `dbeaver`, etc).

## Wildfly server

### Basic server setup

UVMS requires Java 11 and has not been tested on newer versions.

On a SLES setup run:

``` bash
# Install Java 11
sudo zypper install java-11-openjdk-devel

# Add a wildfly user
sudo /usr/sbin/groupadd -r wildfly
sudo /usr/sbin/useradd -r -g wildfly -d /opt/wildfly -s /sbin/nologin wildfly

# Create folder structure
sudo mkdir -p /opt/wildfly
sudo chown -R wildfly:users /opt/wildfly
sudo mkdir -p /opt/uvms/app/logs
sudo chown -R wildfly:users /opt/uvms
sudo ln -s /opt/uvms/app /app

# Open firewall
sudo firewall-cmd --zone=public --add-port=28080/tcp --permanent
sudo firewall-cmd --zone=public --add-port=5445/tcp --permanent
sudo firewall-cmd --zone=public --add-port=8443/tcp --permanent
sudo firewall-cmd --zone=public --add-port=9990/tcp --permanent
sudo firewall-cmd --reload

# 28080 - wildfly http
# 5445 - jms / activemq
# 8443 - wildfly https
# 9990 - wildfly mgmt console

# Verify with
sudo firewall-cmd --list-all
```

### Wildfly setup

Add default configuration and a `systemd` service for Wildfly.

``` bash title="Add wildfly conf"
sudo tee -a /etc/default/wildfly.conf << 'EOF'
# The configuration you want to run
WILDFLY_CONFIG=standalone-full.xml

# The mode you want to run
WILDFLY_MODE=standalone

# The address to bind to
WILDFLY_BIND=0.0.0.0
EOF
```


``` bash title="Add launch script"
sudo -u wildfly tee -a /opt/wildfly/launch.sh << 'EOF'
#!/bin/sh
if [ "x$WILDFLY_HOME" = "x" ]; then
    WILDFLY_HOME="/opt/wildfly/current"
fi

if [[ "$1" == "domain" ]]; then
    $WILDFLY_HOME/bin/domain.sh -c $2 -b $3 -bmanagement $3
else
    $WILDFLY_HOME/bin/standalone.sh -c $2 -b $3 -bmanagement $3
fi
EOF
```

```bash title="Make it executable"
sudo chmod +x /opt/wildfly/launch.sh
```

``` bash title="Add systemd service for wildfly"
sudo tee -a /etc/systemd/system/wildfly.service << 'EOF'
[Unit]
Description=The WildFly Application Server
After=syslog.target network.target

[Service]
Environment=LAUNCH_JBOSS_IN_BACKGROUND=1
EnvironmentFile=-/etc/default/wildfly.conf
User=wildfly
LimitNOFILE=102642
PIDFile=/var/run/wildfly/wildfly.pid
ExecStart=/opt/wildfly/launch.sh $WILDFLY_MODE $WILDFLY_CONFIG $WILDFLY_BIND
StandardOutput=null

[Install]
WantedBy=multi-user.target
EOF
```

``` bash title="Enable the service"
sudo systemctl enable wildfly
sudo systemctl daemon-reload
```

### Install UVMS components

!!! note "Prerequisites"
    * Basic server setup completed
    * Wildfly setup completed
    * SSH user with `sudo` privileges *(not the `wildfly` user as it should not
      have `sudo` nor login privileges)*

#### Files

The following `pom.xml` utilizes SSH and SCP through the maven-antrun-plugin
for maven to move artifacts and run commands on a target host.

Copy the contents of the three files `pom.xml`, `assembly.xml`, and
`uvms.properties` into a folder structure like the following:

``` bash title="Folder structure"
.
├── src
│   └── main
│       ├── assembly
│       │   └── assembly.xml
│       └── wf-scripts
│           └── uvms.properties
└── pom.xml
```

!!! warning
    The `pom.xml` file contains a number of properties that needs setting (look
    for `SET_ME`). Some of them are set in the next section through environment
    variables, and is labeled as `OPTIONAL_SET_ME` instead. For example
    `scp.target.server.hostname` is one that is mandatory to set in `pom.xml`.

``` { .xml .max-height-code-block title="pom.xml" }
--8<-- "docs/installation/pom.xml"
```

``` { .xml .max-height-code-block title="assembly.xml" }
--8<-- "docs/installation/assembly.xml"
```

``` { .properties .max-height-code-block title="uvms.properties"" }
--8<-- "docs/installation/uvms.properties"
```

#### Install and Start

The following commands utilizes the `pom.xml` file above. There are a number of
parameters that can either be set through environment variables or changed
directly in `pom.xml`. The following examples opts for an environment variable
approach since that lends itself for automation (think CI).

``` bash title="Environment variables"
tee -a uvms_environment_variables << 'EOF'
export MAVEN_PROFILE_ENVIRONMENT=prod-server
export UMVS_VERSION=SET_ME

export UVMS_USM_SECRET_KEY=SET_ME

# ssh credentials
export SERVER_USERNAME=SET_ME
export SERVER_PASSWORD=SET_ME

# PostgreSQL (default: postgres/postgres)
export DB_USERNAME=SET_ME
export DB_PASSWORD=SET_ME

# Wildfly management
export WF_MGMT_USERNAME=SET_ME
export WF_MGMT_PASSWORD=SET_ME

# username / password for the PostgreSQL schemas
# Match with what was set in the PostgreSQL setup
export ASSET_PASSWORD=SET_ME
export AUDIT_PASSWORD=SET_ME
export CONFIG_PASSWORD=SET_ME
export MOVEMENT_PASSWORD=SET_ME
export MOVEMENT_RULES_PASSWORD=SET_ME
export EXCHANGE_PASSWORD=SET_ME
export REPORTING_PASSWORD=SET_ME
export SPATIAL_PASSWORD=SET_ME
export USM_PASSWORD=SET_ME
export INCIDENT_PASSWORD=SET_ME
export ACTIVITY_PASSWORD=SET_ME
EOF

source uvms_environment_variables
```

``` bash title="Stop old instance and install"
mvn verify \
    -Pscp-stop-and-install-server,$MAVEN_PROFILE_ENVIRONMENT \
    -Dunionvms.docker.version=$UMVS_VERSION \
    -Dscp.target.server.username=$SERVER_USERNAME \
    -Dscp.target.server.password=$SERVER_PASSWORD \
    -Dunionvms.database.username=$DB_USERNAME \
    -Dunionvms.database.password=$DB_PASSWORD \
    -Dunionvms.database.asset.password=$ASSET_PASSWORD \
    -Dunionvms.database.audit.password=$AUDIT_PASSWORD \
    -Dunionvms.database.config.password=$CONFIG_PASSWORD \
    -Dunionvms.database.movement.password=$MOVEMENT_PASSWORD \
    -Dunionvms.database.movement.rules.password=$MOVEMENT_RULES_PASSWORD \
    -Dunionvms.database.exchange.password=$EXCHANGE_PASSWORD \
    -Dunionvms.database.reporting.password=$REPORTING_PASSWORD \
    -Dunionvms.database.spatial.password=$SPATIAL_PASSWORD \
    -Dunionvms.database.usm.password=$USM_PASSWORD \
    -Dunionvms.database.incident.password=$INCIDENT_PASSWORD \
    -Dunionvms.database.activity.password=$ACTIVITY_PASSWORD \
    -Dwildfly.mgmt.console.username=$WF_MGMT_USERNAME \
    -Dwildfly.mgmt.console.password=$WF_MGMT_PASSWORD \
    -Dunionvms.usm.secret.key=$UVMS_USM_SECRET_KEY \
    -U
```

``` bash title="Update/Create database schema with Liquibase"
mvn liquibase:update \
    -Dliquibase.changeLogFile=target/liquibase/asset/liquibase/changelog/db-changelog-master.xml \
    -Dliquibase.defaultSchemaName=asset \
    -Dliquibase.username=asset \
    -Dliquibase.password=$ASSET_PASSWORD \
    -P$MAVEN_PROFILE_ENVIRONMENT

mvn liquibase:update \
    -Dliquibase.changeLogFile=target/liquibase/audit/liquibase/changelog/db-changelog-master.xml \
    -Dliquibase.defaultSchemaName=audit \
    -Dliquibase.username=audit \
    -Dliquibase.password=$AUDIT_PASSWORD \
    -P$MAVEN_PROFILE_ENVIRONMENT

mvn liquibase:update \
    -Dliquibase.changeLogFile=target/liquibase/config/liquibase/changelog/db-changelog-master.xml \
    -Dliquibase.defaultSchemaName=config \
    -Dliquibase.username=config \
    -Dliquibase.password=$CONFIG_PASSWORD \
    -P$MAVEN_PROFILE_ENVIRONMENT

mvn liquibase:update \
    -Dliquibase.changeLogFile=target/liquibase/movement/liquibase/changelog/db-changelog-master-postgres.xml \
    -Dliquibase.defaultSchemaName=movement \
    -Dliquibase.username=movement \
    -Dliquibase.password=$MOVEMENT_PASSWORD \
    -P$MAVEN_PROFILE_ENVIRONMENT

mvn liquibase:update \
    -Dliquibase.changeLogFile=target/liquibase/movement-rules/liquibase/changelog/db-changelog-master.xml \
    -Dliquibase.defaultSchemaName=movementrules \
    -Dliquibase.username=movementrules \
    -Dliquibase.password=$MOVEMENT_RULES_PASSWORD \
    -P$MAVEN_PROFILE_ENVIRONMENT

mvn liquibase:update \
    -Dliquibase.changeLogFile=target/liquibase/exchange/liquibase/changelog/db-changelog-master.xml \
    -Dliquibase.defaultSchemaName=exchange \
    -Dliquibase.username=exchange \
    -Dliquibase.password=$EXCHANGE_PASSWORD \
    -P$MAVEN_PROFILE_ENVIRONMENT

mvn liquibase:update \
    -Dliquibase.changeLogFile=target/liquibase/reporting/reporting-liquibase/changelog/db-changelog-master.xml \
    -Dliquibase.defaultSchemaName=reporting \
    -Dliquibase.username=reporting \
    -Dliquibase.password=$REPORTING_PASSWORD \
    -P$MAVEN_PROFILE_ENVIRONMENT

mvn liquibase:update \
    -Dliquibase.changeLogFile=target/liquibase/spatial/liquibase/changelog/db-changelog-master.xml \
    -Dliquibase.defaultSchemaName=spatial \
    -Dliquibase.username=spatial \
    -Dliquibase.password=$SPATIAL_PASSWORD \
    -P$MAVEN_PROFILE_ENVIRONMENT

mvn liquibase:update \
    -Dliquibase.changeLogFile=target/liquibase/user/liquibase/changelog/db-changelog-master.xml \
    -Dliquibase.defaultSchemaName=usm \
    -Dliquibase.username=usm \
    -Dliquibase.password=$USM_PASSWORD \
    -P$MAVEN_PROFILE_ENVIRONMENT

mvn liquibase:update \
    -Dliquibase.changeLogFile=target/liquibase/incident/liquibase/changelog/db-changelog-master.xml \
    -Dliquibase.defaultSchemaName=incident \
    -Dliquibase.username=incident \
    -Dliquibase.password=$INCIDENT_PASSWORD \
    -P$MAVEN_PROFILE_ENVIRONMENT

mvn liquibase:update \
    -Dliquibase.changeLogFile=target/liquibase/activity/liquibase/postgres/changelog/db-changelog-master.xml \
    -Dliquibase.defaultSchemaName=activity \
    -Dliquibase.username=activity \
    -Dliquibase.password=$ACTIVITY_PASSWORD \
    -P$MAVEN_PROFILE_ENVIRONMENT
```

``` bash title="Start wildfly"
mvn clean install -Pscp-start-server,$MAVEN_PROFILE_ENVIRONMENT -Dscp.target.server.username=$SERVER_USERNAME -Dscp.target.server.password=$SERVER_PASSWORD -U
```
