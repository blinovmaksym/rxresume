#!/bin/bash
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt install -y docker-ce

# Verify that Docker is installed
# sudo systemctl status docker

# Install Docker Compose
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose
sudo chown $USER /var/run/docker.sock

# Verify that Docker Compose is installed
docker compose version


if [ -d "app" ]; then
  cd "app"
else
  mkdir "app"
  cd "app"
fi
curl -L https://raw.githubusercontent.com/blinovmaksym/rxresume/main/docker-compose.yml > docker-compose.yml
curl -L https://raw.githubusercontent.com/AmruthPillai/Reactive-Resume/main/.env.example > .env

if [ -d "scripts" ]; then
  cd "scripts"
  echo "Переход в папку 'scripts' выполнен"

  chmod +x change_dockerfile.sh
  echo "Установлены права выполнения для 'change_dockerfile.sh'"

  ./change_dockerfile.sh
  echo "Выполнен скрипт 'change_dockerfile.sh'"
fi

# Выполнение команды в фоновом режиме
docker compose up -d &


