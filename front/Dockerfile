# Étape 1 : build du front
FROM node:20-alpine AS build

# Définit le répertoire de travail dans le conteneur
WORKDIR /app

# Copie les fichiers de dépendances
COPY package.json ./

# Installe les dépendances
RUN npm install

# Copie tout le code source
COPY . .

# Ajoute l'argument de build pour l'URL de l'API
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL

# Build le front
RUN npm run build

# Étape 2 : image nginx pour servir le build
FROM nginx:alpine

# Copie le build du front
COPY --from=build /app/dist /usr/share/nginx/html

# Expose le port 80
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"] 