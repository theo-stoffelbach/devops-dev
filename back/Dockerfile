# Use Node.js LTS version with Debian (meilleure compatibilité Prisma)
FROM node:20-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    openssl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy package files
COPY package*.json ./
COPY prisma/ ./prisma/

# Install dependencies (inclure prisma pour la prod)
RUN npm ci

# Generate Prisma client
RUN npx prisma generate

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Start the application
CMD ["node", "server.js"] 

# docker pull rg.fr-par.scw.cloud/namespace-theo-stoffelbach-final/backend-api:latest
# docker pull rg.fr-par.scw.cloud/namespace-theo-stoffelbach-final/frontend-web:latest

# docker image inspect rg.fr-par.scw.cloud/namespace-theo-stoffelbach-final/backend-api:latest
# docker image inspect rg.fr-par.scw.cloud/namespace-theo-stoffelbach-final/frontend-web:latest

# docker build -t backend-api:latest .
# docker build -t frontend-web:latest .

# docker tag backend-api:latest rg.fr-par.scw.cloud/namespace-theo-stoffelbach-final/backend-api:latest
# docker tag frontend-web:latest rg.fr-par.scw.cloud/namespace-theo-stoffelbach-final/frontend-web:latest

# docker push rg.fr-par.scw.cloud/namespace-theo-stoffelbach-final/backend-api:latest
# docker push rg.fr-par.scw.cloud/namespace-theo-stoffelbach-final/frontend-web:latest
