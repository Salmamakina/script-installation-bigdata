# Étape 1 : Builder Angular
FROM node:16.13.0 AS builder

# Définir le dossier de travail
WORKDIR /app

# Copier les fichiers package.json et package-lock.json
COPY package*.json ./

# Installer les dépendances
RUN npm install --force

# Copier le reste de l'application
COPY . .

# Build de l'application Kepler (version production)
RUN npm run build Kepler --prod --aot

# Build de l'application Smarket (configuration spécifique)
RUN npm run build Kepler --configuration smarket --aot

# Étape 2 : Image finale avec NGINX
FROM ubuntu:20.04

# Installer NGINX
RUN apt-get update && apt-get install -y nginx

# Supprimer la configuration NGINX par défaut
RUN rm /etc/nginx/sites-enabled/default

# Copier les fichiers de configuration NGINX
COPY nginx.conf /etc/nginx/sites-available/
COPY nginx-smarket.conf /etc/nginx/sites-available/

# Activer les configurations NGINX
RUN ln -s /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/nginx.conf
RUN ln -s /etc/nginx/sites-available/nginx-smarket.conf /etc/nginx/sites-enabled/nginx-smarket.conf

# Supprimer la page d'accueil par défaut de NGINX
RUN rm -rf /usr/share/nginx/html/*

# Copier l'application Kepler
WORKDIR /var/www/Kepler
COPY --from=builder /app/dist/Kepler .

# Copier l'application Smarket
WORKDIR /var/www/Smarket
COPY --from=builder /app/dist/Kepler .

# Exposer le port NGINX
EXPOSE 81 443

# Lancer NGINX
CMD ["nginx", "-g", "daemon off;"]
