#!/bin/bash

# Установить новые значения полей
PUBLIC_URL="http://example.com"
PUBLIC_SERVER_URL="http://example.com"


# Изменить значения полей в docker-compose.yml
sed -i "s|PUBLIC_URL=.*|PUBLIC_URL=$PUBLIC_URL|" docker-compose.yml
sed -i "s|PUBLIC_SERVER_URL=.*|PUBLIC_SERVER_URL=$PUBLIC_SERVER_URL|" docker-compose.yml



