#!/bin/bash

# Изменить значения полей в docker-compose.yml
sed -i "s|POSTGRES_HOST=.*|POSTGRES_HOST=$POSTGRES_HOST|" ../app/docker-compose.yml



