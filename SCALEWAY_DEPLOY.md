# 🚀 Déploiement Scaleway Serverless Containers

## 1. Installation SCW CLI (Windows)

```bash
# Télécharger depuis GitHub releases
# https://github.com/scaleway/scaleway-cli/releases/latest
# Télécharger scw-*-windows-amd64.exe et renommer en scw.exe
```

## 2. Configuration initiale

```bash
# Configuration du CLI
scw init

# Ou configuration manuelle
scw config set access-key=<YOUR_ACCESS_KEY>
scw config set secret-key=<YOUR_SECRET_KEY>
scw config set default-organization-id=<YOUR_ORG_ID>
scw config set default-project-id=<YOUR_PROJECT_ID>
scw config set default-region=fr-par
scw config set default-zone=fr-par-1
```

## 3. Préparer les images Docker

### Backend

```bash
cd back

# Build et push vers Scaleway Container Registry
docker build -t rg.fr-par.scw.cloud/devops-backend/api:latest .
docker push rg.fr-par.scw.cloud/devops-backend/api:latest
```

### Frontend

```bash
cd front

# Build et push vers Scaleway Container Registry
docker build -t rg.fr-par.scw.cloud/devops-frontend/web:latest .
docker push rg.fr-par.scw.cloud/devops-frontend/web:latest
```

## 4. Créer les namespaces Serverless

```bash
# Namespace pour le backend
scw container namespace create name=backend-api region=fr-par

# Namespace pour le frontend
scw container namespace create name=frontend-web region=fr-par

# Lister les namespaces créés
scw container namespace list
```

## 5. Déployer le Backend API

```bash
# Obtenir l'ID du namespace backend
BACKEND_NS=$(scw container namespace list -o json | jq -r '.[] | select(.name=="backend-api") | .id')

# Déployer le container backend
scw container container create \
  namespace-id=$BACKEND_NS \
  name=api-server \
  registry-image=rg.fr-par.scw.cloud/devops-backend/api:latest \
  port=3000 \
  min-scale=0 \
  max-scale=5 \
  memory-limit=512 \
  cpu-limit=500 \
  environment-variables.DATABASE_URL="file:./dev.db" \
  environment-variables.JWT_SECRET="your-jwt-secret-here" \
  environment-variables.DEFAULT_ADMIN_PASSWORD="admin123" \
  environment-variables.BCRYPT_SALT_ROUNDS="10" \
  privacy=public

# Déployer
scw container container deploy container-id=$(scw container container list namespace-id=$BACKEND_NS -o json | jq -r '.[0].id')
```

## 6. Déployer le Frontend Web

```bash
# Obtenir l'ID du namespace frontend
FRONTEND_NS=$(scw container namespace list -o json | jq -r '.[] | select(.name=="frontend-web") | .id')

# Déployer le container frontend
scw container container create \
  namespace-id=$FRONTEND_NS \
  name=web-client \
  registry-image=rg.fr-par.scw.cloud/devops-frontend/web:latest \
  port=8080 \
  min-scale=0 \
  max-scale=3 \
  memory-limit=256 \
  cpu-limit=250 \
  environment-variables.VITE_API_URL="/api" \
  privacy=public

# Déployer
scw container container deploy container-id=$(scw container container list namespace-id=$FRONTEND_NS -o json | jq -r '.[0].id')
```

## 7. Obtenir les URLs de déploiement

```bash
# URL du backend
echo "Backend API URL:"
scw container container list namespace-id=$BACKEND_NS -o json | jq -r '.[0].domain_name'

# URL du frontend
echo "Frontend Web URL:"
scw container container list namespace-id=$FRONTEND_NS -o json | jq -r '.[0].domain_name'
```

## 8. Configuration des variables d'environnement

### Mettre à jour le frontend avec l'URL du backend

```bash
# Récupérer l'URL du backend
BACKEND_URL=$(scw container container list namespace-id=$BACKEND_NS -o json | jq -r '.[0].domain_name')

# Mettre à jour le container frontend
scw container container update \
  container-id=$(scw container container list namespace-id=$FRONTEND_NS -o json | jq -r '.[0].id') \
  environment-variables.VITE_API_URL="https://$BACKEND_URL"

# Redéployer le frontend
scw container container deploy container-id=$(scw container container list namespace-id=$FRONTEND_NS -o json | jq -r '.[0].id')
```

## 9. Surveillance et logs

```bash
# Voir les logs du backend
scw container container logs container-id=$(scw container container list namespace-id=$BACKEND_NS -o json | jq -r '.[0].id')

# Voir les logs du frontend
scw container container logs container-id=$(scw container container list namespace-id=$FRONTEND_NS -o json | jq -r '.[0].id')

# Statut des containers
scw container container list namespace-id=$BACKEND_NS
scw container container list namespace-id=$FRONTEND_NS
```

## 10. Scaling et ressources

```bash
# Scaler le backend
scw container container update \
  container-id=$(scw container container list namespace-id=$BACKEND_NS -o json | jq -r '.[0].id') \
  min-scale=1 \
  max-scale=10 \
  memory-limit=1024 \
  cpu-limit=1000

# Scaler le frontend
scw container container update \
  container-id=$(scw container container list namespace-id=$FRONTEND_NS -o json | jq -r '.[0].id') \
  min-scale=1 \
  max-scale=5 \
  memory-limit=512 \
  cpu-limit=500
```

## 11. Nettoyage

```bash
# Supprimer les containers
scw container container delete container-id=$(scw container container list namespace-id=$BACKEND_NS -o json | jq -r '.[0].id')
scw container container delete container-id=$(scw container container list namespace-id=$FRONTEND_NS -o json | jq -r '.[0].id')

# Supprimer les namespaces
scw container namespace delete namespace-id=$BACKEND_NS
scw container namespace delete namespace-id=$FRONTEND_NS
```

## 📋 Checklist de déploiement

- [ ] CLI Scaleway installé et configuré
- [ ] Images Docker buildées et pushées sur Container Registry
- [ ] Namespaces Serverless créés
- [ ] Backend déployé avec variables d'environnement
- [ ] Frontend déployé
- [ ] URLs récupérées et testées
- [ ] Communication backend/frontend vérifiée
- [ ] Scaling configuré selon les besoins

## 🎯 Avantages Serverless Containers

- **Pay-as-you-go** : Tu paies uniquement ce que tu utilises
- **Auto-scaling** : Scale automatiquement selon la charge
- **Zero maintenance** : Pas de serveurs à gérer
- **Déploiement séparé** : Backend et frontend indépendants
- **Rolling updates** : Déploiements sans downtime
