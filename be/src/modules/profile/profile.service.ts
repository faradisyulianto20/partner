import { BadRequestException, ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma, UserRole } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { SupabaseService } from '../supabase/supabase.service';
import { ClientProfileDto } from './dto/client-profile.dto';
import { PsychologistProfileDto } from './dto/psychologist-profile.dto';
import { PsychologistDocumentsDto } from './dto/psychologist-documents.dto';

type PsychologistDocumentFiles = {
    ktp?: Express.Multer.File;
    faceWithKtp?: Express.Multer.File;
    strLicense?: Express.Multer.File;
};

@Injectable()
export class ProfileService {
    constructor(
        private readonly prisma: PrismaService,
        private readonly supabaseService: SupabaseService,
    ) { }

    private getPublicBucket() {
        return process.env.SUPABASE_BUCKET?.trim() || 'partner';
    }

    private getPrivateBucket() {
        return process.env.SUPABASE_DOCUMENT_BUCKET?.trim() || 'partner-documents';
    }

    private async signPsychologistDocuments(profile: any) {
        if (!profile?.documents?.length) {
            return profile;
        }

        const documents = await Promise.all(
            profile.documents.map(async (document) => ({
                ...document,
                url: await this.supabaseService.getSignedUrl(this.getPrivateBucket(), document.url),
            })),
        );

        return {
            ...profile,
            documents,
        };
    }

    private parseStringArray(value: unknown) {
        if (Array.isArray(value)) {
            return value.map((item) => String(item).trim()).filter(Boolean);
        }

        if (typeof value !== 'string') {
            return undefined;
        }

        const trimmed = value.trim();
        if (!trimmed) {
            return undefined;
        }

        try {
            const parsed = JSON.parse(trimmed);
            if (Array.isArray(parsed)) {
                return parsed.map((item) => String(item).trim()).filter(Boolean);
            }
        } catch {
            // Fall back to comma-separated input.
        }

        return trimmed
            .split(',')
            .map((item) => item.trim())
            .filter(Boolean);
    }

    private parseNumber(value: unknown) {
        if (typeof value === 'number' && Number.isFinite(value)) {
            return value;
        }

        if (typeof value !== 'string') {
            return undefined;
        }

        const parsed = Number(value.trim());
        return Number.isFinite(parsed) ? parsed : undefined;
    }

    private parseBoolean(value: unknown) {
        if (typeof value === 'boolean') {
            return value;
        }

        if (typeof value !== 'string') {
            return undefined;
        }

        const normalized = value.trim().toLowerCase();

        if (['true', '1', 'yes', 'on'].includes(normalized)) {
            return true;
        }

        if (['false', '0', 'no', 'off'].includes(normalized)) {
            return false;
        }

        return undefined;
    }

    async getCurrentProfile(userId: string) {
        if (!userId?.trim()) {
            return null;
        }

        const profile = await this.prisma.user.findUnique({
            where: { id: userId.trim() },
            include: {
                clientProfile: true,
                psychologist: {
                    include: {
                        education: true,
                        documents: true,
                        schedules: true,
                    },
                },
            },
        });

        if (profile?.psychologist) {
            return {
                ...profile,
                psychologist: await this.signPsychologistDocuments(profile.psychologist),
            };
        }

        return profile;
    }

    private async upsertUser(data: {
        id: string;
        email?: string;
        displayName?: string;
        role: UserRole;
    }) {
        return this.prisma.user.upsert({
            where: { id: data.id },
            create: {
                id: data.id,
                email: data.email,
                displayName: data.displayName,
                role: data.role,
            },
            update: {
                email: data.email ?? undefined,
                displayName: data.displayName ?? undefined,
                role: data.role,
            },
        });
    }

    async upsertClientProfile(dto: ClientProfileDto, photoFile?: Express.Multer.File) {
        await this.upsertUser({
            id: dto.userId,
            email: dto.email,
            displayName: dto.displayName ?? dto.username,
            role: UserRole.CLIENT,
        });

        const photoUrl = photoFile
            ? await this.supabaseService.uploadFile(photoFile, this.getPublicBucket(), `clients/${dto.userId}`)
            : dto.photoUrl;

        return this.prisma.clientProfile.upsert({
            where: { userId: dto.userId },
            create: {
                userId: dto.userId,
                username: dto.username,
                birthDate: dto.birthDate ? new Date(dto.birthDate) : undefined,
                gender: dto.gender,
                photoUrl,
            },
            update: {
                username: dto.username,
                birthDate: dto.birthDate ? new Date(dto.birthDate) : undefined,
                gender: dto.gender,
                photoUrl,
            },
        });
    }

    async upsertPsychologistProfile(dto: PsychologistProfileDto, photoFile?: Express.Multer.File) {
        const userId = dto.userId?.trim();
        const nik = dto.nik?.trim();
        const strNumber = dto.strNumber?.trim();
        const education = this.parseStringArray((dto as unknown as { education?: unknown }).education) ?? dto.education ?? [];
        const tags = this.parseStringArray((dto as unknown as { tags?: unknown }).tags) ?? dto.tags ?? [];
        const clientsHandled = this.parseNumber((dto as unknown as { clientsHandled?: unknown }).clientsHandled) ?? dto.clientsHandled ?? 0;
        const yearsExperience = this.parseNumber((dto as unknown as { yearsExperience?: unknown }).yearsExperience) ?? dto.yearsExperience;
        const isAcceptingSessions = this.parseBoolean((dto as unknown as { isAcceptingSessions?: unknown }).isAcceptingSessions);
        const sessionPrice = this.parseNumber((dto as unknown as { sessionPrice?: unknown }).sessionPrice) ?? dto.sessionPrice;

        if (!userId) {
            throw new BadRequestException('userId is required');
        }

        const existingByUserId = await this.prisma.psychologist.findUnique({
            where: { userId },
            select: { id: true, nik: true, strNumber: true },
        });

        if (nik) {
            const duplicateNik = await this.prisma.psychologist.findUnique({
                where: { nik },
                select: { id: true, userId: true },
            });

            if (duplicateNik && duplicateNik.id !== existingByUserId?.id) {
                throw new ConflictException('nik already used by another psychologist');
            }
        }

        if (strNumber) {
            const duplicateStr = await this.prisma.psychologist.findUnique({
                where: { strNumber },
                select: { id: true, userId: true },
            });

            if (duplicateStr && duplicateStr.id !== existingByUserId?.id) {
                throw new ConflictException('strNumber already used by another psychologist');
            }
        }

        await this.upsertUser({
            id: userId,
            email: dto.email,
            displayName: dto.fullName,
            role: UserRole.PSYCHOLOGIST,
        });

        const photoUrl = photoFile
            ? await this.supabaseService.uploadFile(photoFile, this.getPublicBucket(), `psychologists/${userId}`)
            : dto.photoUrl;

        const createData: Prisma.PsychologistUncheckedCreateInput = {
            userId,
            fullName: dto.fullName,
            email: dto.email,
            phoneNumber: dto.phoneNumber,
            gender: dto.gender,
            location: dto.location,
            clinicName: dto.clinicName,
            specialization: dto.specialization,
            clientsHandled,
            yearsExperience,
            nik: nik ?? dto.nik,
            strNumber: strNumber ?? dto.strNumber,
            bio: dto.bio,
            tags,
            photoUrl,
            isAcceptingSessions: isAcceptingSessions ?? dto.isAcceptingSessions ?? true,
            sessionPrice: Math.max(0, Math.round(sessionPrice ?? 0)),
        };

        const updateData: Prisma.PsychologistUncheckedUpdateInput = {
            fullName: dto.fullName,
            email: dto.email,
            phoneNumber: dto.phoneNumber,
            gender: dto.gender,
            location: dto.location,
            clinicName: dto.clinicName,
            specialization: dto.specialization,
            clientsHandled,
            yearsExperience,
            nik: nik ?? dto.nik,
            strNumber: strNumber ?? dto.strNumber,
            bio: dto.bio,
            tags,
            photoUrl,
            ...(dto.isAcceptingSessions !== undefined
                ? { isAcceptingSessions: isAcceptingSessions ?? dto.isAcceptingSessions }
                : {}),
            ...(sessionPrice !== undefined
                ? { sessionPrice: Math.max(0, Math.round(sessionPrice)) }
                : {}),
        };

        return this.prisma.$transaction(async (tx) => {
            const psychologist = await tx.psychologist.upsert({
                where: { userId },
                create: createData,
                update: updateData,
            });

            if (dto.education?.length) {
                await tx.psychologistEducation.deleteMany({
                    where: { psychologistId: psychologist.id },
                });

                await tx.psychologistEducation.createMany({
                    data: dto.education.map((name) => ({
                        psychologistId: psychologist.id,
                        level: 'S1',
                        institution: name,
                    })),
                });
            }

            return psychologist;
        });
    }

    async updatePsychologistConsultationStatus(userId: string, isAcceptingSessions: boolean) {
        if (!userId?.trim()) {
            return null;
        }

        const psychologist = await this.prisma.psychologist.findUnique({
            where: { userId: userId.trim() },
            select: { id: true },
        });

        if (!psychologist) {
            return null;
        }

        return this.prisma.psychologist.update({
            where: { id: psychologist.id },
            data: { isAcceptingSessions },
        });
    }

    async replacePsychologistSchedules(
        userId: string,
        schedules: Array<{
            dayOfWeek: number;
            startTime: string;
            endTime: string;
            isAvailable?: boolean;
        }>,
    ) {
        if (!userId?.trim()) {
            return null;
        }

        const psychologist = await this.prisma.psychologist.findUnique({
            where: { userId: userId.trim() },
            select: { id: true },
        });

        if (!psychologist) {
            return null;
        }

        return this.prisma.$transaction(async (tx) => {
            await tx.psychologistSchedule.deleteMany({
                where: { psychologistId: psychologist.id },
            });

            if (schedules.length) {
                await tx.psychologistSchedule.createMany({
                    data: schedules.map((schedule) => ({
                        psychologistId: psychologist.id,
                        dayOfWeek: schedule.dayOfWeek,
                        startTime: schedule.startTime,
                        endTime: schedule.endTime,
                        isAvailable: schedule.isAvailable ?? true,
                    })),
                });
            }

            return tx.psychologist.findUnique({
                where: { id: psychologist.id },
                include: { schedules: true },
            });
        });
    }

    async getPsychologistDashboard(userId: string) {
        if (!userId?.trim()) {
            return null;
        }

        const psychologist = await this.prisma.psychologist.findUnique({
            where: { userId: userId.trim() },
            include: {
                schedules: true,
                user: {
                    select: { id: true, email: true, displayName: true, role: true },
                },
            },
        });

        if (!psychologist) {
            return null;
        }

        const now = new Date();
        const startOfDay = new Date(now);
        startOfDay.setHours(0, 0, 0, 0);

        const startOfNextDay = new Date(startOfDay);
        startOfNextDay.setDate(startOfNextDay.getDate() + 1);

        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
        const startOfNextMonth = new Date(now.getFullYear(), now.getMonth() + 1, 1);

        const [todaySessions, monthlyIncome, nextSession, pendingRequests, upcomingSessions] =
            await Promise.all([
                this.prisma.psychologistBooking.count({
                    where: {
                        psychologistId: psychologist.id,
                        scheduledAt: { gte: startOfDay, lt: startOfNextDay },
                        status: { in: ['PAID', 'CONFIRMED'] },
                    },
                }),
                this.prisma.psychologistBooking.aggregate({
                    where: {
                        psychologistId: psychologist.id,
                        paymentStatus: 'PAID',
                        createdAt: { gte: startOfMonth, lt: startOfNextMonth },
                    },
                    _sum: { price: true },
                }),
                this.prisma.psychologistBooking.findFirst({
                    where: {
                        psychologistId: psychologist.id,
                        scheduledAt: { gte: now },
                        status: { in: ['PAID', 'CONFIRMED'] },
                    },
                    orderBy: { scheduledAt: 'asc' },
                }),
                this.prisma.psychologistBooking.findMany({
                    where: {
                        psychologistId: psychologist.id,
                        status: 'PENDING_PAYMENT',
                    },
                    orderBy: { createdAt: 'desc' },
                    take: 10,
                }),
                this.prisma.psychologistBooking.findMany({
                    where: {
                        psychologistId: psychologist.id,
                        scheduledAt: { gte: now },
                        status: { in: ['PAID', 'CONFIRMED'] },
                    },
                    orderBy: { scheduledAt: 'asc' },
                    take: 10,
                }),
            ]);

        return {
            psychologist,
            stats: {
                totalSessionsToday: todaySessions,
                monthlyIncome: monthlyIncome._sum.price ?? 0,
                pendingRequests: pendingRequests.length,
            },
            nextSession,
            requests: pendingRequests,
            upcomingSessions,
        };
    }

    async respondToBooking(
        bookingId: string,
        userId: string,
        action: 'ACCEPT' | 'REJECT',
    ) {
        const booking = await this.prisma.psychologistBooking.findUnique({
            where: { id: bookingId },
            include: {
                psychologist: {
                    select: { userId: true },
                },
            },
        });

        if (!booking) {
            throw new BadRequestException('booking not found');
        }
        if (booking.psychologist.userId !== userId) {
            throw new BadRequestException('user not allowed');
        }

        const status = action === 'ACCEPT' ? 'CONFIRMED' : 'CANCELLED';

        return this.prisma.psychologistBooking.update({
            where: { id: bookingId },
            data: { status },
        });
    }

    async submitPsychologistDocuments(dto: PsychologistDocumentsDto, files?: PsychologistDocumentFiles) {
        const userId = dto.userId?.trim();

        if (!userId) {
            throw new BadRequestException('userId is required');
        }

        const psychologist = await this.prisma.psychologist.findUnique({
            where: { userId },
        });

        if (!psychologist) {
            return null;
        }

        const ktpUrl = files?.ktp
            ? await this.supabaseService.uploadPrivateFile(files.ktp, this.getPrivateBucket(), `psychologists/${userId}`)
            : dto.ktpUrl?.trim();
        const faceWithKtpUrl = files?.faceWithKtp
            ? await this.supabaseService.uploadPrivateFile(files.faceWithKtp, this.getPrivateBucket(), `psychologists/${userId}`)
            : dto.faceWithKtpUrl?.trim();
        const strLicenseUrl = files?.strLicense
            ? await this.supabaseService.uploadPrivateFile(files.strLicense, this.getPrivateBucket(), `psychologists/${userId}`)
            : dto.strLicenseUrl?.trim();

        if (!ktpUrl || !faceWithKtpUrl || !strLicenseUrl) {
            throw new BadRequestException('ktp, faceWithKtp, and strLicense are required');
        }

        const docs = [
            { type: 'KTP' as const, url: ktpUrl },
            { type: 'FACE_WITH_KTP' as const, url: faceWithKtpUrl },
            { type: 'STR_LICENSE' as const, url: strLicenseUrl },
        ];

        const savedDocs = await this.prisma.$transaction(
            docs.map((doc) =>
                this.prisma.psychologistVerificationDoc.upsert({
                    where: {
                        psychologistId_type: {
                            psychologistId: psychologist.id,
                            type: doc.type,
                        },
                    },
                    create: {
                        psychologistId: psychologist.id,
                        type: doc.type,
                        url: doc.url,
                    },
                    update: {
                        url: doc.url,
                        status: 'PENDING',
                    },
                }),
            ),
        );

        return this.signPsychologistDocuments({ documents: savedDocs });
    }

    async getClientProfile(userId: string) {
        if (!userId?.trim()) {
            throw new NotFoundException('client profile not found');
        }

        const profile = await this.prisma.clientProfile.findUnique({
            where: { userId: userId.trim() },
            include: {
                user: {
                    select: { id: true, email: true, displayName: true, role: true },
                },
            },
        });

        if (!profile) {
            throw new NotFoundException('client profile not found');
        }

        return this.signPsychologistDocuments(profile);
    }

    async getPsychologistProfile(userId: string) {
        if (!userId?.trim()) {
            throw new NotFoundException('psychologist profile not found');
        }

        const profile = await this.prisma.psychologist.findUnique({
            where: { userId: userId.trim() },
            include: {
                education: true,
                documents: true,
                schedules: true,
                user: {
                    select: { id: true, email: true, displayName: true, role: true },
                },
            },
        });

        if (!profile) {
            throw new NotFoundException('psychologist profile not found');
        }

        return profile;
    }
}
