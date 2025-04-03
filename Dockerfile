# Étape 1 : Builder Angular
FROM node:16.20.2 AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install --force

COPY . .

# Build de Kepler (version production)
RUN npm run build Kepler --prod --aot

COPY --from=builder /app/dist/Kepler /var/www/Kepler

# Build de Smarket (configuration spécifique)
RUN npx ng build --configuration smarket --aot

COPY --from=builder /app/dist/Kepler /var/www/Smarket


# Étape 2 : Image finale avec NGINX
FROM ubuntu:20.04

RUN apt-get update && apt-get install -y nginx
RUN rm /etc/nginx/sites-enabled/default

COPY nginx.conf /etc/nginx/sites-available/
COPY nginx-smarket.conf /etc/nginx/sites-available/

RUN ln -s /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/nginx.conf
RUN ln -s /etc/nginx/sites-available/nginx-smarket.conf /etc/nginx/sites-enabled/nginx-smarket.conf

RUN rm -rf /usr/share/nginx/html/*

# Exposer le port NGINX
EXPOSE 81 443

CMD ["nginx", "-g", "daemon off;"]
