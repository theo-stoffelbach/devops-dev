#!/bin/bash

# 🗑️ Script de nettoyage Scaleway Serverless Containers
# Usage: ./cleanup-scaleway.sh

set -e

echo "🗑️ Nettoyage Scaleway Serverless Containers"
echo "==========================================="

# Configuration
BACKEND_NAMESPACE="backend-api"
FRONTEND_NAMESPACE="frontend-web"

# Vérifier que SCW CLI est installé
if ! command -v scw &> /dev/null; then
    echo "❌ SCW CLI n'est pas installé"
    exit 1
fi

echo "✅ SCW CLI détecté"

# Récupérer les IDs des namespaces
BACKEND_NS=$(scw container namespace list -o json | jq -r ".[] | select(.name==\"$BACKEND_NAMESPACE\") | .id // empty")
FRONTEND_NS=$(scw container namespace list -o json | jq -r ".[] | select(.name==\"$FRONTEND_NAMESPACE\") | .id // empty")

echo ""
echo "📦 Namespaces trouvés:"
echo "Backend Namespace ID: $BACKEND_NS"
echo "Frontend Namespace ID: $FRONTEND_NS"

# Fonction pour supprimer tous les containers d'un namespace
cleanup_namespace() {
    local namespace_id=$1
    local namespace_name=$2
    
    if [ -z "$namespace_id" ]; then
        echo "⚠️  Namespace $namespace_name non trouvé"
        return
    fi
    
    echo ""
    echo "🧹 Nettoyage du namespace $namespace_name..."
    
    # Lister et supprimer tous les containers
    containers=$(scw container container list namespace-id=$namespace_id -o json | jq -r '.[].id')
    
    if [ -z "$containers" ]; then
        echo "ℹ️  Aucun container trouvé dans $namespace_name"
    else
        for container_id in $containers; do
            echo "Suppression du container: $container_id"
            scw container container delete container-id=$container_id force=true || echo "❌ Erreur lors de la suppression du container $container_id"
        done
    fi
    
    # Supprimer le namespace
    echo "Suppression du namespace $namespace_name..."
    scw container namespace delete namespace-id=$namespace_id || echo "❌ Erreur lors de la suppression du namespace $namespace_name"
    
    echo "✅ Namespace $namespace_name nettoyé"
}

# Demander confirmation
echo ""
echo "⚠️  Cette opération va supprimer:"
echo "   - Tous les containers backend et frontend"
echo "   - Les namespaces backend-api et frontend-web"
echo ""
read -p "Voulez-vous continuer? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Opération annulée"
    exit 1
fi

# Nettoyer les namespaces
cleanup_namespace "$BACKEND_NS" "backend-api"
cleanup_namespace "$FRONTEND_NS" "frontend-web"

echo ""
echo "🎉 Nettoyage terminé!"
echo "Tous les containers et namespaces ont été supprimés."

# Optionnel: nettoyer les images Docker locales
echo ""
read -p "Voulez-vous aussi supprimer les images Docker locales? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🐳 Suppression des images Docker locales..."
    docker image rm rg.fr-par.scw.cloud/devops-backend/api:latest || echo "❌ Image backend non trouvée"
    docker image rm rg.fr-par.scw.cloud/devops-frontend/web:latest || echo "❌ Image frontend non trouvée"
    echo "✅ Images Docker supprimées"
fi

echo ""
echo "✨ Nettoyage complet!" 