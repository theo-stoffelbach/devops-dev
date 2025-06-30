import app from './app.js';
import prisma from './db.js';

const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';

// DÉMARRER LE SERVEUR IMMÉDIATEMENT (pas d'attente Prisma)
const server = app.listen(PORT, HOST, () => {
    // Connecter à Prisma APRÈS le démarrage (non-bloquant)
    connectToDatabase();
});

// Gérer les erreurs serveur
server.on('error', (error) => {
    process.exit(1);
});

// Fonction de connexion DB non-bloquante
async function connectToDatabase() {
    try {
        await prisma.$connect();
        // Vérifier que la DB existe, sinon la créer
        await initializeDatabaseIfNeeded();
    } catch (error) {
        // Server continues without database
    }
}

// Initialisation DB si nécessaire
async function initializeDatabaseIfNeeded() {
    try {
        await prisma.user.count();
    } catch (error) {
        try {
            const { execSync } = await import('child_process');
            execSync('npx prisma db push --force-reset', { stdio: 'ignore' });
            execSync('npx prisma db seed', { stdio: 'ignore' });
        } catch (initError) {
            // Silent fail
        }
    }
}

// Graceful shutdown
process.on('SIGTERM', () => {
    server.close(() => process.exit(0));
});
