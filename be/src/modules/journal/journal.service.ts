import { BadRequestException, Injectable, InternalServerErrorException, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GoogleGenAI } from '@google/genai';
import { PrismaService } from '../prisma/prisma.service';
import { CreateJournalDto } from './dto/create-journal.dto';
import { UpdateJournalDto } from './dto/update-journal.dto';

export type JournalMoodResult = {
    moodLabel: string;
    moodCategory: 'POSITIVE' | 'CALM' | 'ANXIOUS' | 'SAD' | 'ANGRY' | 'BURNOUT' | 'NEUTRAL';
    summary: string;
    confidence?: number;
};

@Injectable()
export class JournalService {
    private readonly ai: GoogleGenAI;

    constructor(
        private readonly prismaService: PrismaService,
        private readonly configService: ConfigService,
    ) {
        const apiKey = process.env.GEMINI_API_KEY || this.configService.get<string>('GEMINI_API_KEY');
        if (!apiKey) {
            throw new Error('GEMINI_API_KEY is missing');
        }
        this.ai = new GoogleGenAI({ apiKey });
    }

    async createJournal(userId: string, dto: CreateJournalDto) {
        this.assertUserId(userId);
        this.assertJournalFields(dto.title, dto.content);

        const analysis = await this.analyzeMood(dto.title, dto.content);

        return this.prismaService.journal.create({
            data: {
                userId: userId.trim(),
                title: dto.title.trim(),
                content: dto.content.trim(),
                moodLabel: analysis.moodLabel,
                moodCategory: analysis.moodCategory,
                moodConfidence: analysis.confidence ?? null,
                summary: analysis.summary,
                rawJson: analysis,
            },
        });
    }

    async listJournals(userId: string, limit = 20, offset = 0) {
        this.assertUserId(userId);
        const safeLimit = Math.min(Math.max(limit, 1), 50);
        const safeOffset = Math.max(offset, 0);

        const [items, total] = await this.prismaService.$transaction([
            this.prismaService.journal.findMany({
                where: { userId: userId.trim() },
                orderBy: { createdAt: 'desc' },
                take: safeLimit,
                skip: safeOffset,
            }),
            this.prismaService.journal.count({
                where: { userId: userId.trim() },
            }),
        ]);

        return { total, items };
    }

    async getJournal(userId: string, id: string) {
        this.assertUserId(userId);
        const journal = await this.prismaService.journal.findFirst({
            where: { id, userId: userId.trim() },
        });

        if (!journal) {
            throw new NotFoundException('journal not found');
        }

        return journal;
    }

    async updateJournal(userId: string, id: string, dto: UpdateJournalDto) {
        this.assertUserId(userId);

        const journal = await this.prismaService.journal.findFirst({
            where: { id, userId: userId.trim() },
        });
        if (!journal) {
            throw new NotFoundException('journal not found');
        }

        const title = dto.title?.trim() || journal.title;
        const content = dto.content?.trim() || journal.content;
        this.assertJournalFields(title, content);

        const analysis = await this.analyzeMood(title, content);

        return this.prismaService.journal.update({
            where: { id },
            data: {
                title,
                content,
                moodLabel: analysis.moodLabel,
                moodCategory: analysis.moodCategory,
                moodConfidence: analysis.confidence ?? null,
                summary: analysis.summary,
                rawJson: analysis,
            },
        });
    }

    async deleteJournal(userId: string, id: string) {
        this.assertUserId(userId);

        const journal = await this.prismaService.journal.findFirst({
            where: { id, userId: userId.trim() },
        });
        if (!journal) {
            throw new NotFoundException('journal not found');
        }

        await this.prismaService.journal.delete({ where: { id } });
        return { status: 'deleted' };
    }

    private async analyzeMood(title: string, content: string) {
        const prompt = [
            'Kamu adalah asisten yang menganalisis mood dari jurnal harian dengan empatik dan hati-hati.',
            'Baca judul dan isi jurnal, lalu kembalikan JSON murni tanpa markdown.',
            'Format JSON wajib: {"moodLabel": string, "moodCategory": "POSITIVE|CALM|ANXIOUS|SAD|ANGRY|BURNOUT|NEUTRAL", "summary": string, "confidence": number}',
            'Gunakan Bahasa Indonesia yang ringkas, jelas, dan suportif.',
            'moodLabel harus berupa label pendek seperti "Cemas Ringan", "Lelah", "Tenang", atau "Bahagia".',
            'moodCategory pilih satu yang paling sesuai berdasarkan isi jurnal.',
            '',
            'Judul jurnal:',
            title,
            '',
            'Isi jurnal:',
            content,
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
            throw new InternalServerErrorException(`failed to call Gemini API: ${error?.message || error}`);
        }

        const parsed = this.safeParseJson(rawText);
        if (!parsed) {
            throw new InternalServerErrorException('invalid response format from Gemini');
        }

        const moodCategory = this.normalizeMoodCategory(parsed.moodCategory ?? parsed.category ?? parsed.mood);
        const moodLabel = String(parsed.moodLabel ?? parsed.label ?? '').trim();
        const summary = String(parsed.summary ?? '').trim();
        const confidence = typeof parsed.confidence === 'number' ? parsed.confidence : undefined;

        if (!moodLabel || !summary) {
            throw new InternalServerErrorException('incomplete response from Gemini');
        }

        return {
            moodLabel,
            moodCategory,
            summary,
            confidence,
            raw: parsed,
        };
    }

    private normalizeMoodCategory(value: unknown): JournalMoodResult['moodCategory'] {
        const normalized = String(value ?? '').trim().toUpperCase();
        const allowed: JournalMoodResult['moodCategory'][] = [
            'POSITIVE',
            'CALM',
            'ANXIOUS',
            'SAD',
            'ANGRY',
            'BURNOUT',
            'NEUTRAL',
        ];

        if (allowed.includes(normalized as JournalMoodResult['moodCategory'])) {
            return normalized as JournalMoodResult['moodCategory'];
        }

        return 'NEUTRAL';
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

    private assertUserId(userId: string) {
        if (!userId?.trim()) {
            throw new BadRequestException('userId is required');
        }
    }

    private assertJournalFields(title: string, content: string) {
        if (!title?.trim()) {
            throw new BadRequestException('title is required');
        }
        if (!content?.trim()) {
            throw new BadRequestException('content is required');
        }
    }
}
