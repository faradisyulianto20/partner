import { PrismaClient, Gender, VerificationDocType, VerificationStatus } from '@prisma/client';

const prisma = new PrismaClient();

async function seedPsychologist() {
    const data = [
        {
            fullName: 'Dr. Alya Rahmadani, M.Psi., Psikolog',
            email: 'nawwafzayyan27+alya@gmail.com',
            phoneNumber: '081200000001',
            gender: Gender.FEMALE,
            location: 'Jakarta Selatan',
            clinicName: 'Klinik Sehat Jiwa',
            specialization: 'Anxiety & Stress',
            clientsHandled: 320,
            yearsExperience: 8,
            nik: '3173010101010001',
            strNumber: 'STR-PSI-0001',
            bio: 'Fokus pada kecemasan, overthinking, dan burnout kerja.',
            tags: ['anxiety', 'stress', 'burnout', 'self-esteem'],
            education: [
                { level: 'S1', institution: 'Universitas Indonesia', year: 2014 },
                { level: 'S2', institution: 'Universitas Indonesia', year: 2016 },
            ],
            schedules: [
                { dayOfWeek: 1, startTime: '09:00', endTime: '12:00' },
                { dayOfWeek: 3, startTime: '13:00', endTime: '17:00' },
            ],
        },
        {
            fullName: 'Dr. Bagus Prasetyo, M.Psi., Psikolog',
            email: 'nawwafzayyan27+bagus@gmail.com',
            phoneNumber: '081200000002',
            gender: Gender.MALE,
            location: 'Bandung',
            clinicName: 'MindCare Clinic',
            specialization: 'Depression & Grief',
            clientsHandled: 210,
            yearsExperience: 6,
            nik: '3273020202020002',
            strNumber: 'STR-PSI-0002',
            bio: 'Pendampingan duka, kehilangan, dan depresi ringan.',
            tags: ['depression', 'grief', 'sadness', 'support'],
            education: [
                { level: 'S1', institution: 'Universitas Padjadjaran', year: 2015 },
                { level: 'S2', institution: 'Universitas Padjadjaran', year: 2017 },
            ],
            schedules: [
                { dayOfWeek: 2, startTime: '10:00', endTime: '14:00' },
                { dayOfWeek: 5, startTime: '09:00', endTime: '12:00' },
            ],
        },
        {
            fullName: 'Dr. Citra Lestari, M.Psi., Psikolog',
            email: 'nawwafzayyan27+citra@gmail.com',
            phoneNumber: '081200000003',
            gender: Gender.FEMALE,
            location: 'Surabaya',
            clinicName: 'Harmony Psychology',
            specialization: 'Relationship & Family',
            clientsHandled: 410,
            yearsExperience: 10,
            nik: '3573030303030003',
            strNumber: 'STR-PSI-0003',
            bio: 'Konseling relasi pasangan dan keluarga.',
            tags: ['relationship', 'family', 'communication'],
            education: [
                { level: 'S1', institution: 'Universitas Airlangga', year: 2012 },
                { level: 'S2', institution: 'Universitas Airlangga', year: 2014 },
            ],
            schedules: [
                { dayOfWeek: 4, startTime: '13:00', endTime: '18:00' },
                { dayOfWeek: 6, startTime: '09:00', endTime: '12:00' },
            ],
        },
    ];

    for (const item of data) {
        const psychologist = await prisma.psychologist.upsert({
            where: { nik: item.nik },
            update: {
                fullName: item.fullName,
                email: item.email,
                phoneNumber: item.phoneNumber,
                gender: item.gender,
                location: item.location,
                clinicName: item.clinicName,
                specialization: item.specialization,
                clientsHandled: item.clientsHandled,
                yearsExperience: item.yearsExperience,
                strNumber: item.strNumber,
                bio: item.bio,
                tags: item.tags,
            },
            create: {
                fullName: item.fullName,
                email: item.email,
                phoneNumber: item.phoneNumber,
                gender: item.gender,
                location: item.location,
                clinicName: item.clinicName,
                specialization: item.specialization,
                clientsHandled: item.clientsHandled,
                yearsExperience: item.yearsExperience,
                nik: item.nik,
                strNumber: item.strNumber,
                bio: item.bio,
                tags: item.tags,
            },
        });

        await prisma.psychologistEducation.deleteMany({
            where: { psychologistId: psychologist.id },
        });
        await prisma.psychologistSchedule.deleteMany({
            where: { psychologistId: psychologist.id },
        });
        await prisma.psychologistVerificationDoc.deleteMany({
            where: { psychologistId: psychologist.id },
        });

        await prisma.psychologistEducation.createMany({
            data: item.education.map((edu) => ({
                psychologistId: psychologist.id,
                level: edu.level,
                institution: edu.institution,
                year: edu.year,
            })),
        });

        await prisma.psychologistSchedule.createMany({
            data: item.schedules.map((schedule) => ({
                psychologistId: psychologist.id,
                dayOfWeek: schedule.dayOfWeek,
                startTime: schedule.startTime,
                endTime: schedule.endTime,
                isAvailable: true,
            })),
        });

        await prisma.psychologistVerificationDoc.createMany({
            data: [
                {
                    psychologistId: psychologist.id,
                    type: VerificationDocType.KTP,
                    url: 'https://example.com/docs/ktp.png',
                    status: VerificationStatus.PENDING,
                },
                {
                    psychologistId: psychologist.id,
                    type: VerificationDocType.FACE_WITH_KTP,
                    url: 'https://example.com/docs/face-with-ktp.png',
                    status: VerificationStatus.PENDING,
                },
                {
                    psychologistId: psychologist.id,
                    type: VerificationDocType.STR_LICENSE,
                    url: 'https://example.com/docs/str.pdf',
                    status: VerificationStatus.PENDING,
                },
            ],
        });
    }
}

async function seedReviews() {
    const psychologists = await prisma.psychologist.findMany({
        select: { id: true },
    });

    const reviewSamples = [
        { userId: 'u1', rating: 5, comment: 'Sangat empatik dan membantu.' },
        { userId: 'u2', rating: 4, comment: 'Penjelasan jelas, terasa suportif.' },
        { userId: 'u3', rating: 5, comment: 'Membuat saya merasa lebih tenang.' },
    ];

    for (const psy of psychologists) {
        await prisma.psychologistReview.deleteMany({
            where: { psychologistId: psy.id },
        });

        await prisma.psychologistReview.createMany({
            data: reviewSamples.map((review) => ({
                psychologistId: psy.id,
                userId: review.userId,
                rating: review.rating,
                comment: review.comment,
            })),
        });

        const stats = await prisma.psychologistReview.aggregate({
            where: { psychologistId: psy.id },
            _avg: { rating: true },
            _count: { rating: true },
        });

        await prisma.psychologist.update({
            where: { id: psy.id },
            data: {
                rating: stats._avg.rating ?? 0,
                reviewCount: stats._count.rating ?? 0,
            },
        });
    }
}

async function main() {
    await seedPsychologist();
    await seedReviews();
}

main()
    .catch((error) => {
        console.error(error);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
