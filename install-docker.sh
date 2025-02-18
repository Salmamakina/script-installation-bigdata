#!/bin/bash

REPO_GITHUB=/tmp/repo_installation

# Vérifier si Docker est installé
if ! command -v docker &> /dev/null
then
    echo "Docker n'est pas installé. Installation..."
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
else
    echo "Docker est déjà installé."
fi

# Ajouter l'utilisateur au groupe Docker si ce n'est pas déjà fait
if ! groups $(whoami) | grep &>/dev/null "\bdocker\b"; then
    sudo usermod -aG docker $(whoami)
    echo "L'utilisateur $(whoami) a été ajouté au groupe docker."
else
    echo "L'utilisateur $(whoami) est déjà dans le groupe docker."
fi

# Appliquer le changement de groupe sans redémarrer
newgrp docker

# Redémarrer Docker si nécessaire
if sudo systemctl is-active --quiet docker; then
    systemctl restart docker
else
    echo "Docker n'est pas actif, démarrage..."
    systemctl start docker
fi

# Vérifier si Docker Compose est installé
if ! command -v docker-compose &> /dev/null
then
  curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
else
    echo "Docker Compose est déjà installé."
fi

# Lancer docker-compose
echo "Lancement de docker-compose..."
/usr/local/bin/docker-compose -f $REPO_GITHUB/docker-compose.yml up -d 
