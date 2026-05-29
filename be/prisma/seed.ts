import { PrismaClient, Gender, VerificationDocType, VerificationStatus } from '@prisma/client';

const prisma = new PrismaClient();

const psychologistData = [
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
        isAcceptingSessions: true,
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
        isAcceptingSessions: true,
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
        isAcceptingSessions: true,
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

const reviewSamples = [
    { userId: 'u1', rating: 5, comment: 'Sangat empatik dan membantu.' },
    { userId: 'u2', rating: 4, comment: 'Penjelasan jelas, terasa suportif.' },
    { userId: 'u3', rating: 5, comment: 'Membuat saya merasa lebih tenang.' },
];

// Hitung rating rata-rata & jumlah secara statis untuk performa
const avgRating = reviewSamples.reduce((acc, r) => acc + r.rating, 0) / reviewSamples.length;
const totalReviews = reviewSamples.length;

async function seedPsychologistAndReviews() {
    console.log('🌱 Starting seeding process...');

    for (const item of psychologistData) {
        // Bungkus per psikolog ke dalam transaksi agar jika salah satu gagal, di-rollback
        await prisma.$transaction(async (tx) => {
            const psychologist = await tx.psychologist.upsert({
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
                    rating: avgRating,       // Langsung di-update di sini
                    reviewCount: totalReviews // Langsung di-update di sini
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
                    rating: avgRating,
                    reviewCount: totalReviews
                },
            });

            // Bersihkan relasi lama milik psikolog ini
            await tx.psychologistEducation.deleteMany({ where: { psychologistId: psychologist.id } });
            await tx.psychologistSchedule.deleteMany({ where: { psychologistId: psychologist.id } });
            await tx.psychologistVerificationDoc.deleteMany({ where: { psychologistId: psychologist.id } });
            await tx.psychologistReview.deleteMany({ where: { psychologistId: psychologist.id } });

            // Re-insert data relasi baru
            await tx.psychologistEducation.createMany({
                data: item.education.map((edu) => ({
                    psychologistId: psychologist.id,
                    level: edu.level,
                    institution: edu.institution,
                    year: edu.year,
                })),
            });

            await tx.psychologistSchedule.createMany({
                data: item.schedules.map((schedule) => ({
                    psychologistId: psychologist.id,
                    dayOfWeek: schedule.dayOfWeek,
                    startTime: schedule.startTime,
                    endTime: schedule.endTime,
                    isAvailable: true,
                })),
            });

            await tx.psychologistVerificationDoc.createMany({
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

            await tx.psychologistReview.createMany({
                data: reviewSamples.map((review) => ({
                    psychologistId: psychologist.id,
                    userId: review.userId,
                    rating: review.rating,
                    comment: review.comment,
                })),
            });
        });
        
        console.log(`✅ Seeded psychologist: ${item.fullName}`);
    }
}

async function main() {
    await seedPsychologistAndReviews();
}

main()
    .catch((error) => {
        console.error('❌ Seeding failed:', error);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
        console.log('🏁 Database connection closed.');
    });