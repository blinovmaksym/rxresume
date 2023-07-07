#!/bin/bash

# Изменить значения полей в docker-compose.yml
sed -i "s|PUBLIC_URL=.*|PUBLIC_URL=http://$PUBLIC_URL:3000|" ../app/docker-compose.yml
sed -i "s|PUBLIC_SERVER_URL=.*|PUBLIC_SERVER_URL=http://$PUBLIC_URL:3100|" ../app/docker-compose.yml



