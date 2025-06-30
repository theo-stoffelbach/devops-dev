# 🐳 Docker Deployment

Ce projet est dockerisé avec deux services distincts :

- **API Backend** (Node.js + Express + Prisma) sur le port 3000
- **Frontend Web** (Vue.js + Nginx) sur le port 8080

## 🚀 Lancement rapide

```bash
# Construire et lancer les services
docker-compose up --build

# En arrière-plan
docker-compose up -d --build
```

## 🔧 Services disponibles

### Backend API (Node.js)

- **Port:** 3000
- **Endpoint:** http://localhost:3000
- **Health check:** http://localhost:3000/items
- **Base de données:** SQLite avec volume persistant

### Frontend Web (Vue.js + Nginx)

- **Port:** 8080
- **URL:** http://localhost:8080
- **Proxy API:** http://localhost:8080/api → Backend
- **Serveur:** Nginx avec gzip et cache

## 📁 Architecture

```
├── back/
│   ├── Dockerfile          # Image Node.js + Prisma
│   └── .dockerignore       # Exclusions build
├── front/
│   ├── Dockerfile          # Multi-stage build Vue.js + Nginx
│   ├── nginx.conf          # Configuration Nginx
│   ├── .env.production     # Variables d'environnement
│   └── .dockerignore       # Exclusions build
└── docker-compose.yml      # Orchestration des services
```

## 🎯 Endpoints API

### Authentication

- `POST /api/users/login` - Connexion
- `POST /api/users/register` - Inscription

### Items

- `GET /api/items` - Liste des items
- `POST /api/items` - Créer un item (admin)

### Orders

- `POST /api/orders` - Créer une commande
- `GET /api/orders/my` - Mes commandes

## 👤 Utilisateur par défaut

- **Username:** `admin`
- **Password:** `admin123`
- **Role:** Administrateur

## 🔄 Commandes utiles

```bash
# Voir les logs
docker-compose logs -f

# Logs d'un service spécifique
docker-compose logs -f api
docker-compose logs -f frontend

# Arrêter les services
docker-compose down

# Reconstruire seulement un service
docker-compose build api
docker-compose build frontend

# Nettoyer les volumes (⚠️ perte de données)
docker-compose down -v

# Accéder au container
docker exec -it shop-api sh
docker exec -it shop-frontend sh
```

## 🐛 Troubleshooting

### Backend ne démarre pas

```bash
# Vérifier les logs
docker-compose logs api

# Problème de DB
docker-compose down -v
docker-compose up --build
```

### Frontend 502 Bad Gateway

```bash
# Vérifier que l'API est healthy
docker-compose ps

# Redémarrer le frontend
docker-compose restart frontend
```

### Rebuild complet

```bash
# Nettoyer et reconstruire
docker-compose down
docker system prune -f
docker-compose up --build
```

## 🔐 Variables d'environnement

Configurées dans `docker-compose.yml` :

- `DATABASE_URL` - URL de la base SQLite
- `JWT_SECRET` - Clé secrète JWT
- `DEFAULT_ADMIN_PASSWORD` - Mot de passe admin
- `BCRYPT_SALT_ROUNDS` - Rounds de hachage bcrypt

## 📊 Monitoring

### Health Checks

- API: `wget http://localhost:3000/items`
- Frontend: `wget http://localhost/`

### Statut des services

```bash
docker-compose ps
```

## 🚢 Production

Pour la production, modifier :

1. `JWT_SECRET` dans docker-compose.yml
2. `DEFAULT_ADMIN_PASSWORD`
3. Ajouter un reverse proxy (Traefik, Nginx)
4. Configurer HTTPS
5. Utiliser une base de données externe (PostgreSQL)
