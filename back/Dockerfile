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

# Create data directory for SQLite
RUN mkdir -p /app/data

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/items || exit 1

# Create startup script with better error handling
RUN echo '#!/bin/bash\n\
set -e\n\
echo "🔧 Setting up environment..."\n\
export DATABASE_URL="${DATABASE_URL:-file:/app/data/prod.db}"\n\
export JWT_SECRET="${JWT_SECRET:-fallback-secret-key}"\n\
export DEFAULT_ADMIN_PASSWORD="${DEFAULT_ADMIN_PASSWORD:-admin123}"\n\
export BCRYPT_SALT_ROUNDS="${BCRYPT_SALT_ROUNDS:-10}"\n\
echo "📊 DATABASE_URL: $DATABASE_URL"\n\
echo "🔧 Initializing database..."\n\
npx prisma db push --force-reset || npx prisma migrate deploy || echo "⚠️ Database setup failed, continuing..."\n\
echo "🌱 Seeding database..."\n\
npx prisma db seed || echo "⚠️ Seed failed, continuing..."\n\
echo "🚀 Starting server..."\n\
npm start' > /app/start.sh && chmod +x /app/start.sh

# Start the application
CMD ["/app/start.sh"] 