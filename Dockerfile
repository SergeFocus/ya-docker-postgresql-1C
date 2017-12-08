FROM sameersbn/ubuntu:14.04.20170123

LABEL maintainer.base="sameer@damagehead.com" \
      maintainer.current="team@silverbulleters.org"

ENV DEBIAN_FRONTEND=noninteractive

ENV PG_APP_HOME="/etc/docker-postgresql"\
    PG_VERSION=9.6 \
    PG_USER=postgres \
    PG_HOME=/var/lib/postgresql \
    PG_RUNDIR=/run/postgresql \
    PG_LOGDIR=/var/log/postgresql \
    PG_CERTDIR=/etc/postgresql/certs

ENV PG_BINDIR=/usr/lib/postgresql/${PG_VERSION}/bin \
    PG_DATADIR=${PG_HOME}/${PG_VERSION}/main \
    PG_WAL=${PG_HOME}/pg_xlog \
    PG_TEMPTBLSPC=${PG_HOME}/temptblspc \
    PG_V81C_DATA=${PG_HOME}/v81c_data \
    PG_V81C_INDEX=${PG_HOME}/v81c_index 

RUN apt-get update && apt-get install -y locales \
        && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8 \
        && update-locale LANG=ru_RU.UTF-8

#TODO add en_US locale
ENV LANG ru_RU.UTF-8
ENV LC_MESSAGES "POSIX"

ADD tools/postgrepinning /etc/apt/preferences.d/postgres

RUN wget --quiet -O - http://1c.postgrespro.ru/keys/GPG-KEY-POSTGRESPRO-1C | apt-key add - \
 && echo 'deb http://1c.postgrespro.ru/deb/ trusty main' > /etc/apt/sources.list.d/postgrespro-1c.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y curl acl \
      postgresql-pro-1c-${PG_VERSION} postgresql-client-pro-1c-${PG_VERSION} postgresql-contrib-pro-1c-${PG_VERSION} \
 && ln -sf ${PG_DATADIR}/postgresql.conf /etc/postgresql/${PG_VERSION}/main/postgresql.conf \
 && ln -sf ${PG_DATADIR}/pg_hba.conf /etc/postgresql/${PG_VERSION}/main/pg_hba.conf \
 && ln -sf ${PG_DATADIR}/pg_ident.conf /etc/postgresql/${PG_VERSION}/main/pg_ident.conf 
 
WORKDIR /tmp

RUN curl -s https://packagecloud.io/install/repositories/postgrespro/mamonsu/script.deb.sh | bash
RUN apt-get install mamonsu -y

WORKDIR /usr/local/src

RUN apt-get update && apt-get install -y \
    gcc \
    jq \
    make \
    postgresql-contrib-pro-1c-${PG_VERSION}  \
    postgresql-server-dev-pro-1c-${PG_VERSION}  \
    postgresql-plpython-pro-1c-${PG_VERSION} \
    && wget -O- $(wget -O- https://api.github.com/repos/dalibo/powa-archivist/releases/latest|jq -r '.tarball_url') | tar -xzf - \
    && wget -O- $(wget -O- https://api.github.com/repos/dalibo/pg_qualstats/releases/latest|jq -r '.tarball_url') | tar -xzf - \
    && wget -O- $(wget -O- https://api.github.com/repos/dalibo/pg_stat_kcache/releases/latest|jq -r '.tarball_url') | tar -xzf - \
    && wget -O- $(wget -O- https://api.github.com/repos/dalibo/hypopg/releases/latest|jq -r '.tarball_url') | tar -xzf - \
    && wget -O- $(wget -O- https://api.github.com/repos/rjuju/pg_track_settings/releases/latest|jq -r '.tarball_url') | tar -xzf - \
    && wget -O- $(wget -O- https://api.github.com/repos/reorg/pg_repack/tags|jq -r '.[0].tarball_url') | tar -xzf - \
    && for f in $(ls); do cd $f; make install; cd ..; rm    -rf $f; done

RUN wget --quiet -O - http://packages.2ndquadrant.com/repmgr3/apt/0xD3FA41F6.asc | apt-key add - \
 && echo deb http://packages.2ndquadrant.com/repmgr3/apt/ $(lsb_release -cs)-2ndquadrant main > /etc/apt/sources.list.d/repmgr3.list



# apt-key adv --fetch-keys http://packages.2ndquadrant.com/repmgr3/apt/0xD3FA41F6.asc

# echo deb http://packages.2ndquadrant.com/repmgr3/apt/ $(lsb_release -cs)-2ndquadrant main > /etc/apt/sources.list.d/repmgr3.list

RUN apt-get update

# RUN apt-get install -y --nodeps \
#     postgresql-${PG_VERSION}-repmgr \
#     repmgr-common \

RUN apt-get download \
    postgresql-${PG_VERSION}-repmgr \
    repmgr-common

# repmgr

# postgresql-9.6-repmgr
# repmgr-common

# postgresql-common
# postgresql-client-common


RUN apt-get purge -y --auto-remove curl gcc jq make postgresql-server-dev-pro-1c-${PG_VERSION} wget

RUN dpkg -i --ignore-depends=postgresql-common *.deb

RUN rm -rf *.deb

# Name of the cluster you want to start
ENV CLUSTER_NAME pg_cluster

# special repmgr db for cluster info
ENV REPLICATION_DB replication_db
ENV REPLICATION_USER replication_user
ENV REPLICATION_PASSWORD replication_pass
ENV REPLICATION_PRIMARY_PORT 5432

# priority on electing new master
ENV NODE_PRIORITY 100

# ENV CONFIGS "listen_addresses:'*'"
                                    # in format variable1:value1[,variable2:value2[,...]]
                                    # used for pgpool.conf file

ENV PARTNER_NODES ""
                    # List (comma separated) of all nodes in the cluster, it allows master to be adaptive on restart
                    # (can act as a new standby if new master has been already elected)

ENV MASTER_ROLE_LOCK_FILE_NAME $PGDATA/master.lock
                                                   # File will be put in $MASTER_ROLE_LOCK_FILE_NAME when:
                                                   #    - node starts as a primary node/master
                                                   #    - node promoted to a primary node/master
                                                   # File does not exist
                                                   #    - if node starts as a standby
ENV STANDBY_ROLE_LOCK_FILE_NAME $PGDATA/standby.lock
                                                  # File will be put in $STANDBY_ROLE_LOCK_FILE_NAME when:
                                                  #    - event repmgrd_failover_follow happened
                                                  # contains upstream NODE_ID
                                                  # that basically used when standby changes upstream node set by default
ENV REPMGR_WAIT_POSTGRES_START_TIMEOUT 90
                                            # For how long in seconds repmgr will wait for postgres start on current node
                                            # Should be big enough to perform post replication start which might take from a minute to a few
ENV USE_REPLICATION_SLOTS 1
                                # Use replication slots to make sure that WAL files will not be removed without beein synced to replicas
                                # Recomended(not required though) to put 0 for replicas of the second and deeper levels
ENV CLEAN_OVER_REWIND 0
                        # Clean $PGDATA directory before start standby and not try to rewind
ENV SSH_ENABLE 0
                        # If you need SSH server running on the node

#### Advanced options ####
ENV REPMGR_PID_FILE /tmp/repmgrd.pid
ENV WAIT_SYSTEM_IS_STARTING 5
ENV STOPPING_LOCK_FILE /tmp/stop.pid
ENV REPLICATION_LOCK_FILE /tmp/replication
ENV STOPPING_TIMEOUT 15
ENV CONNECT_TIMEOUT 2
ENV RECONNECT_ATTEMPTS 3
ENV RECONNECT_INTERVAL 5
ENV MASTER_RESPONSE_TIMEOUT 20
ENV LOG_LEVEL INFO
ENV CHECK_PGCONNECT_TIMEOUT 10
ENV REPMGR_SLOT_NAME_PREFIX repmgr_slot_


RUN rm -rf ${PG_HOME} \
&& rm -rf /var/lib/apt/lists/*

COPY runtime/ ${PG_APP_HOME}/
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 5432/tcp
VOLUME ["${PG_HOME}", "${PG_RUNDIR}", "${PG_LOGDIR}", "${PG_DATADIR}"]
VOLUME ["${PG_TEMPTBLSPC}", "${PG_V81C_DATA}", "${PG_V81C_INDEX}"]
WORKDIR ${PG_HOME}
ENTRYPOINT ["/sbin/entrypoint.sh"] 
