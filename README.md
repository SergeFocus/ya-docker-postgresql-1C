# VanessaDockers/postgresql:9.6.5-5 with 1C support

Stable Build Status   | Experimental Build Status |
:-------------------:|:----------------------:|
[![CircleCI](https://circleci.com/gh/VanessaDockers/ya-docker-postgresql-1C/tree/master.svg?style=svg)](https://circleci.com/gh/VanessaDockers/ya-docker-postgresql-1C/tree/master) | [![CircleCI](https://circleci.com/gh/VanessaDockers/ya-docker-postgresql-1C/tree/experimental.svg?style=svg)](https://circleci.com/gh/VanessaDockers/ya-docker-postgresql-1C/tree/experimental) |

- [Введение](#введение)
  - [Доработка](#доработка)
  - [Обсуждения](#обсуждения)
- [Начиная использование](#приступая-к-работе)
  - [Установка](#установка)
  - [Быстрый старт](#быстрый-старт)
  - [Персистентность](#персистентность)
  - [Trusting local connections](#trusting-local-connections)
  - [Setting `postgres` user password](#setting-postgres-user-password)
  - [Creating database user](#creating-database-user)
  - [Creating databases](#creating-databases)
  - [Granting user access to a database](#granting-user-access-to-a-database)
  - [Enabling extensions](#enabling-extensions)
  - [Creating replication user](#creating-replication-user)
  - [Setting up a replication cluster](#setting-up-a-replication-cluster)
  - [Creating a snapshot](#creating-a-snapshot)
  - [Creating a backup](#creating-a-backup)
  - [Command-line arguments](#command-line-arguments)
  - [Logs](#logs)
  - [UID/GID mapping](#uidgid-mapping)
- [Maintenance](#maintenance)
  - [Upgrading](#upgrading)
  - [Shell Access](#shell-access)

# Введение

`Dockerfile` для создания образа [Docker](https://www.docker.com/) контейнера [PostgreSQL Pro](https://postgrespro.ru/).

PostgreSQL это объектно ориентированая система управления базами данных с акцентом на расширяемость и соответствие стандартам [[источник](https://ru.wikipedia.org/wiki/PostgreSQL)].

## Доработка

Для доработки данного образа используйте концепцию `fork` и `pull-request`

## Обсуждения

Прежде чем принимать решения об обсуждении проблемы, попробуйте обновить `Docker` до последней версии и проверьте не исправило ли это вашу проблему. Ознакомьтесь c инструкцией [по установке и обновлению Docker](https://docs.docker.com/installation)

Пользователи SELinux должны попробовать воспользоваться командой `setenforce 0` чтобы удостовериться в исправлении проблемы.

Если вышеуказанные рекомендации не помогают, тогда произведите исследование, исправьте проблемы и сформируйте `pull request`
при формировании `pull request'а` пожалуйста отразите  

- вывод команд `docker version` и `docker info`
- проверяли ли вы работу в режиме `docker run` или использовали файл `docker-compose.yml`
- использовали ли в момент проверки [Boot2Docker](http://www.boot2docker.io), [VirtualBox](https://www.virtualbox.org), и т.д.

Дополнительно для данного проекта [открыт чат gitter](https://gitter.im/VanessaDockers/pgsteroids)

# Приступая к работе

## Установка

Автоматические сборки данного образа доступна через хаб [Dockerhub](https://hub.docker.com/r//silverbulleters/ya-docker-postgresql-1c) и являются рекомендованным способом установки


```bash
docker pull silverbulleters/ya-docker-postgresql-1c
```

Конечно же вы можете собрать образ и сами.

```bash
docker build -t silverbulleters/ya-docker-postgresql-1c github.com/VanessDockers/ya-docker-postgresql-1c
```

## Быстрый старт

Для запуска просто запустите команду:

```bash
docker run --name postgresql -itd --restart always \
  --publish 5432:5432 \
  --volume /srv/docker/postgresql:/var/lib/postgresql \
  silverbulleters/ya-docker-postgresql-1c:9.6.5-5
```

Для подключения к сервер запустите команду:

```bash
docker exec -it postgresql sudo -u postgres psql
```


Примерные шаги по запуску всего контура целиком:
- Получить (pull) или собрать (build) образы сервисов
- Запустить сервис коллектора журналов - logstash
- Запустить сервис PostgreSQL (мастер)
- При необходимости запустить реплику
- Запустить сервис передачи журналов работы (log-beats)
- Запустить сервис отображения отчетов по журналам работы pgbadger
- Запустить сервис Pgadmin 
- Создать базу (если база для 1с, то только средствами 1С: консоль администрирования или стартовое окно Предприятия)
- На созданную базу подключить сервис Pghero (редактировать docker-compose.yml)
- Запустить сервис POWA 
- Запуск службы агента мониторинга состоит из двух частей:
  - предварительный запуск: создание и наполнение служебных таблиц и шаблонов на хосте мониторинга
  - рабочий запуск



*Дополнительно вы можете использовать примерный файл [docker-compose.yml](docker-compose.yml) для запуска вашего контейнера с помощью [Docker Compose](https://docs.docker.com/compose/). Обратите внимание: для вашего удобства созданы 2 файла `psql.bat` и `psql.sh` которые позволяют сразу же войти в режим `psql` с учетом того что вы склонировали репозиторий в каталог ya-docker-postgresql-1c*

## Сохранение данных контейнеров

Для хранения данных служб в контейнерах определены несколько томов: том для данных субд, отдельный том для табличных пространств (временные таблицы, данные платформы 1С:Предприятие, индексы платформы 1С:Предприятие), том для хранения журналов работы субд.

Чтобы службы сохраняли своё состояние при пересоздании контейнеров служб необходимо смонтировать тома в соответующие расположения.

Для корректной работы как на платформе windows, так и на платформе linux в качестве точек монтирования были определены отдельные контейнеры для хранения данных (docker volumes).

Для загрузки большого объема данных в окружении разработчика (docker for windows или docker toolbox) необходимо увеличить размер диска виртуальной машины. Для этого нужно выполнить соответствующие инструкции из статьи [Изменение размера диска виртуальной машины](change-size-vm-disk.md)

При запуске на продуктивной среде можно дополнительно указать точки монтирования куда будут подключены тома хранения данных на докер хосте.

> *В [Быстром старте](#быстрый-старт) команда уже монтирует точку подключения как персистентную.*

Пользователи `SELinux` должны обновить контекст безопасности в точке подключения, чтобы корректно использовать Docker:

```bash
mkdir -p /srv/docker/postgresql
chcon -Rt svirt_sandbox_file_t /srv/docker/postgresql
```

> **Примечание** 
>
> обратите внимание, в текущей версии docker-compose данные PostgreSQL размещаются в именованных томах (docker volumes), чтобы это изменить, вам необходимо явно переопределить точки монтирования.

## Доверительные локальные соединения

По умолчанию, соединения к PostgreSQL серверу требуют аутентификация при помощи пароля. Если вы решите использовать доверительные соединения без пароля из локальной сети, вы должны указать переменную окружения `PG_TRUST_LOCALNET`

```bash
docker run --name postgresql -itd --restart always \
  --env 'PG_TRUST_LOCALNET=true' \
  silverbulleters/ya-docker-postgresql-1c:9.6.5-5
```

> **Примечание**
>
> The local network here is network to which the container is attached. This has different meanings depending on the `--net` parameter specified while starting the container. In the default configuration, this parameter would trust connections from other containers on the `docker0` bridge.

## Setting `postgres` user password

By default the `postgres` user is not assigned a password and as a result you can only login to the PostgreSQL server locally. If you wish to login remotely to the PostgreSQL server as the `postgres` user, you will need to assign a password for the user using the `PG_PASSWORD` variable.

```bash
docker run --name postgresql -itd --restart always \
  --env 'PG_PASSWORD=passw0rd' \
  silverbulleters/ya-docker-postgresql-1c:9.6.5-5
```


> **Примечание**
>
> - When [persistence](#persistence) is in use, `PG_PASSWORD` is effective on the first run.
> - This feature is only available in the `latest` and versions > `9.4-10`

## Creating database user

A new PostgreSQL database user can be created by specifying the `DB_USER` and `DB_PASS` variables while starting the container.

```bash
docker run --name postgresql -itd --restart always \
  --env 'DB_USER=dbuser' --env 'DB_PASS=dbuserpass' \
  silverbulleters/ya-docker-postgresql-1c:9.6.5-5
```

> **Примечания**
>
> - The created user can login remotely
> - The container will error out if a password is not specified for the user
> - No changes will be made if the user already exists
> - Only a single user can be created at each launch

## Создание баз данных

A new PostgreSQL database can be created by specifying the `DB_NAME` variable while starting the container.

```bash
docker run --name postgresql -itd --restart always \
  --env 'DB_NAME=dbname' \
  silverbulleters/ya-docker-postgresql-1c:9.6.5-5
```

By default databases are created by copying the standard system database named `template1`. You can specify a different template for your database using the `DB_TEMPLATE` parameter. Refer to [Template Databases](http://www.postgresql.org/docs/9.4/static/manage-ag-templatedbs.html) for further information.

Additionally, more than one database can be created by specifying a comma separated list of database names in `DB_NAME`. For example, the following command creates two new databases named `dbname1` and `dbname2`.

```bash
docker run --name postgresql -itd --restart always \
  --env 'DB_NAME=dbname1,dbname2' \
  silverbulleters/ya-docker-postgresql-1c:9.6.5-5
```

## Granting user access to a database

If the `DB_USER` and `DB_PASS` variables are specified along with the `DB_NAME` variable, then the user specified in `DB_USER` will be granted access to all the databases listed in `DB_NAME`. Note that if the user and/or databases do not exist, they will be created.

```bash
docker run --name postgresql -itd --restart always \
  --env 'DB_USER=dbuser' --env 'DB_PASS=dbuserpass' \
  --env 'DB_NAME=dbname1,dbname2' \
  silverbulleters/ya-docker-postgresql-1c:9.6.5-5
```

In the above example `dbuser` with be granted access to both the `dbname1` and `dbname2` databases.

# Enabling extensions

The image also packages the [postgres contrib module](http://www.postgresql.org/docs/9.4/static/contrib.html). A comma separated list of modules can be specified using the `DB_EXTENSION` parameter.

```bash
docker run --name postgresql -itd \
  --env 'DB_NAME=db1,db2' --env 'DB_EXTENSION=unaccent,pg_trgm' \
  silverbulleters/ya-docker-postgresql-1c:9.6.5-5
```

The above command enables the `unaccent` and `pg_trgm` modules on the databases listed in `DB_NAME`, namely `db1` and `db2`.

> **NOTE**:
>
> This option deprecates the `DB_UNACCENT` parameter.

## Creating replication user

Similar to the creation of a database user, a new PostgreSQL replication user can be created by specifying the `REPLICATION_USER` and `REPLICATION_PASS` variables while starting the container.

```bash
docker run --name postgresql -itd --restart always \
  --env 'REPLICATION_USER=repluser' --env 'REPLICATION_PASS=repluserpass' \
  silverbulleters/ya-docker-postgresql-1c:9.6.5-5
```

> **Notes**
>
> - The created user can login remotely
> - The container will error out if a password is not specified for the user
> - No changes will be made if the user already exists
> - Only a single user can be created at each launch

*It is a good idea to create a replication user even if you are not going to use it as it will allow you to setup slave nodes and/or generate snapshots and backups when the need arises.*

## Setting up a replication cluster

When the container is started, it is by default configured to act as a master node in a replication cluster. This means that you can scale your PostgreSQL database backend when the need arises without incurring any downtime. However do note that a replication user must exist on the master node for this to work.

Begin by creating the master node of our cluster:

```bash
docker run --name postgresql-master -itd --restart always \
  --env 'DB_USER=dbuser' --env 'DB_PASS=dbuserpass' --env 'DB_NAME=dbname' \
  --env 'REPLICATION_USER=repluser' --env 'REPLICATION_PASS=repluserpass' \
  silverbulleters/ya-docker-postgresql-1c:9.6.5-5
```

Notice that no additional arguments are specified while starting the master node of the cluster.

To create a replication slave the `REPLICATION_MODE` variable should be set to `slave` and additionally the `REPLICATION_HOST`, `REPLICATION_PORT`, `REPLICATION_SSLMODE`, `REPLICATION_USER` and `REPLICATION_PASS` variables should be specified.

Create a slave node:

```bash
docker run --name postgresql-slave01 -itd --restart always \
  --link postgresql-master:master \
  --env 'REPLICATION_MODE=slave' --env 'REPLICATION_SSLMODE=prefer' \
  --env 'REPLICATION_HOST=master' --env 'REPLICATION_PORT=5432'  \
  --env 'REPLICATION_USER=repluser' --env 'REPLICATION_PASS=repluserpass' \
  silverbulleters/ya-docker-postgresql-1c:9.6.5-5
```

*In the above command, we used docker links so that we can address the master node using the `master` alias in `REPLICATION_HOST`.*

> **Note**
>
> - The default value of `REPLICATION_PORT` is `5432`
> - The default value of `REPLICATION_SSLMODE` is `prefer`
> - The value of `REPLICATION_USER` and `REPLICATION_PASS` should be the same as the ones specified on the master node.
> - With [persistence](#persistence) in use, if the container is stopped and started, for the container continue to function as a slave you need to ensure that `REPLICATION_MODE=slave` is defined in the containers environment. In the absense of which the slave configuration will be turned off and the node will allow writing to it while having the last synced data from the master.

And just like that with minimal effort you have a PostgreSQL replication cluster setup. You can create additional slaves to scale the cluster horizontally.

Here are some important notes about a PostgreSQL replication cluster:

 - Writes can only occur on the master
 - Slaves are read-only
 - For best performance, limit the reads to the slave nodes

## Creating a snapshot

Similar to a creating replication slave node, you can create a snapshot of the master by specifying `REPLICATION_MODE=snapshot`.

Once the master node is created as specified in [Setting up a replication cluster](#setting-up-a-replication-cluster), you can create a snapshot using:

```bash
docker run --name postgresql-snapshot -itd --restart always \
  --link postgresql-master:master \
  --env 'REPLICATION_MODE=snapshot' --env 'REPLICATION_SSLMODE=prefer' \
  --env 'REPLICATION_HOST=master' --env 'REPLICATION_PORT=5432'  \
  --env 'REPLICATION_USER=repluser' --env 'REPLICATION_PASS=repluserpass' \
  silverbulleters/ya-docker-postgresql-1c:9.6.5-5
```

The difference between a slave and a snapshot is that a slave is read-only and updated whenever the master data is updated (streaming replication), while a snapshot is read-write and is not updated after the initial snapshot of the data from the master.

This is useful for developers to quickly snapshot the current state of a live database and use it for development/debugging purposes without altering the database on the live instance.

## Creating a backup

Just as the case of setting up a slave node or generating a snapshot, you can also create a backup of the data on the master by specifying `REPLICATION_MODE=backup`.

> The backups are generated with [pg_basebackup](http://www.postgresql.org/docs/9.4/static/app-pgbasebackup.html) using the replication protocol.

Once the master node is created as specified in [Setting up a replication cluster](#setting-up-a-replication-cluster), you can create a point-in-time backup using:

```bash
docker run --name postgresql-backup -it --rm \
  --link postgresql-master:master \
  --env 'REPLICATION_MODE=backup' --env 'REPLICATION_SSLMODE=prefer' \
  --env 'REPLICATION_HOST=master' --env 'REPLICATION_PORT=5432'  \
  --env 'REPLICATION_USER=repluser' --env 'REPLICATION_PASS=repluserpass' \
  --volume /srv/docker/backups/postgresql.$(date +%Y%m%d%H%M%S):/var/lib/postgresql \
  silverbulleters/ya-docker-postgresql-1c:9.6.5-5
```

Once the backup is generated, the container will exit and the backup of the master data will be available at `/srv/docker/backups/postgresql.XXXXXXXXXXXX/`. Restoring the backup involves starting a container with the data in `/srv/docker/backups/postgresql.XXXXXXXXXXXX`.

## Command-line arguments

You can customize the launch command of PostgreSQL server by specifying arguments for `postgres` on the `docker run` command. For example the following command enables connection logging:

```bash
docker run --name postgresql -itd --restart always \
  silverbulleters/ya-docker-postgresql-1c:9.6.5-5 -c log_connections=on
```

Please refer to the documentation of [postgres](http://www.postgresql.org/docs/9.6/static/app-postgres.html) for the complete list of available options.

## Журналы работы СУБД

В образе PostgreSQL настроен на хранение лог файлов внутри выделенного тома `pg-log-master` смонтированного в каталог `/var/log/postgresql`. Логи записываются каждый час в новый файл, в имени файла при этом присутствует указание часа в течении которого в этот файл производилась запись. При наступлении новых суток содержимое файлов перезатираются новыми данными. Таким образом "рядом" с работающим сервером мы имеем журналы за последние 24 часа работы, что обеспечивает защиту от переполнения тома с файлами журналов.

Для анализа журналов работы они передаются в режиме онлайн на хост с где запущен коллектор лог файлов (см. раздел Коллектор журналов)

Для просомтра содержимого журнала работы вызвать `tail -f` внутри контейнера. Примерно так:

```bash
docker exec -it postgresql tail -f /var/log/postgresql/postgresql-17.log
```


## Коллектор журналов
Для централизованного сбора и анализа журналов с помощью PgBadger сохраненные локальной на каждом сервере журналы работы СУБД отправляются в централизованное хранилище. Для этого с помощью сервиса `logstash` запускается контейнер и слушает порт 5000 для приема данных от службы `log-beats`. Входящие данные архивируются, сжимаются и складываются в файловую систему.

Служба `log-beats` запускается рядом с запущенным контейнером СУБД подключаясь к тому с лог файлами СУБД обеспечивает их отправку в централизованное хранилище.


Перед запуском необходимо в файле конфигурации filebeat/config/filebeat.yml указать ip адрес или днс имя хоста на котором запущен коллектор журналов.


## PgBadger

Контейнер PgBadger собран с использованием сервиса `supervisord` который обеспечивает запуск нескольких служб внутри одного контейнера. Это веб сервер nginx для отображения отчетов сгенерированных из журналов работы и системный планировщик заданий `cron` который по расписанию запускает обработку журналов. По-умолчанию запуск задания анализа настроен на выполнение в пятую минуту каждого часа.

После выполнения анализа проанализированный файл перемещается в поддиректорию (analyzed).

Для просмотра статуса работы сервиса `supervisord` перейти в папку http://HOST-IP:9980/supervisor/

Логин/пароль: admin/admin

Для принудительного запуска анализа записываемого журнала после старта контейнера выполнить команду:
```
docker exec pgbadger ls -l /var/log/pg-logs
```
Скопировать имя файла который необходимо проанализировать и запустить анализ указав имя файла:

```
docker exec pgbadger pgbadger -I -J 4 --start-monday -Z +03 \
  ВЫБРАННЫЙ-ФАЙЛ.tar.gz \
  -O /var/www/html/
```
Для принудительного запуска скрипта анализа с переносом в архив выполнить:
```
docker exec pgbadger /bin/bash /usr/local/bin/start_analyze.sh
```



# UID/GID mapping

The files and processes created by the container are owned by the `postgres` user that is internal to the container. In the absense of user namespace in docker the UID and GID of the containers `postgres` user may have different meaning on the host.

For example, a user on the host with the same UID and/or GID as the `postgres` user of the container will be able to access the data in the persistent volumes mounted from the host as well as be able to KILL the `postgres` server process started by the container.

To circumvent this issue you can specify the UID and GID for the `postgres` user of the container using the `USERMAP_UID` and `USERMAP_GID` variables respectively.

For example, if you want to assign the `postgres` user of the container the UID and GID `999`:

```bash
docker run --name postgresql -itd --restart always \
  --env 'USERMAP_UID=999' --env 'USERMAP_GID=999' \
  silverbulleters/ya-docker-postgresql-1c:9.6.5-5
```
# Параметры запуска контейнера

Сгрупированы в файле [переменных окружения](runtime/env-defaults)

> **Примечание** 
> каждая переменная имеет значение по умолчанию, например:
> * `PG_TIMEZONE` - по умолчанию равно `Europe/Moscow`, то есть контейнер считает что он запускается в Московском времени

# Обслуживание

## Обновление

To upgrade to newer releases:

  1. Download the updated Docker image:

  ```bash
  docker pull silverbulleters/ya-docker-postgresql-1c:9.6.5-5
  ```

  2. Stop the currently running image:

  ```bash
  docker stop postgresql
  ```

  3. Remove the stopped container

  ```bash
  docker rm -v postgresql
  ```

  4. Start the updated image

  ```bash
  docker run --name postgresql -itd \
    [OPTIONS] \
    silverbulleters/ya-docker-postgresql-1c:9.6.5-5
  ```

## Shell Access

For debugging and maintenance purposes you may want access the containers shell. If you are using Docker version `1.3.0` or higher you can access a running containers shell by starting `bash` using `docker exec`:

```bash
docker exec -it postgresql bash
```

### Перед стартом работы с 1С

Если вы загрузили базу данных из DT файла в случае с 1С необходимо выполнить следующую последовательность команды

```
docker exec -it postgresql bash
sudo su postgres
vacuumdb -v -a -f -F -z
```

более подробно смотри 

* [на русском](https://postgrespro.ru/docs/postgrespro/current/app-vacuumdb)
* [на английском](https://www.postgresql.org/docs/current/static/app-vacuumdb.html)

# Базы данных, Тонкий тюннинг и прочее

## Когда можно использовать данный образ в продуктиве

* Для GITLAB 
* Для SonarQube
* Для 1С информационных систем работающих в режиме совместимости не ниже 8.3.9
  * образ использовался для баз данных размером `до 500 Gb` без использования сжатия на уровне файловых систем (только средствами TOAST)

## Ресурсы

Обратите внимание контейнер использует для адаптации параметров запуска все выделенные ресурсы для Docker хоста, если вы хотите наложить ограничения на контейнер используейте параметры ограничений [Ограничения ресурсов](https://docs.docker.com/engine/admin/resource_constraints/)

## Сжатие TOAST

Не все поля клиентское приложение может поместить в [TOAST](https://postgrespro.ru/docs/postgrespro/current/storage-toast), поэтому можно использовать скрипт для попытки сжатия в хранилище `EXTENDED`

Скрипт использует oscript.io для реализации, для подключения используется системные переменные DBNAME

Подробней в самом скрипте [./tools/compsess-status.os]

## Скрипты PLSQL

* `postgres.public.make_tablespace(name, dir, owner)` - создает табличное простраство с идентификатором `name`, по адресу `dir` с владелцем owner - по умолчанию `postgres`

## Мониторинг

в образ встроена возможность сбора журналов и статистики использования с помощью

* `mamonsu` и https://github.com/zabbix/zabbix-docker
* `pghero`
* `powa`
* `pgBadger`
