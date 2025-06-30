# Use Node.js LTS version with Debian (meilleure compatibilité Prisma)
FROM node:20-slim

# Set working directory
WORKDIR /app

# Install system dependencies (minimal)
RUN apt-get update && apt-get install -y \
    openssl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Copy package files
COPY package*.json ./

# Install dependencies avec cache npm
RUN npm ci --only=production --no-audit --no-fund --silent && npm cache clean --force

# Copy prisma schema
COPY prisma/ ./prisma/

# Generate Prisma client (plus rapide après npm install)
RUN npx prisma generate

# Copy application code (à la fin pour optimiser le cache Docker)
COPY . .

# Create startup script silencieux
RUN echo '#!/bin/sh\nnode server.js' > /app/start.sh && chmod +x /app/start.sh

# Expose port
EXPOSE 3000

# Health check optimisé
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/items', (res) => process.exit(res.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"

# Start ULTRA FAST et SILENCIEUX
CMD ["/app/start.sh"]

# === COMMANDS MEMO ===
# docker build -t frontend-web:latest .
# docker tag frontend-web:latest rg.fr-par.scw.cloud/namespace-theo-stoffelbach-final/frontend-web:latest
# docker push rg.fr-par.scw.cloud/namespace-theo-stoffelbach-final/frontend-web:latest

# docker run -d -p 3000:3000 rg.fr-par.scw.cloud/namespace-theo-stoffelbach-final/frontend-web:latest

# docker pull rg.fr-par.scw.cloud/namespace-theo-stoffelbach-final/frontend-web:latest
# docker image inspect rg.fr-par.scw.cloud/namespace-theo-stoffelbach-final/frontend-web:latest