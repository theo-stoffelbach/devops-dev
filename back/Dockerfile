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

# Install dependencies
RUN npm ci --only=production

# Generate Prisma client
RUN npx prisma generate

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/items || exit 1

# Create startup script
RUN echo '#!/bin/bash\n\
set -e\n\
echo "🔧 Initializing database..."\n\
npx prisma db push --accept-data-loss\n\
echo "🌱 Seeding database..."\n\
npx prisma db seed\n\
echo "🚀 Starting server..."\n\
npm start' > /app/start.sh && chmod +x /app/start.sh

# Start the application
CMD ["/app/start.sh"] 