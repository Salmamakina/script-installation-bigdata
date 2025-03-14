#!/bin/bash

# ===================== Installation de Jenkins =====================

# Ajouter la clé GPG officielle de Jenkins
echo "Ajout de la clé GPG de Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc
if [ $? -eq 0 ]; then
  echo "Clé GPG Jenkins ajoutée avec succès."
else
  echo "Erreur lors de l'ajout de la clé GPG de Jenkins."
  exit 1
fi

# Ajouter le dépôt Jenkins
echo "Ajout du dépôt Jenkins..."
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list
if [ $? -eq 0 ]; then
  echo "Dépôt Jenkins ajouté avec succès."
else
  echo "Erreur lors de l'ajout du dépôt Jenkins."
  exit 1
fi

# Installer OpenJDK et Jenkins
echo "Mise à jour des paquets et installation de Jenkins..."
sudo apt-get update -y && sudo apt-get install -y openjdk-17-jdk jenkins
if [ $? -eq 0 ]; then
  echo "Jenkins et OpenJDK installés avec succès."
else
  echo "Erreur lors de l'installation de Jenkins."
  exit 1
fi

# Démarrer et activer Jenkins
echo "Démarrage de Jenkins..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

if [ $? -eq 0 ]; then
  echo "Jenkins démarré et activé avec succès."
else
  echo "Erreur lors du démarrage de Jenkins."
  exit 1
fi

# Vérifier si Jenkins fonctionne
echo "Vérification du statut de Jenkins..."
sudo systemctl status jenkins > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "Jenkins est en cours d'exécution."
else
  echo "Jenkins ne fonctionne pas. Vérifiez les logs pour plus d'informations."
fi

# ===================== Déploiement de SonarQube =====================

# Vérifier si le conteneur SonarQube existe déjà et le supprimer
echo "Vérification de l'existence d'un conteneur SonarQube..."
if sudo docker ps -a --format '{{.Names}}' | grep -q '^sonar$'; then
  echo "Un conteneur SonarQube existe déjà. Suppression..."
  sudo docker stop sonar && sudo docker rm sonar
fi 

# Créer un répertoire pour Docker Compose
echo "Création du répertoire pour Docker Compose..."
sudo mkdir -p /opt/sonarqube
if [ $? -eq 0 ]; then
  echo "Répertoire créé avec succès."
else
  echo "Erreur lors de la création du répertoire."
  exit 1
fi

# Créer le fichier docker-compose.yml pour SonarQube
echo "Création du fichier docker-compose.yml..."
sudo tee /opt/sonarqube/docker-compose.yml <<EOF
version: '3.7'

services:
  sonarqube:
    image: sonarqube:lts
    container_name: sonarqube
    restart: always
    depends_on:
      - postgres
    environment:
      SONAR_JDBC_URL: jdbc:postgresql://postgres/sonarqube
      SONAR_JDBC_USERNAME: sonar
      SONAR_JDBC_PASSWORD: sonar
      SONAR_WEB_PORT: 9000
    ports:
      - "9002:9000"
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
    networks:
      - sonarqube_network

  postgres:
    image: postgres:13
    container_name: postgres
    restart: always
    environment:
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: sonar
      POSTGRES_DB: sonarqube
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - sonarqube_network

volumes:
  sonarqube_data:
  sonarqube_extensions:
  postgres_data:

networks:
  sonarqube_network:
    driver: bridge
EOF
if [ $? -eq 0 ]; then
  echo "Fichier docker-compose.yml créé avec succès."
else
  echo "Erreur lors de la création du fichier docker-compose.yml."
  exit 1
fi
# Vérifier et modifier la limite vm.max_map_count
echo "Augmentation de la limite vm.max_map_count..."
sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl --system

# Démarrer SonarQube avec Docker Compose
echo "Démarrage de SonarQube avec Docker Compose..."
sudo docker-compose -f /opt/sonarqube/docker-compose.yml up -d
if [ $? -eq 0 ]; then
  echo "SonarQube démarré avec succès."
else
  echo "Erreur lors du démarrage de SonarQube."
  exit 1
fi
