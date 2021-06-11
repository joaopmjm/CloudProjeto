#!/bin/bash

cd /home/ubuntu

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo apt install git -y

git clone https://github.com/joaopmjm/CloudProjeto.git

cd CloudProjeto/api


crontab <<EOF
@reboot sudo docker run -it --rm -d -p 80:8001 -e DB_DSN="db_user:123456789@tcp(172.31.48.2:80)/todos?charset=utf8mb4&parseTime=True&loc=Local" --name joaopmjm api_db

EOF

sudo docker build -t api_db .

sudo docker run -it --rm -d -p 80:8001 -e DB_DSN="db_user:123456789@tcp(172.31.48.2:80)/todos?charset=utf8mb4&parseTime=True&loc=Local" --name joaopmjm api_db
