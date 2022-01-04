#!/bin/bash
mkdir -p /app
cd /app
touch start
sudo yum update -y 1>>server_logs.txt 2>&1
touch updated
sudo yum install -y git 1>>server_logs.txt 2>&1
touch git
curl --silent --location https://rpm.nodesource.com/setup_12.x | sudo bash - && sudo yum -y install nodejs 1>>server_logs.txt 2>&1
touch npm
git clone https://${GIT_TOKEN}@github.com/gwaihirSIGL/soar-platform-2-back.git 1>>server_logs.txt 2>&1
cd soar-platform-2-back/
echo "PGHOST='${PGHOST}'
POSTGRES_USER='${POSTGRES_USER}'
POSTGRES_PASSWORD='${POSTGRES_PASSWORD}'
POSTGRES_DB=soar
POSTGRES_PORT=3306
PORT=4002
" > .env
sudo npm i 1>>server_logs.txt 2>&1
sudo shutdown now
