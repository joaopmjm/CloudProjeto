#!/bin/bash

cd /home/ubuntu

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo apt install git -y

git clone https://github.com/joaopmjm/CloudProjeto.git

cd CloudProjeto/front


crontab <<EOF
@reboot sudo docker run -d -p 80:5000 --name=front front
EOF

sudo docker build -t front .
sudo docker run -d -p 80:5000 --name=run-front front