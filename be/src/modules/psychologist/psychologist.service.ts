import { BadRequestException, Injectable, InternalServerErrorException } from '@nestjs/common';
import nodemailer from 'nodemailer';
import { ConfigService } from '@nestjs/config';
import { GoogleGenAI } from '@google/genai';
import { PrismaService } from '../prisma/prisma.service';

export type RankedPsychologist = {
    id: string;
    fullName: string;
    specialization: string;
    location: string;
    clinicName: string;
    rating: number;
    reviewCount: number;
};

@Injectable()
export class PsychologistService {
    private readonly ai: GoogleGenAI;
    private mailer: nodemailer.Transporter | null = null;

    constructor(
        private readonly prismaService: PrismaService,
        private readonly configService: ConfigService,
    ) {
        const apiKey =
            process.env.GEMINI_API_KEY || this.configService.get<string>('GEMINI_API_KEY');
        if (!apiKey) {
            throw new Error('GEMINI_API_KEY is missing');
        }
        this.ai = new GoogleGenAI({ apiKey });
    }

    async search(userId?: string, criteria?: string, limit = 10) {
        const safeLimit = Math.min(Math.max(limit, 1), 20);
        const candidates = await this.prismaService.psychologist.findMany({
            take: safeLimit,
            orderBy: [{ rating: 'desc' }, { reviewCount: 'desc' }],
            select: {
                id: true,
                fullName: true,
                specialization: true,
                location: true,
                clinicName: true,
                rating: true,
                reviewCount: true,
                tags: true,
                bio: true,
                yearsExperience: true,
            },
        });

        if (!criteria?.trim() && !userId?.trim()) {
            return candidates.map(this.toRanked);
        }

        const moodContext = await this.getUserMoodContext(userId);
        const rankedIds = await this.rankWithGemini(candidates, criteria, moodContext);
        if (!rankedIds?.length) {
            return candidates.map(this.toRanked);
        }

        const byId = new Map(candidates.map((item) => [item.id, item]));
        const ordered = rankedIds
            .map((id) => byId.get(id))
            .filter((item): item is typeof candidates[number] => Boolean(item));

        const remainder = candidates.filter((item) => !rankedIds.includes(item.id));
        return [...ordered, ...remainder].map(this.toRanked);
    }

    async getDetail(id: string) {
        return this.prismaService.psychologist.findUnique({
            where: { id },
            include: {
                education: true,
                reviews: { orderBy: { createdAt: 'desc' } },
                schedules: true,
            },
        });
    }

    async createBooking(
        userId: string,
        psychologistId: string,
        fullName: string,
        method: 'CHAT' | 'VOICE' | 'VIDEO',
        price: number,
        notes: string | undefined,
        scheduledAt: string,
    ) {
        const safeUserId = userId?.trim();
        if (!safeUserId) {
            throw new BadRequestException('userId is required');
        }
        if (!fullName?.trim()) {
            throw new BadRequestException('fullName is required');
        }
        if (!['CHAT', 'VOICE', 'VIDEO'].includes(method)) {
            throw new BadRequestException('method must be CHAT, VOICE, or VIDEO');
        }
        if (!Number.isFinite(price) || price <= 0) {
            throw new BadRequestException('price must be a positive number');
        }

        const date = new Date(scheduledAt);
        if (Number.isNaN(date.getTime())) {
            throw new BadRequestException('scheduledAt is invalid');
        }

        return this.prismaService.psychologistBooking.create({
            data: {
                userId: safeUserId,
                psychologistId,
                fullName: fullName.trim(),
                method,
                price: Math.round(price),
                notes: notes?.trim() || null,
                scheduledAt: date,
            },
        });
    }

    async payBooking(bookingId: string, userId: string) {
        const booking = await this.prismaService.psychologistBooking.findUnique({
            where: { id: bookingId },
        });
        if (!booking) {
            throw new BadRequestException('booking not found');
        }
        if (booking.userId !== userId) {
            throw new BadRequestException('user not allowed');
        }

        return this.prismaService.psychologistBooking.update({
            where: { id: bookingId },
            data: {
                paymentStatus: 'PAID',
                status: 'CONFIRMED',
            },
        });
    }

    async addReview(userId: string, psychologistId: string, rating: number, comment?: string) {
        if (!userId?.trim()) {
            throw new BadRequestException('userId is required');
        }
        if (!psychologistId?.trim()) {
            throw new BadRequestException('psychologistId is required');
        }
        if (!Number.isFinite(rating) || rating < 1 || rating > 5) {
            throw new BadRequestException('rating must be 1-5');
        }

        const review = await this.prismaService.psychologistReview.create({
            data: {
                userId: userId.trim(),
                psychologistId,
                rating: Math.round(rating),
                comment: comment?.trim() || null,
            },
        });

        const stats = await this.prismaService.psychologistReview.aggregate({
            where: { psychologistId },
            _avg: { rating: true },
            _count: { rating: true },
        });

        await this.prismaService.psychologist.update({
            where: { id: psychologistId },
            data: {
                rating: stats._avg.rating ?? 0,
                reviewCount: stats._count.rating ?? 0,
            },
        });

        return review;
    }

    async requestEmailVerification(psychologistId: string) {
        const psychologist = await this.prismaService.psychologist.findUnique({
            where: { id: psychologistId },
        });
        if (!psychologist) {
            throw new BadRequestException('psychologist not found');
        }
        if (!psychologist.email) {
            throw new BadRequestException('psychologist email is required');
        }

        const token = this.generateToken();
        const expiresAt = new Date(Date.now() + 1000 * 60 * 30);

        await this.prismaService.psychologistEmailVerification.create({
            data: {
                psychologistId: psychologist.id,
                email: psychologist.email,
                token,
                expiresAt,
            },
        });

        const baseUrl = this.configService.get<string>('APP_BASE_URL') || 'http://localhost:3000';
        const verifyUrl = `${baseUrl}/psychologist/verification/confirm/${token}`;

        const mailer = this.mailer ?? this.createMailer();
        this.mailer = mailer;

        await mailer.sendMail({
            from: this.configService.get<string>('SMTP_FROM') || 'no-reply@example.com',
            to: psychologist.email,
            subject: 'Verifikasi Psikolog Partner',
            text: `Klik link berikut untuk verifikasi: ${verifyUrl}`,
        });

        return { status: 'sent' };
    }

    async confirmEmailVerification(token: string) {
        const verification = await this.prismaService.psychologistEmailVerification.findUnique({
            where: { token },
        });
        if (!verification) {
            throw new BadRequestException('token not found');
        }
        if (verification.status !== 'PENDING') {
            return { status: verification.status.toLowerCase() };
        }
        if (verification.expiresAt < new Date()) {
            throw new BadRequestException('token expired');
        }

        await this.prismaService.psychologistEmailVerification.update({
            where: { id: verification.id },
            data: { status: 'VERIFIED' },
        });

        await this.prismaService.psychologistVerificationDoc.updateMany({
            where: {
                psychologistId: verification.psychologistId,
                status: 'PENDING',
            },
            data: { status: 'VERIFIED' },
        });

        return { status: 'verified' };
    }

    private async getUserMoodContext(userId?: string) {
        if (!userId?.trim()) {
            return null;
        }

        const analyses = await this.prismaService.analysis.findMany({
            where: { userId: userId.trim() },
            orderBy: { createdAt: 'desc' },
            take: 5,
        });

        if (!analyses.length) {
            return null;
        }

        return analyses
            .map((item) => `- ${item.emotionLabel}: ${item.summary}`)
            .join('\n');
    }

    private async rankWithGemini(
        candidates: Array<{
            id: string;
            fullName: string;
            specialization: string;
            location: string;
            clinicName: string;
            tags: string[];
            bio: string | null;
            yearsExperience: number;
        }>,
        criteria?: string,
        moodContext?: string | null,
    ) {
        const prompt = [
            'Kamu membantu memilih psikolog yang paling cocok.',
            'Berikan ranking ID psikolog berdasarkan kriteria user dan konteks mood/diary.',
            'Balas JSON murni tanpa markdown: {"rankedIds": [string]}',
            '',
            `Kriteria user: ${criteria?.trim() || 'Tidak ada kriteria tambahan.'}`,
            `Konteks mood user:\n${moodContext || 'Tidak ada konteks mood.'}`,
            '',
            'Daftar psikolog:',
            ...candidates.map((item, index) => {
                const details = [
                    `${index + 1}. id=${item.id}`,
                    `nama=${item.fullName}`,
                    `spesialis=${item.specialization}`,
                    `lokasi=${item.location}`,
                    `klinik=${item.clinicName}`,
                    `pengalaman=${item.yearsExperience} tahun`,
                    `tags=${item.tags.join(', ')}`,
                    `bio=${item.bio || '-'}`,
                ];
                return details.join(' | ');
            }),
        ].join('\n');

        let rawText = '';
        try {
            const response = await this.ai.models.generateContent({
                model: 'gemini-2.5-flash',
                contents: prompt,
                config: {
                    responseMimeType: 'application/json',
                },
            });
            rawText = response.text || '';
        } catch (error: any) {
            throw new InternalServerErrorException(
                `failed to call Gemini API: ${error?.message || error}`,
            );
        }

        const parsed = this.safeParseJson(rawText);
        if (!parsed?.rankedIds || !Array.isArray(parsed.rankedIds)) {
            return [];
        }

        return parsed.rankedIds.map((item: unknown) => String(item));
    }

    private safeParseJson(rawText: string) {
        const trimmed = rawText.trim();
        const start = trimmed.indexOf('{');
        const end = trimmed.lastIndexOf('}');
        if (start === -1 || end === -1 || end <= start) {
            return null;
        }

        const jsonText = trimmed.slice(start, end + 1);
        try {
            return JSON.parse(jsonText);
        } catch {
            return null;
        }
    }

    private toRanked(item: {
        id: string;
        fullName: string;
        specialization: string;
        location: string;
        clinicName: string;
        rating: number;
        reviewCount: number;
    }): RankedPsychologist {
        return {
            id: item.id,
            fullName: item.fullName,
            specialization: item.specialization,
            location: item.location,
            clinicName: item.clinicName,
            rating: item.rating,
            reviewCount: item.reviewCount,
        };
    }

    private createMailer() {
        const host = this.configService.get<string>('SMTP_HOST');
        const port = Number(this.configService.get<string>('SMTP_PORT') || 587);
        const user = this.configService.get<string>('SMTP_USER');
        const pass = this.configService.get<string>('SMTP_PASS');

        if (!host || !user || !pass) {
            throw new Error('SMTP credentials are missing');
        }

        return nodemailer.createTransport({
            host,
            port,
            secure: port === 465,
            auth: { user, pass },
        });
    }

    private generateToken() {
        return `${Date.now()}-${Math.random().toString(36).slice(2, 12)}`;
    }
}
