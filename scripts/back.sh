#!/bin/bash

cd /home/ubuntu

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo apt install git -y

git clone https://github.com/joaopmjm/CloudProjeto.git

cd CloudProjeto/api

crontab <<EOF
@reboot sudo docker run --rm -d -p 80:8001 -e --name joaopmjm api_db

EOF

sudo docker build -t api .

sudo docker run --rm -d -p 80:8001 -e --name api api
