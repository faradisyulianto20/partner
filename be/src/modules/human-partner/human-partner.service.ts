import { BadRequestException, Injectable } from '@nestjs/common';
import { EnergyCategory } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

export type MatchResult =
  | { status: 'matched'; matchId: string; partnerUserId: string }
  | { status: 'queued' };

@Injectable()
export class HumanPartnerService {
  constructor(private readonly prismaService: PrismaService) {}

  async joinQueue(userId: string): Promise<MatchResult> {
    const safeUserId = userId?.trim();
    if (!safeUserId) {
      throw new BadRequestException('userId is required');
    }

    const existingMatch = await this.prismaService.partnerMatch.findFirst({
      where: {
        status: 'ACTIVE',
        OR: [{ userAId: safeUserId }, { userBId: safeUserId }],
      },
    });
    if (existingMatch) {
      const partnerUserId =
        existingMatch.userAId === safeUserId
          ? existingMatch.userBId
          : existingMatch.userAId;
      return { status: 'matched', matchId: existingMatch.id, partnerUserId };
    }

    const existingQueue = await this.prismaService.partnerQueue.findFirst({
      where: { userId: safeUserId },
    });
    if (existingQueue) {
      return { status: 'queued' };
    }

    const energy = await this.resolveEnergy(safeUserId);
    const candidates = await this.findCandidateQueue(safeUserId, energy);
    for (const candidate of candidates) {
      const blocked = await this.isBlocked(safeUserId, candidate.userId);
      if (blocked) {
        continue;
      }

      const match = await this.prismaService.partnerMatch.create({
        data: {
          userAId: safeUserId,
          userBId: candidate.userId,
          energyA: energy,
          energyB: candidate.energy,
          status: 'ACTIVE',
        },
      });

      await this.prismaService.partnerQueue.deleteMany({
        where: { userId: { in: [safeUserId, candidate.userId] } },
      });

      return {
        status: 'matched',
        matchId: match.id,
        partnerUserId: candidate.userId,
      };
    }

    await this.prismaService.partnerQueue.create({
      data: {
        userId: safeUserId,
        energy,
      },
    });

    return { status: 'queued' };
  }

  async leaveQueue(userId: string) {
    const safeUserId = userId?.trim();
    if (!safeUserId) {
      throw new BadRequestException('userId is required');
    }

    await this.prismaService.partnerQueue.deleteMany({
      where: { userId: safeUserId },
    });

    return { status: 'left' };
  }

  async getMatch(matchId: string) {
    return this.prismaService.partnerMatch.findUnique({
      where: { id: matchId },
      include: {
        messages: { orderBy: { createdAt: 'asc' } },
      },
    });
  }

  async addFavorite(userId: string, targetUserId: string) {
    const safeUserId = userId?.trim();
    const safeTarget = targetUserId?.trim();
    if (!safeUserId || !safeTarget) {
      throw new BadRequestException('userId and targetUserId are required');
    }

    return this.prismaService.partnerFavorite.create({
      data: {
        userId: safeUserId,
        partnerId: safeTarget,
      },
    });
  }

  async blockUser(userId: string, targetUserId: string, reason?: string) {
    const safeUserId = userId?.trim();
    const safeTarget = targetUserId?.trim();
    if (!safeUserId || !safeTarget) {
      throw new BadRequestException('userId and targetUserId are required');
    }

    await this.prismaService.partnerBlock.create({
      data: {
        userId: safeUserId,
        blockedUserId: safeTarget,
        reason: reason?.trim() || null,
      },
    });

    await this.prismaService.partnerMatch.updateMany({
      where: {
        status: 'ACTIVE',
        OR: [
          { userAId: safeUserId, userBId: safeTarget },
          { userAId: safeTarget, userBId: safeUserId },
        ],
      },
      data: { status: 'CLOSED' },
    });

    return { status: 'blocked' };
  }

  async reportUser(userId: string, targetUserId: string, reason: string) {
    const safeUserId = userId?.trim();
    const safeTarget = targetUserId?.trim();
    if (!safeUserId || !safeTarget || !reason?.trim()) {
      throw new BadRequestException(
        'userId, targetUserId, and reason are required',
      );
    }

    return this.prismaService.partnerReport.create({
      data: {
        userId: safeUserId,
        reportedUserId: safeTarget,
        reason: reason.trim(),
      },
    });
  }

  async listFavorites(userId: string) {
    const safeUserId = userId?.trim();
    if (!safeUserId) {
      throw new BadRequestException('userId is required');
    }

    return this.prismaService.partnerFavorite.findMany({
      where: { userId: safeUserId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async saveMessage(matchId: string, userId: string, content: string) {
    return this.prismaService.partnerMessage.create({
      data: {
        matchId,
        userId,
        content,
      },
    });
  }

  async validateParticipant(matchId: string, userId: string) {
    const match = await this.prismaService.partnerMatch.findUnique({
      where: { id: matchId },
    });
    if (!match) {
      throw new BadRequestException('match not found');
    }
    if (match.userAId !== userId && match.userBId !== userId) {
      throw new BadRequestException('user not in match');
    }
    return match;
  }

  private async resolveEnergy(userId: string): Promise<EnergyCategory> {
    const latest = await this.prismaService.analysis.findFirst({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });

    return latest?.energyCategory || EnergyCategory.NEUTRAL;
  }

  private async findCandidateQueue(userId: string, energy: EnergyCategory) {
    const energyFilter = this.resolveEnergyFilter(energy);
    return this.prismaService.partnerQueue.findMany({
      where: {
        userId: { not: userId },
        energy: energyFilter,
      },
      orderBy: { createdAt: 'asc' },
    });
  }

  private resolveEnergyFilter(energy: EnergyCategory) {
    if (energy === EnergyCategory.POSITIVE) {
      return EnergyCategory.NEGATIVE;
    }
    if (energy === EnergyCategory.NEGATIVE) {
      return EnergyCategory.POSITIVE;
    }
    return {
      in: [
        EnergyCategory.POSITIVE,
        EnergyCategory.NEGATIVE,
        EnergyCategory.NEUTRAL,
      ],
    };
  }

  private async isBlocked(userId: string, otherUserId: string) {
    const blocked = await this.prismaService.partnerBlock.findFirst({
      where: {
        OR: [
          { userId, blockedUserId: otherUserId },
          { userId: otherUserId, blockedUserId: userId },
        ],
      },
    });

    return Boolean(blocked);
  }
}
