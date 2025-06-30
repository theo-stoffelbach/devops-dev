# 🚀 GitHub Actions Workflows

Ce projet utilise des workflows GitHub Actions pour automatiser les builds et déploiements.

## 📁 Structure des Workflows

```
.github/workflows/
├── build-on-main.yml    # 🏗️ Build automatique sur push main
└── deploy.yml           # 🚀 Déploiement automatique
```

---

## 🏗️ Build Automatique (`build-on-main.yml`)

### 🎯 Objectif

Build automatique des applications à chaque push sur main.

### 🔄 Déclencheur

- **Push** sur la branche `main` uniquement

### 🏗️ Jobs

#### Build Backend

- **Node.js 20** avec cache NPM
- **Prisma** : Génération du client
- **Variables** d'environnement pour build

#### Build Frontend

- **Vue.js** build avec Vite
- **Artefacts** : Distribution uploadée (7 jours)
- **Variable** : `VITE_API_URL=/api`

#### Build Docker

- **Images** : Backend et Frontend buildées
- **Cache** : GitHub Actions Cache optimisé
- **Tags** : `shop-backend:latest`, `shop-frontend:latest`
- **Test** : Vérification des images créées

### 📊 Résultats

- ✅ Applications compilées et prêtes
- 📦 Artefacts frontend disponibles
- 🐳 Images Docker buildées
- 📝 Résumé détaillé du build

---

## 🚀 Déploiement (`deploy.yml`)

### 🎯 Objectif

Déploiement automatique ou manuel des applications.

### 🔄 Déclencheurs

- **Tags** `v*` → Production automatique
- **Manuel** → Choix staging/production

### 🏗️ Process

1. **Configuration** production avec secrets
2. **Génération** docker-compose.prod.yml
3. **Upload** artefacts de déploiement
4. **Summary** détaillé

### 🔐 Secrets requis

```bash
# À configurer dans GitHub Secrets
JWT_SECRET_PROD=your-production-jwt-secret
ADMIN_PASSWORD_PROD=your-production-admin-password
```

### 📋 Exemple de déploiement

```yaml
# docker-compose.prod.yml généré
services:
  api:
    image: ghcr.io/username/repo-backend:latest
    environment:
      - JWT_SECRET=${{ secrets.JWT_SECRET_PROD }}
      - BCRYPT_SALT_ROUNDS=12
      - NODE_ENV=production
```

---

## 🎮 Comment utiliser

### 🔧 Configuration initiale

1. **Activer GitHub Packages**

   ```bash
   # Settings → Actions → General → Permissions
   # ✅ Allow GitHub Actions to create and approve pull requests
   # ✅ Allow actions and reusable workflows
   ```

2. **Configurer les secrets**

   ```bash
   # Settings → Secrets and variables → Actions
   JWT_SECRET_PROD=your-secret-key-here
   ADMIN_PASSWORD_PROD=your-admin-password
   ```

### 🚀 Flux de développement

#### Pour une feature

```bash
git checkout -b feature/nouvelle-fonctionnalite
git commit -am "nouvelle fonctionnalité"
git push origin feature/nouvelle-fonctionnalite
# → Aucun workflow déclenché sur les branches
```

#### Push sur main (build automatique)

```bash
git checkout main
git merge feature/nouvelle-fonctionnalite
git push origin main
# → Déclenche build-on-main.yml automatiquement
```

#### Pour une release (déploiement)

```bash
git tag v1.2.0
git push origin v1.2.0
# → Déclenche deploy.yml automatiquement
```

#### Pour un hotfix

```bash
# Via l'interface GitHub Actions
# → Run workflow "Deploy" manuellement
```

---

## 📊 Badges pour README

```markdown
![Build](https://github.com/username/repo/workflows/🏗️%20Build%20on%20Main%20Push/badge.svg)
![Deploy](https://github.com/username/repo/workflows/🚀%20Deploy%20to%20Production/badge.svg)
```

---

## 🔧 Personnalisation

### Variables d'environnement

```yaml
# Dans tes workflows
env:
  NODE_VERSION: "20"
  REGISTRY: ghcr.io
  PRODUCTION_URL: https://mon-app.com
```

### Ajout d'étapes custom

```yaml
- name: 🧪 Tests E2E avec Playwright
  run: npm run test:e2e

- name: 📊 Métriques performance
  run: npm run lighthouse
```

### Notifications

```yaml
- name: 📢 Slack notification
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

---

## 🎯 Approches Build

### 🏠 Node.js Direct (test-and-build.yml)

**Avantages :**

- ✅ Plus rapide pour les tests
- ✅ Meilleur feedback développeur
- ✅ Cache NPM natif
- ✅ Artefacts légers

**Inconvénients :**

- ❌ Pas de garantie production
- ❌ Différences d'environnement

### 🐳 Images Docker (docker-build.yml)

**Avantages :**

- ✅ Reproduction exacte production
- ✅ Déploiement simplifié
- ✅ Isolation complète
- ✅ Multi-architecture

**Inconvénients :**

- ❌ Plus lent à builder
- ❌ Images plus lourdes
- ❌ Cache plus complexe

---

## 🚦 Statuts des builds

### ✅ Succès

- 🏗️ **Build** : Applications compilées et images Docker créées
- 🚀 **Deploy** : Déploiement réussi et services démarrés

### ⚠️ Avertissements

- 🏗️ **Build** : Compilation avec warnings
- 🚀 **Deploy** : Déploiement avec warnings

### ❌ Échec

- 🏗️ **Build** : Erreurs de compilation ou Docker
- 🚀 **Deploy** : Échec de déploiement ou configuration invalide

Les workflows bloquent automatiquement les merges en cas d'échec ! 🛡️
