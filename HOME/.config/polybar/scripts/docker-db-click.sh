#!/bin/bash

if docker inspect db &> /dev/null; then
  docker stop db
else
  docker run --rm -it -d --network host --name db -v /tmp/docker-db:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=toor yobasystems/alpine-mariadb
fi
