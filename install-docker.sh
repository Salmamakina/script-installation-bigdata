#!/bin/bash


REPO_GITHUB=/tmp/repo_installation

sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $(whoami)
newgrp docker
sudo systemctl restart docker
sudo apt-get install -y python3-pip
sudo pip3 install docker-compose
sudo chmod +x /usr/local/bin/docker-compose


# Run Docker-compose
sudo docker-compose -f $REPO_GITHUB/docker-compose.yml up -d
