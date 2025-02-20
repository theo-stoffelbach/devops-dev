import prisma from '../db.js'
import bcrypt from 'bcrypt'

const main = async () => {
    const encryptedPassword = bcrypt.hashSync(process.env.DEFAULT_ADMIN_PASSWORD, parseInt(process.env.BCRYPT_SALT_ROUNDS))
    await prisma.user.upsert({
        where: { username: 'admin' },
        update: {},
        create: {
            username: 'admin',
            password: encryptedPassword,
            firstName: 'ad',
            lastName: 'min',
            isAdmin: true
        }
    })
}

main()
    .then(async () => {
        await prisma.$disconnect()
    })
    .catch(async (e) => {
        console.error(e)
        if (!process.env.DEFAULT_ADMIN_PASSWORD) {
            console.error('❌ Please provide a DEFAULT_ADMIN_PASSWORD in your .env file')
        }
        if (!process.env.BCRYPT_SALT_ROUNDS) {
            console.error('❌ Please provide a BCRYPT_SALT_ROUNDS in your .env file')
        }
        await prisma.$disconnect()
        process.exit(1)
    })
