import {
  BadRequestException,
  Injectable,
  InternalServerErrorException,
} from '@nestjs/common';
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

export type BookingDetailResult = {
  booking: {
    id: string;
    scheduledAt: Date;
    method: string;
    notes: string | null;
    status: string;
    paymentStatus: string;
    price: number;
    fullName: string;
  };
  client: {
    id: string;
    userId: string;
    username: string;
    age: number | null;
    gender: string | null;
    photoUrl: string | null;
  } | null;
  psychologist: {
    id: string;
    fullName: string;
    specialization: string;
    photoUrl: string | null;
  };
  latestAnalysis: {
    id: string;
    emotionLabel: string;
    summary: string;
    recommendations: unknown;
    createdAt: Date;
  } | null;
};

export type DaySessionResult = {
  date: string;
  dayLabel: string;
  psychologist: {
    id: string;
    fullName: string;
    isAcceptingSessions: boolean;
    schedules: Array<{
      id: string;
      dayOfWeek: number;
      startTime: string;
      endTime: string;
      isAvailable: boolean;
    }>;
  };
  sessions: Array<{
    bookingId: string;
    scheduledAt: Date;
    timeLabel: string;
    method: string;
    status: string;
    paymentStatus: string;
    fullName: string;
    notes: string | null;
    moodLabel: string | null;
    summary: string | null;
    clientPhotoUrl: string | null;
    durationMinutes: number;
  }>;
  timeline: Array<
    | {
        type: 'SESSION';
        bookingId: string;
        timeLabel: string;
        startAt: Date;
        endAt: Date;
        fullName: string;
        method: string;
        status: string;
        paymentStatus: string;
        moodLabel: string | null;
        summary: string | null;
        notes: string | null;
        clientPhotoUrl: string | null;
      }
    | {
        type: 'BREAK';
        label: string;
        startAt: Date;
        endAt: Date;
      }
  >;
  totalSessions: number;
};

export type ClientListResult = {
  items: Array<{
    clientId: string;
    userId: string;
    name: string;
    age: number | null;
    gender: string | null;
    photoUrl: string | null;
    bookingId: string;
    status: 'ACTIVE' | 'COMPLETED' | 'PENDING_PAYMENT';
    statusLabel: string;
    lastSessionAt: Date;
    lastSessionLabel: string;
    totalBookings: number;
    latestMoodLabel: string | null;
    latestSummary: string | null;
  }>;
  total: number;
  counts: {
    all: number;
    active: number;
    completed: number;
  };
};

export type IncomeHistoryResult = {
  totalBalance: number;
  transactions: Array<{
    bookingId: string;
    title: string;
    amount: number;
    amountLabel: string;
    dateLabel: string;
    timeLabel: string;
    scheduledAt: Date;
    clientName: string;
    method: string;
    status: string;
  }>;
  total: number;
};

export type ReviewListResult = {
  summary: {
    averageRating: number;
    totalReviews: number;
    breakdown: Array<{
      rating: number;
      count: number;
    }>;
  };
  items: Array<{
    reviewId: string;
    reviewerName: string;
    reviewerPhotoUrl: string | null;
    rating: number;
    comment: string | null;
    createdAt: Date;
    timeLabel: string;
    dayLabel: string;
  }>;
  total: number;
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
      process.env.GEMINI_API_KEY ||
      this.configService.get<string>('GEMINI_API_KEY');
    if (!apiKey) {
      throw new Error('GEMINI_API_KEY is missing');
    }
    this.ai = new GoogleGenAI({ apiKey });
  }

  async search(userId?: string, criteria?: string, limit = 10) {
    const safeLimit = Math.min(Math.max(limit, 1), 20);
    const candidates = await this.prismaService.psychologist.findMany({
      where: { isAcceptingSessions: true },
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
    const rankedIds = await this.rankWithGemini(
      candidates,
      criteria,
      moodContext,
    );
    if (!rankedIds?.length) {
      return candidates.map(this.toRanked);
    }

    const byId = new Map(candidates.map((item) => [item.id, item]));
    const ordered = rankedIds
      .map((id) => byId.get(id))
      .filter((item): item is (typeof candidates)[number] => Boolean(item));

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

  async getBookingDetail(
    bookingId: string,
  ): Promise<BookingDetailResult | null> {
    const booking = await this.prismaService.psychologistBooking.findUnique({
      where: { id: bookingId },
      include: {
        psychologist: {
          select: {
            id: true,
            fullName: true,
            specialization: true,
            photoUrl: true,
          },
        },
      },
    });

    if (!booking) {
      return null;
    }

    const [clientProfile, latestAnalysis] = await Promise.all([
      this.prismaService.clientProfile.findUnique({
        where: { userId: booking.userId },
        select: {
          id: true,
          userId: true,
          username: true,
          birthDate: true,
          gender: true,
          photoUrl: true,
        },
      }),
      this.prismaService.analysis.findFirst({
        where: { userId: booking.userId },
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          emotionLabel: true,
          summary: true,
          recommendations: true,
          createdAt: true,
        },
      }),
    ]);

    return {
      booking: {
        id: booking.id,
        scheduledAt: booking.scheduledAt,
        method: booking.method,
        notes: booking.notes,
        status: booking.status,
        paymentStatus: booking.paymentStatus,
        price: booking.price,
        fullName: booking.fullName,
      },
      client: clientProfile
        ? {
            id: clientProfile.id,
            userId: clientProfile.userId,
            username: clientProfile.username,
            age: clientProfile.birthDate
              ? this.calculateAge(clientProfile.birthDate)
              : null,
            gender: clientProfile.gender,
            photoUrl: clientProfile.photoUrl,
          }
        : null,
      psychologist: booking.psychologist,
      latestAnalysis: latestAnalysis
        ? {
            id: latestAnalysis.id,
            emotionLabel: latestAnalysis.emotionLabel,
            summary: latestAnalysis.summary,
            recommendations: latestAnalysis.recommendations,
            createdAt: latestAnalysis.createdAt,
          }
        : null,
    };
  }

  async getDaySessions(
    userId: string,
    dateInput?: string,
  ): Promise<DaySessionResult | null> {
    if (!userId?.trim()) {
      return null;
    }

    const psychologist = await this.prismaService.psychologist.findUnique({
      where: { userId: userId.trim() },
      select: {
        id: true,
        fullName: true,
        isAcceptingSessions: true,
        schedules: {
          select: {
            id: true,
            dayOfWeek: true,
            startTime: true,
            endTime: true,
            isAvailable: true,
          },
        },
      },
    });

    if (!psychologist) {
      return null;
    }

    const date = this.parseDateInput(dateInput);
    const startOfDay = new Date(date);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(startOfDay);
    endOfDay.setDate(endOfDay.getDate() + 1);

    const bookings = await this.prismaService.psychologistBooking.findMany({
      where: {
        psychologistId: psychologist.id,
        scheduledAt: {
          gte: startOfDay,
          lt: endOfDay,
        },
      },
      orderBy: { scheduledAt: 'asc' },
    });

    const userIds = bookings.map((booking) => booking.userId);
    const [clientProfiles, latestAnalyses] = await Promise.all([
      this.prismaService.clientProfile.findMany({
        where: { userId: { in: userIds } },
        select: {
          userId: true,
          photoUrl: true,
        },
      }),
      this.prismaService.analysis.findMany({
        where: { userId: { in: userIds } },
        orderBy: { createdAt: 'desc' },
      }),
    ]);

    const clientPhotoMap = new Map(
      clientProfiles.map((item) => [item.userId, item.photoUrl ?? null]),
    );
    const latestAnalysisMap = new Map<
      string,
      { moodLabel: string | null; summary: string | null }
    >();
    for (const analysis of latestAnalyses) {
      if (!latestAnalysisMap.has(analysis.userId || '')) {
        latestAnalysisMap.set(analysis.userId || '', {
          moodLabel: analysis.emotionLabel || null,
          summary: analysis.summary || null,
        });
      }
    }

    const sessions = bookings.map((booking) => {
      const analysis = latestAnalysisMap.get(booking.userId) || null;
      const scheduledAt = new Date(booking.scheduledAt);
      const durationMinutes = 60;
      return {
        bookingId: booking.id,
        scheduledAt,
        timeLabel: this.formatTime(scheduledAt),
        method: booking.method,
        status: booking.status,
        paymentStatus: booking.paymentStatus,
        fullName: booking.fullName,
        notes: booking.notes,
        moodLabel: analysis?.moodLabel ?? null,
        summary: analysis?.summary ?? null,
        clientPhotoUrl: clientPhotoMap.get(booking.userId) ?? null,
        durationMinutes,
      };
    });

    const timeline = this.buildTimeline(sessions, date);

    return {
      date: this.toDateKey(date),
      dayLabel: this.getDayLabel(date),
      psychologist: {
        id: psychologist.id,
        fullName: psychologist.fullName,
        isAcceptingSessions: psychologist.isAcceptingSessions,
        schedules: psychologist.schedules,
      },
      sessions,
      timeline,
      totalSessions: sessions.length,
    };
  }

  async getClients(
    userId: string,
    search?: string,
    status?: string,
  ): Promise<ClientListResult | null> {
    if (!userId?.trim()) {
      return null;
    }

    const psychologist = await this.prismaService.psychologist.findUnique({
      where: { userId: userId.trim() },
      select: { id: true },
    });

    if (!psychologist) {
      return null;
    }

    const bookings = await this.prismaService.psychologistBooking.findMany({
      where: { psychologistId: psychologist.id },
      orderBy: [{ scheduledAt: 'desc' }, { createdAt: 'desc' }],
    });

    const counts = {
      all: 0,
      active: 0,
      completed: 0,
    };

    const latestByUser = new Map<string, (typeof bookings)[number]>();
    for (const booking of bookings) {
      counts.all += 1;
      if (['PAID', 'CONFIRMED'].includes(booking.status)) {
        counts.active += 1;
      }
      if (booking.status === 'COMPLETED') {
        counts.completed += 1;
      }

      if (!latestByUser.has(booking.userId)) {
        latestByUser.set(booking.userId, booking);
      }
    }

    const searchValue = search?.trim().toLowerCase() ?? '';
    const normalizedStatus = (status?.trim().toUpperCase() || 'ALL') as
      | 'ALL'
      | 'ACTIVE'
      | 'COMPLETED';

    const uniqueBookings = Array.from(latestByUser.values());
    const userIds = uniqueBookings.map((booking) => booking.userId);

    const [clientProfiles, latestAnalyses, userProfiles] = await Promise.all([
      this.prismaService.clientProfile.findMany({
        where: { userId: { in: userIds } },
        select: {
          id: true,
          userId: true,
          username: true,
          birthDate: true,
          gender: true,
          photoUrl: true,
        },
      }),
      this.prismaService.analysis.findMany({
        where: { userId: { in: userIds } },
        orderBy: { createdAt: 'desc' },
      }),
      this.prismaService.user.findMany({
        where: { id: { in: userIds } },
        select: { id: true, displayName: true, email: true },
      }),
    ]);

    const clientProfileMap = new Map(
      clientProfiles.map((item) => [item.userId, item]),
    );
    const userMap = new Map(userProfiles.map((item) => [item.id, item]));
    const latestAnalysisMap = new Map<
      string,
      { emotionLabel: string | null; summary: string | null }
    >();
    for (const analysis of latestAnalyses) {
      if (!analysis.userId || latestAnalysisMap.has(analysis.userId)) {
        continue;
      }

      latestAnalysisMap.set(analysis.userId, {
        emotionLabel: analysis.emotionLabel || null,
        summary: analysis.summary || null,
      });
    }

    const items = uniqueBookings
      .map((booking) => {
        const clientProfile = clientProfileMap.get(booking.userId) || null;
        const user = userMap.get(booking.userId) || null;
        const displayName =
          clientProfile?.username ||
          user?.displayName ||
          booking.fullName ||
          'Unknown';
        const lastSessionAt = new Date(booking.scheduledAt);
        const status = this.getClientListStatus(booking.status);
        const statusLabel = this.getClientStatusLabel(status);
        const analysis = latestAnalysisMap.get(booking.userId) || null;

        return {
          clientId: clientProfile?.id ?? booking.userId,
          userId: booking.userId,
          name: displayName,
          age: clientProfile?.birthDate
            ? this.calculateAge(clientProfile.birthDate)
            : null,
          gender: clientProfile?.gender ?? null,
          photoUrl: clientProfile?.photoUrl ?? null,
          bookingId: booking.id,
          status,
          statusLabel,
          lastSessionAt,
          lastSessionLabel: this.formatLongDate(lastSessionAt),
          totalBookings: bookings.filter(
            (item) => item.userId === booking.userId,
          ).length,
          latestMoodLabel: analysis?.emotionLabel ?? null,
          latestSummary: analysis?.summary ?? null,
        };
      })
      .filter((item) => {
        const matchesSearch =
          !searchValue ||
          item.name.toLowerCase().includes(searchValue) ||
          item.userId.toLowerCase().includes(searchValue);

        const matchesStatus =
          normalizedStatus === 'ALL' || normalizedStatus === item.status;

        return matchesSearch && matchesStatus;
      })
      .sort(
        (left, right) =>
          right.lastSessionAt.getTime() - left.lastSessionAt.getTime(),
      );

    return {
      items,
      total: items.length,
      counts,
    };
  }

  async getIncomeHistory(
    userId: string,
    limit = 50,
  ): Promise<IncomeHistoryResult | null> {
    if (!userId?.trim()) {
      return null;
    }

    const psychologist = await this.prismaService.psychologist.findUnique({
      where: { userId: userId.trim() },
      select: { id: true },
    });

    if (!psychologist) {
      return null;
    }

    const safeLimit = Math.min(Math.max(Number(limit) || 0, 1), 100);

    const [paidBookings, balanceAggregate] = await Promise.all([
      this.prismaService.psychologistBooking.findMany({
        where: {
          psychologistId: psychologist.id,
          paymentStatus: 'PAID',
        },
        orderBy: { createdAt: 'desc' },
        take: safeLimit,
      }),
      this.prismaService.psychologistBooking.aggregate({
        where: {
          psychologistId: psychologist.id,
          paymentStatus: 'PAID',
        },
        _sum: { price: true },
        _count: { _all: true },
      }),
    ]);

    const transactions = paidBookings.map((booking) => {
      const scheduledAt = new Date(booking.scheduledAt);
      const amount = booking.price || 0;

      return {
        bookingId: booking.id,
        title: 'Pembayaran Masuk',
        amount,
        amountLabel: `+${this.formatRupiah(amount)}`,
        dateLabel: this.formatLongDateTime(scheduledAt),
        timeLabel: this.formatTimeWithWIB(scheduledAt),
        scheduledAt,
        clientName: booking.fullName,
        method: booking.method,
        status: booking.status,
      };
    });

    return {
      totalBalance: balanceAggregate._sum.price ?? 0,
      transactions,
      total: balanceAggregate._count._all,
    };
  }

  async getReviewSummary(
    userId: string,
    limit = 20,
    page = 1,
  ): Promise<ReviewListResult | null> {
    if (!userId?.trim()) {
      return null;
    }

    const psychologist = await this.prismaService.psychologist.findUnique({
      where: { userId: userId.trim() },
      select: { id: true },
    });

    if (!psychologist) {
      return null;
    }

    const safeLimit = Math.min(Math.max(Number(limit) || 0, 1), 50);
    const safePage = Math.max(Number(page) || 1, 1);
    const skip = (safePage - 1) * safeLimit;

    const [stats, total, reviews] = await Promise.all([
      this.prismaService.psychologistReview.aggregate({
        where: { psychologistId: psychologist.id },
        _avg: { rating: true },
        _count: { rating: true },
      }),
      this.prismaService.psychologistReview.count({
        where: { psychologistId: psychologist.id },
      }),
      this.prismaService.psychologistReview.findMany({
        where: { psychologistId: psychologist.id },
        orderBy: { createdAt: 'desc' },
        take: safeLimit,
        skip,
      }),
    ]);

    const reviewerIds = [...new Set(reviews.map((review) => review.userId))];
    const [clientProfiles, userProfiles] = await Promise.all([
      this.prismaService.clientProfile.findMany({
        where: { userId: { in: reviewerIds } },
        select: { userId: true, username: true, photoUrl: true },
      }),
      this.prismaService.user.findMany({
        where: { id: { in: reviewerIds } },
        select: { id: true, displayName: true },
      }),
    ]);

    const clientMap = new Map(
      clientProfiles.map((item) => [item.userId, item]),
    );
    const userMap = new Map(userProfiles.map((item) => [item.id, item]));

    const breakdown = await Promise.all(
      [5, 4, 3, 2, 1].map(async (rating) => {
        const count = await this.prismaService.psychologistReview.count({
          where: {
            psychologistId: psychologist.id,
            rating,
          },
        });

        return { rating, count };
      }),
    );

    return {
      summary: {
        averageRating: Number((stats._avg.rating ?? 0).toFixed(1)),
        totalReviews: total,
        breakdown,
      },
      items: reviews.map((review) => {
        const client = clientMap.get(review.userId) || null;
        const user = userMap.get(review.userId) || null;
        const reviewerName = client?.username || user?.displayName || 'Anonim';
        const createdAt = new Date(review.createdAt);

        return {
          reviewId: review.id,
          reviewerName,
          reviewerPhotoUrl: client?.photoUrl ?? null,
          rating: review.rating,
          comment: review.comment,
          createdAt,
          timeLabel: this.formatRelativeTime(createdAt),
          dayLabel: this.formatLongDate(createdAt),
        };
      }),
      total,
    };
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

    const psychologist = await this.prismaService.psychologist.findUnique({
      where: { id: psychologistId },
      select: { isAcceptingSessions: true },
    });

    if (!psychologist) {
      throw new BadRequestException('psychologist not found');
    }
    if (!psychologist.isAcceptingSessions) {
      throw new BadRequestException('psychologist is not accepting sessions');
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

  async updateConsultationStatus(userId: string, isAcceptingSessions: boolean) {
    const psychologist = await this.prismaService.psychologist.findUnique({
      where: { userId },
      select: { id: true },
    });

    if (!psychologist) {
      throw new BadRequestException('psychologist not found');
    }

    return this.prismaService.psychologist.update({
      where: { id: psychologist.id },
      data: { isAcceptingSessions },
    });
  }

  async replaceSchedules(
    userId: string,
    schedules: Array<{
      dayOfWeek: number;
      startTime: string;
      endTime: string;
      isAvailable?: boolean;
    }>,
  ) {
    const psychologist = await this.prismaService.psychologist.findUnique({
      where: { userId },
      select: { id: true },
    });

    if (!psychologist) {
      throw new BadRequestException('psychologist not found');
    }

    return this.prismaService.$transaction(async (tx) => {
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

  async getDashboard(userId: string) {
    const psychologist = await this.prismaService.psychologist.findUnique({
      where: { userId },
      include: {
        schedules: true,
        user: {
          select: { id: true, email: true, displayName: true, role: true },
        },
      },
    });

    if (!psychologist) {
      throw new BadRequestException('psychologist not found');
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
      requests,
      upcomingSessions,
    ] = await Promise.all([
      this.prismaService.psychologistBooking.count({
        where: {
          psychologistId: psychologist.id,
          scheduledAt: { gte: startOfDay, lt: startOfNextDay },
          status: { in: ['PAID', 'CONFIRMED', 'COMPLETED'] },
        },
      }),
      this.prismaService.psychologistBooking.aggregate({
        where: {
          psychologistId: psychologist.id,
          paymentStatus: 'PAID',
          createdAt: { gte: startOfMonth, lt: startOfNextMonth },
        },
        _sum: { price: true },
      }),
      this.prismaService.psychologistBooking.findFirst({
        where: {
          psychologistId: psychologist.id,
          scheduledAt: { gte: now },
          status: { in: ['PAID', 'CONFIRMED', 'COMPLETED'] },
        },
        orderBy: { scheduledAt: 'asc' },
      }),
      this.prismaService.psychologistBooking.findMany({
        where: {
          psychologistId: psychologist.id,
          status: 'PENDING_PAYMENT',
        },
        orderBy: { createdAt: 'desc' },
        take: 10,
      }),
      this.prismaService.psychologistBooking.findMany({
        where: {
          psychologistId: psychologist.id,
          scheduledAt: { gte: now },
          status: { in: ['PAID', 'CONFIRMED', 'COMPLETED'] },
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
        pendingRequests: requests.length,
      },
      nextSession,
      requests,
      upcomingSessions,
    };
  }

  async respondToBooking(
    bookingId: string,
    userId: string,
    action: 'ACCEPT' | 'REJECT',
  ) {
    const booking = await this.prismaService.psychologistBooking.findUnique({
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

    return this.prismaService.psychologistBooking.update({
      where: { id: bookingId },
      data: { status: action === 'ACCEPT' ? 'CONFIRMED' : 'CANCELLED' },
    });
  }

  async completeBooking(bookingId: string, userId: string) {
    const booking = await this.prismaService.psychologistBooking.findUnique({
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
    if (!['CONFIRMED', 'PAID'].includes(booking.status)) {
      throw new BadRequestException(
        'booking must be confirmed before completing',
      );
    }

    return this.prismaService.psychologistBooking.update({
      where: { id: bookingId },
      data: { status: 'COMPLETED' },
    });
  }

  async addReview(
    userId: string,
    psychologistId: string,
    rating: number,
    comment?: string,
  ) {
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

    const baseUrl =
      this.configService.get<string>('APP_BASE_URL') || 'http://localhost:3000';
    const verifyUrl = `${baseUrl}/psychologist/verification/confirm/${token}`;

    const mailer = this.mailer ?? this.createMailer();
    this.mailer = mailer;

    await mailer.sendMail({
      from:
        this.configService.get<string>('SMTP_FROM') || 'no-reply@example.com',
      to: psychologist.email,
      subject: 'Verifikasi Psikolog Partner',
      text: `Klik link berikut untuk verifikasi: ${verifyUrl}`,
    });

    return { status: 'sent' };
  }

  async confirmEmailVerification(token: string) {
    const verification =
      await this.prismaService.psychologistEmailVerification.findUnique({
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

  private calculateAge(birthDate: Date) {
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    if (
      monthDiff < 0 ||
      (monthDiff === 0 && today.getDate() < birthDate.getDate())
    ) {
      age -= 1;
    }
    return age;
  }

  private parseDateInput(dateInput?: string) {
    if (!dateInput) {
      return new Date();
    }

    const parsed = new Date(dateInput);
    if (Number.isNaN(parsed.getTime())) {
      throw new BadRequestException('date is invalid');
    }

    return parsed;
  }

  private toDateKey(date: Date) {
    return new Intl.DateTimeFormat('en-CA', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      timeZone: 'Asia/Jakarta',
    }).format(date);
  }

  private getDayLabel(date: Date) {
    const value = new Intl.DateTimeFormat('id-ID', {
      weekday: 'long',
      timeZone: 'Asia/Jakarta',
    }).format(date);

    return value.charAt(0).toUpperCase() + value.slice(1);
  }

  private formatLongDate(date: Date) {
    return new Intl.DateTimeFormat('id-ID', {
      day: 'numeric',
      month: 'long',
      year: 'numeric',
      timeZone: 'Asia/Jakarta',
    }).format(date);
  }

  private formatRelativeTime(date: Date) {
    const now = new Date();
    const diffMinutes = Math.max(
      1,
      Math.round((now.getTime() - date.getTime()) / 60000),
    );

    if (diffMinutes < 60) {
      return `${diffMinutes} menit lalu`;
    }

    const diffHours = Math.round(diffMinutes / 60);
    if (diffHours < 24) {
      return `${diffHours} jam lalu`;
    }

    const diffDays = Math.round(diffHours / 24);
    return `${diffDays} hari lalu`;
  }

  private formatLongDateTime(date: Date) {
    return new Intl.DateTimeFormat('id-ID', {
      day: 'numeric',
      month: 'long',
      year: 'numeric',
      timeZone: 'Asia/Jakarta',
    }).format(date);
  }

  private formatTimeWithWIB(date: Date) {
    return `${new Intl.DateTimeFormat('id-ID', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: false,
      timeZone: 'Asia/Jakarta',
    }).format(date)} WIB`;
  }

  private formatRupiah(amount: number) {
    return new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      maximumFractionDigits: 0,
    })
      .format(amount)
      .replace(/^Rp\s?/, 'Rp. ');
  }

  private getClientStatusLabel(status: string) {
    if (status === 'COMPLETED') {
      return 'Selesai';
    }

    if (status === 'ACTIVE') {
      return 'Aktif';
    }

    return 'Menunggu';
  }

  private getClientListStatus(
    status: string,
  ): 'ACTIVE' | 'COMPLETED' | 'PENDING_PAYMENT' {
    if (status === 'COMPLETED') {
      return 'COMPLETED';
    }

    if (status === 'PAID' || status === 'CONFIRMED') {
      return 'ACTIVE';
    }

    return 'PENDING_PAYMENT';
  }

  private formatTime(date: Date) {
    return new Intl.DateTimeFormat('id-ID', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: false,
      timeZone: 'Asia/Jakarta',
    }).format(date);
  }

  private buildTimeline(
    sessions: Array<{
      bookingId: string;
      scheduledAt: Date;
      timeLabel: string;
      method: string;
      status: string;
      paymentStatus: string;
      fullName: string;
      notes: string | null;
      moodLabel: string | null;
      summary: string | null;
      clientPhotoUrl: string | null;
      durationMinutes: number;
    }>,
    date: Date,
  ) {
    const sortedSessions = [...sessions].sort(
      (left, right) => left.scheduledAt.getTime() - right.scheduledAt.getTime(),
    );
    const timeline: DaySessionResult['timeline'] = [];

    const dayStart = new Date(date);
    dayStart.setHours(0, 0, 0, 0);

    let cursor = new Date(dayStart);

    for (const session of sortedSessions) {
      const sessionStart = new Date(session.scheduledAt);
      const sessionEnd = new Date(
        sessionStart.getTime() + session.durationMinutes * 60 * 1000,
      );

      if (sessionStart.getTime() > cursor.getTime()) {
        timeline.push({
          type: 'BREAK',
          label: 'Waktu Istirahat',
          startAt: new Date(cursor),
          endAt: new Date(sessionStart),
        });
      }

      timeline.push({
        type: 'SESSION',
        bookingId: session.bookingId,
        timeLabel: session.timeLabel,
        startAt: sessionStart,
        endAt: sessionEnd,
        fullName: session.fullName,
        method: session.method,
        status: session.status,
        paymentStatus: session.paymentStatus,
        moodLabel: session.moodLabel,
        summary: session.summary,
        notes: session.notes,
        clientPhotoUrl: session.clientPhotoUrl,
      });

      cursor = sessionEnd;
    }

    return timeline;
  }
}
