#!/bin/bash

# 🚀 Script de déploiement Scaleway Serverless Containers
# Usage: ./deploy-scaleway.sh

set -e

echo "🚀 Déploiement Scaleway Serverless Containers"
echo "============================================="

# Configuration
REGION="fr-par"
BACKEND_NAMESPACE="backend-api"
FRONTEND_NAMESPACE="frontend-web"
BACKEND_IMAGE="rg.fr-par.scw.cloud/devops-backend/api:latest"
FRONTEND_IMAGE="rg.fr-par.scw.cloud/devops-frontend/web:latest"

# Vérifier que SCW CLI est installé
if ! command -v scw &> /dev/null; then
    echo "❌ SCW CLI n'est pas installé"
    echo "Téléchargez-le depuis: https://github.com/scaleway/scaleway-cli/releases/latest"
    exit 1
fi

echo "✅ SCW CLI détecté"

# Fonction pour attendre que le container soit prêt
wait_for_container() {
    local container_id=$1
    local max_attempts=30
    local attempt=1
    
    echo "⏳ Attente du déploiement du container..."
    
    while [ $attempt -le $max_attempts ]; do
        status=$(scw container container get container-id=$container_id -o json | jq -r '.status')
        
        if [ "$status" == "ready" ]; then
            echo "✅ Container déployé avec succès!"
            return 0
        elif [ "$status" == "error" ]; then
            echo "❌ Erreur lors du déploiement"
            return 1
        fi
        
        echo "⏳ Tentative $attempt/$max_attempts - Status: $status"
        sleep 10
        ((attempt++))
    done
    
    echo "❌ Timeout: Le container n'est pas prêt après $max_attempts tentatives"
    return 1
}

# 1. Créer les namespaces
echo ""
echo "📦 Création des namespaces..."

# Backend namespace
echo "Création du namespace backend..."
scw container namespace create name=$BACKEND_NAMESPACE region=$REGION || echo "Namespace backend existe déjà"

# Frontend namespace  
echo "Création du namespace frontend..."
scw container namespace create name=$FRONTEND_NAMESPACE region=$REGION || echo "Namespace frontend existe déjà"

# Récupérer les IDs des namespaces
BACKEND_NS=$(scw container namespace list -o json | jq -r ".[] | select(.name==\"$BACKEND_NAMESPACE\") | .id")
FRONTEND_NS=$(scw container namespace list -o json | jq -r ".[] | select(.name==\"$FRONTEND_NAMESPACE\") | .id")

echo "✅ Backend Namespace ID: $BACKEND_NS"
echo "✅ Frontend Namespace ID: $FRONTEND_NS"

# 2. Build et push des images Docker
echo ""
echo "🐳 Build et push des images Docker..."

echo "Building backend image..."
cd back
docker build -t $BACKEND_IMAGE .
docker push $BACKEND_IMAGE
cd ..

echo "Building frontend image..."
cd front  
docker build -t $FRONTEND_IMAGE .
docker push $FRONTEND_IMAGE
cd ..

echo "✅ Images Docker pushées"

# 3. Déployer le backend
echo ""
echo "🚀 Déploiement du backend..."

# Supprimer l'ancien container s'il existe
OLD_BACKEND=$(scw container container list namespace-id=$BACKEND_NS -o json | jq -r '.[0].id // empty')
if [ ! -z "$OLD_BACKEND" ]; then
    echo "Suppression de l'ancien container backend..."
    scw container container delete container-id=$OLD_BACKEND force=true || true
fi

# Créer le nouveau container backend
BACKEND_CONTAINER=$(scw container container create \
  namespace-id=$BACKEND_NS \
  name=api-server \
  registry-image=$BACKEND_IMAGE \
  port=3000 \
  min-scale=0 \
  max-scale=5 \
  memory-limit=512 \
  cpu-limit=500 \
  environment-variables.DATABASE_URL="file:./dev.db" \
  environment-variables.JWT_SECRET="scaleway-jwt-secret-2024" \
  environment-variables.DEFAULT_ADMIN_PASSWORD="admin123" \
  environment-variables.BCRYPT_SALT_ROUNDS="10" \
  privacy=public \
  -o json | jq -r '.id')

echo "✅ Container backend créé: $BACKEND_CONTAINER"

# Déployer le backend
echo "Déploiement du backend..."
scw container container deploy container-id=$BACKEND_CONTAINER

# Attendre que le backend soit prêt
wait_for_container $BACKEND_CONTAINER

# Récupérer l'URL du backend
BACKEND_URL=$(scw container container get container-id=$BACKEND_CONTAINER -o json | jq -r '.domain_name')
echo "✅ Backend déployé: https://$BACKEND_URL"

# 4. Déployer le frontend
echo ""
echo "🌐 Déploiement du frontend..."

# Supprimer l'ancien container s'il existe
OLD_FRONTEND=$(scw container container list namespace-id=$FRONTEND_NS -o json | jq -r '.[0].id // empty')
if [ ! -z "$OLD_FRONTEND" ]; then
    echo "Suppression de l'ancien container frontend..."
    scw container container delete container-id=$OLD_FRONTEND force=true || true
fi

# Créer le nouveau container frontend avec l'URL du backend
FRONTEND_CONTAINER=$(scw container container create \
  namespace-id=$FRONTEND_NS \
  name=web-client \
  registry-image=$FRONTEND_IMAGE \
  port=8080 \
  min-scale=0 \
  max-scale=3 \
  memory-limit=256 \
  cpu-limit=250 \
  environment-variables.VITE_API_URL="https://$BACKEND_URL" \
  privacy=public \
  -o json | jq -r '.id')

echo "✅ Container frontend créé: $FRONTEND_CONTAINER"

# Déployer le frontend
echo "Déploiement du frontend..."
scw container container deploy container-id=$FRONTEND_CONTAINER

# Attendre que le frontend soit prêt
wait_for_container $FRONTEND_CONTAINER

# Récupérer l'URL du frontend
FRONTEND_URL=$(scw container container get container-id=$FRONTEND_CONTAINER -o json | jq -r '.domain_name')
echo "✅ Frontend déployé: https://$FRONTEND_URL"

# 5. Résumé du déploiement
echo ""
echo "🎉 Déploiement terminé!"
echo "======================"
echo "🔗 Backend API:  https://$BACKEND_URL"
echo "🔗 Frontend Web: https://$FRONTEND_URL"
echo ""
echo "📊 Pour surveiller les containers:"
echo "   scw container container logs container-id=$BACKEND_CONTAINER"
echo "   scw container container logs container-id=$FRONTEND_CONTAINER"
echo ""
echo "🗑️  Pour nettoyer:"
echo "   scw container container delete container-id=$BACKEND_CONTAINER"
echo "   scw container container delete container-id=$FRONTEND_CONTAINER"
echo "   scw container namespace delete namespace-id=$BACKEND_NS"
echo "   scw container namespace delete namespace-id=$FRONTEND_NS" 