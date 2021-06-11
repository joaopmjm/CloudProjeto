#!/bin/bash

cd /home/ubuntu

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo apt install git -y

git clone https://github.com/joaopmjm/CloudProjeto.git

cd CloudProjeto/front


crontab <<EOF
@reboot sudo docker run -d -p 80:5000 --name=frontProjeto frontProjeto
EOF

sudo docker build -t frontProjeto --build-arg API_URL="http://${IP_DO_BACK}" .
sudo docker run -d -p 80:5000 --name=run-frontProjeto frontProjeto