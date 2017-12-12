# Изменение размера диска виртуальной машины

##  docker for windows (hyperv)
TODO 



## docker toolbox (virtualbox)
Необходимо закрыть kitematic если запущен.

В консоли Docker Quickstart Terminal выполним команду удаления машины
```
$ docker-machine rm default
```

И пересоздадим её с размером диска 100 Гб.
```
$ docker-machine create -d virtualbox --virtualbox-disk-size "102400" default
```

Для того чтобы всегда создавалась виртулаьная машина с необходимым размером диска добавить в скрипт запуска `start.sh` (%ProgramFiles%\Docker Toolbox\) на шаге `Checking if machine $VM exists`

в cтроке 
```
"${DOCKER_MACHINE}" create -d virtualbox $PROXY_ENV "${VM}"
```
параметр `--virtualbox-disk-size "102400"`

Чтобы получилась такая строка
```
"${DOCKER_MACHINE}" create -d virtualbox --virtualbox-disk-size "102400" $PROXY_ENV "${VM}"
```
