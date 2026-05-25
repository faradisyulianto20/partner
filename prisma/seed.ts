import { PrismaClient, UserRole, Gender } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
    const user = await prisma.user.upsert({
        where: { email: 'demo.user@partner.test' },
        update: {},
        create: {
            role: UserRole.USER,
            googleId: 'demo-google-id-user',
            email: 'demo.user@partner.test',
            name: 'Dinda Test',
            username: 'dinda_test',
            birthDate: new Date('2005-06-20'),
            gender: Gender.FEMALE,
            photoUrl: 'https://placehold.co/200x200/png',
        },
    });

    await prisma.emotionEntry.create({
        data: {
            userId: user.id,
            text: 'Aku merasa capek belakangan ini, tapi masih bisa berusaha lebih baik.',
            moodLabel: 'cemas ringan',
            moodScore: 0.62,
            summary: 'Kamu terlihat lelah namun masih punya motivasi untuk mencoba lagi.',
            recommendations: JSON.stringify([
                'Coba tidur lebih awal malam ini.',
                'Luangkan 10 menit untuk latihan pernapasan.',
                'Cerita ke orang terdekat jika butuh dukungan.',
            ]),
            rawResponse: {
                source: 'seed',
            },
        },
    });
}

main()
    .catch((error) => {
        console.error(error);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
