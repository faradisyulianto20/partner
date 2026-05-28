import { Injectable } from '@nestjs/common';
import { Prisma, UserRole } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { ClientProfileDto } from './dto/client-profile.dto';
import { PsychologistProfileDto } from './dto/psychologist-profile.dto';
import { PsychologistDocumentsDto } from './dto/psychologist-documents.dto';

@Injectable()
export class ProfileService {
    constructor(private readonly prisma: PrismaService) { }

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

    async upsertClientProfile(dto: ClientProfileDto) {
        await this.upsertUser({
            id: dto.userId,
            email: dto.email,
            displayName: dto.displayName ?? dto.username,
            role: UserRole.CLIENT,
        });

        return this.prisma.clientProfile.upsert({
            where: { userId: dto.userId },
            create: {
                userId: dto.userId,
                username: dto.username,
                birthDate: dto.birthDate ? new Date(dto.birthDate) : undefined,
                gender: dto.gender,
                photoUrl: dto.photoUrl,
            },
            update: {
                username: dto.username,
                birthDate: dto.birthDate ? new Date(dto.birthDate) : undefined,
                gender: dto.gender,
                photoUrl: dto.photoUrl,
            },
        });
    }

    async upsertPsychologistProfile(dto: PsychologistProfileDto) {
        await this.upsertUser({
            id: dto.userId,
            email: dto.email,
            displayName: dto.fullName,
            role: UserRole.PSYCHOLOGIST,
        });

        const profileData: Prisma.PsychologistUncheckedCreateInput = {
            userId: dto.userId,
            fullName: dto.fullName,
            email: dto.email,
            phoneNumber: dto.phoneNumber,
            gender: dto.gender,
            location: dto.location,
            clinicName: dto.clinicName,
            specialization: dto.specialization,
            clientsHandled: dto.clientsHandled ?? 0,
            yearsExperience: dto.yearsExperience,
            nik: dto.nik,
            strNumber: dto.strNumber,
            bio: dto.bio,
            tags: dto.tags ?? [],
            photoUrl: dto.photoUrl,
        };

        return this.prisma.$transaction(async (tx) => {
            const psychologist = await tx.psychologist.upsert({
                where: { userId: dto.userId },
                create: profileData,
                update: profileData,
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

    async submitPsychologistDocuments(dto: PsychologistDocumentsDto) {
        const psychologist = await this.prisma.psychologist.findUnique({
            where: { userId: dto.userId },
        });

        if (!psychologist) {
            return null;
        }

        const docs = [
            { type: 'KTP' as const, url: dto.ktpUrl },
            { type: 'FACE_WITH_KTP' as const, url: dto.faceWithKtpUrl },
            { type: 'STR_LICENSE' as const, url: dto.strLicenseUrl },
        ];

        return this.prisma.$transaction(
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
    }
}
