#!/bin/bash

set -e  # Arrêter le script en cas d'erreur

REPO_GITHUB="/tmp/repo_installation"

# Vérifier si Docker est installé
if ! command -v docker &> /dev/null; then
    echo "Docker n'est pas installé. Installation..."
    sudo apt update
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
else
    echo "Docker est déjà installé."
fi

# Ajouter l'utilisateur au groupe Docker
if ! groups | grep -q "\bdocker\b"; then
    sudo usermod -aG docker $USER
    echo "Ajout de l'utilisateur $USER au groupe docker. Déconnexion/reconnexion nécessaire."
else
    echo "L'utilisateur $USER est déjà dans le groupe docker."
fi

# Vérifier si Docker est actif, sinon le redémarrer
if ! sudo systemctl is-active --quiet docker; then
    echo "Docker n'est pas actif, démarrage..."
    sudo systemctl start docker
else
    echo "Docker fonctionne déjà."
fi

# Vérifier si Docker Compose est installé
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose n'est pas installé. Installation..."
    sudo apt install -y curl
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose installé avec succès."
else
    echo "Docker Compose est déjà installé."
fi

# Lancer docker-compose
if [[ -f "$REPO_GITHUB/docker-compose.yml" ]]; then
    echo "Lancement de docker-compose..."
    sudo /usr/local/bin/docker-compose -f "$REPO_GITHUB/docker-compose.yml" up -d
else
    echo "⚠️  Fichier docker-compose.yml introuvable dans $REPO_GITHUB. Vérifiez le chemin."
fi
