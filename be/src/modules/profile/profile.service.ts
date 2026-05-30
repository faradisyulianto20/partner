import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma, UserRole } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { ClientProfileDto } from './dto/client-profile.dto';
import { PsychologistProfileDto } from './dto/psychologist-profile.dto';
import { PsychologistDocumentsDto } from './dto/psychologist-documents.dto';

@Injectable()
export class ProfileService {
  constructor(private readonly prisma: PrismaService) {}

  async getCurrentProfile(userId: string) {
    if (!userId?.trim()) {
      return null;
    }

    return this.prisma.user.findUnique({
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
    const userId = dto.userId?.trim();
    const nik = dto.nik?.trim();
    const strNumber = dto.strNumber?.trim();

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
        throw new ConflictException(
          'strNumber already used by another psychologist',
        );
      }
    }

    await this.upsertUser({
      id: userId,
      email: dto.email,
      displayName: dto.fullName,
      role: UserRole.PSYCHOLOGIST,
    });

    const createData: Prisma.PsychologistUncheckedCreateInput = {
      userId,
      fullName: dto.fullName,
      email: dto.email,
      phoneNumber: dto.phoneNumber,
      gender: dto.gender,
      location: dto.location,
      clinicName: dto.clinicName,
      specialization: dto.specialization,
      clientsHandled: dto.clientsHandled ?? 0,
      yearsExperience: dto.yearsExperience,
      nik: nik ?? dto.nik,
      strNumber: strNumber ?? dto.strNumber,
      bio: dto.bio,
      tags: dto.tags ?? [],
      photoUrl: dto.photoUrl,
      isAcceptingSessions: dto.isAcceptingSessions ?? true,
    };

    const updateData: Prisma.PsychologistUncheckedUpdateInput = {
      fullName: dto.fullName,
      email: dto.email,
      phoneNumber: dto.phoneNumber,
      gender: dto.gender,
      location: dto.location,
      clinicName: dto.clinicName,
      specialization: dto.specialization,
      clientsHandled: dto.clientsHandled ?? 0,
      yearsExperience: dto.yearsExperience,
      nik: nik ?? dto.nik,
      strNumber: strNumber ?? dto.strNumber,
      bio: dto.bio,
      tags: dto.tags ?? [],
      photoUrl: dto.photoUrl,
      ...(dto.isAcceptingSessions !== undefined
        ? { isAcceptingSessions: dto.isAcceptingSessions }
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

  async updatePsychologistConsultationStatus(
    userId: string,
    isAcceptingSessions: boolean,
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

    const [
      todaySessions,
      monthlyIncome,
      nextSession,
      pendingRequests,
      upcomingSessions,
    ] = await Promise.all([
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

    return profile;
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
