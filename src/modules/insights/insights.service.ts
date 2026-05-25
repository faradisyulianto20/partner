import { BadRequestException, Injectable, ServiceUnavailableException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GoogleGenerativeAI } from '@google/generative-ai';
import { PrismaService } from '../../prisma/prisma.service';

interface GeminiResult {
    moodLabel: string;
    moodScore?: number;
    summary?: string;
    recommendations?: string[];
}

@Injectable()
export class InsightsService {
    private readonly ai: GoogleGenerativeAI;

    constructor(
        private readonly prisma: PrismaService,
        private readonly configService: ConfigService,
    ) {
        const apiKey = this.configService.get<string>('GEMINI_API_KEY') || process.env.GEMINI_API_KEY;

        if (!apiKey) {
            throw new Error('Gemini API Key is missing in environment variables');
        }

        this.ai = new GoogleGenerativeAI(apiKey);
    }

    private extractJson(text: string) {
        const start = text.indexOf('{');
        const end = text.lastIndexOf('}');
        if (start === -1 || end === -1 || end <= start) {
            return null;
        }
        const jsonText = text.slice(start, end + 1);
        try {
            return JSON.parse(jsonText);
        } catch {
            return null;
        }
    }

    private toGeminiResult(text: string): GeminiResult {
        const parsed = this.extractJson(text);
        if (!parsed || typeof parsed !== 'object') {
            return {
                moodLabel: 'unknown',
                summary: 'Tidak dapat memproses deskripsi emosi saat ini.',
                recommendations: ['Coba ulangi sebentar lagi.'],
            };
        }

        return {
            moodLabel: String(parsed.moodLabel ?? 'unknown'),
            moodScore: typeof parsed.moodScore === 'number' ? parsed.moodScore : undefined,
            summary: parsed.summary ? String(parsed.summary) : undefined,
            recommendations: Array.isArray(parsed.recommendations)
                ? parsed.recommendations.map((item: unknown) => String(item))
                : undefined,
        };
    }

    async analyzeText(userId: string, text: string) {
        if (!text || text.trim().length < 8) {
            throw new BadRequestException('Text is too short');
        }

        const modelName = this.configService.get<string>('GEMINI_MODEL') ?? 'gemini-2.5-flash';
        const fallbackModel = 'gemini-1.5-flash';

        const prompt = [
            'Kamu adalah asisten analisis emosi untuk aplikasi wellbeing.',
            'Analisis teks berikut dan kembalikan HANYA JSON valid dengan kunci:',
            'moodLabel (label singkat), moodScore (0-1), summary (ringkas), recommendations (array tips singkat).',
            'Gunakan Bahasa Indonesia untuk semua nilai teks.',
            'Teks:',
            text,
        ].join('\n');

        let outputText = '';
        try {
            const model = this.ai.getGenerativeModel({ model: modelName });
            const response = await model.generateContent(prompt);
            outputText = response.response.text();
        } catch (error) {
            try {
                const fallback = this.ai.getGenerativeModel({ model: fallbackModel });
                const response = await fallback.generateContent(prompt);
                outputText = response.response.text();
            } catch {
                throw new ServiceUnavailableException('Gemini is busy. Please try again later.');
            }
        }
        const result = this.toGeminiResult(outputText);

        const entry = await this.prisma.emotionEntry.create({
            data: {
                userId,
                text,
                moodLabel: result.moodLabel,
                moodScore: result.moodScore,
                summary: result.summary,
                recommendations: result.recommendations ? JSON.stringify(result.recommendations) : null,
                rawResponse: this.extractJson(outputText) ?? { rawText: outputText },
            },
        });

        return {
            entryId: entry.id,
            moodLabel: entry.moodLabel,
            moodScore: entry.moodScore,
            summary: entry.summary,
            recommendations: result.recommendations ?? [],
        };
    }

    async getHomeDashboard(userId: string) {
        const user = await this.prisma.user.findUnique({
            where: { id: userId },
            select: { name: true, username: true, photoUrl: true },
        });

        const todayStart = new Date();
        todayStart.setHours(0, 0, 0, 0);
        const todayEnd = new Date(todayStart);
        todayEnd.setDate(todayEnd.getDate() + 1);

        const todayEntry = await this.prisma.emotionEntry.findFirst({
            where: {
                userId,
                createdAt: { gte: todayStart, lt: todayEnd },
            },
            orderBy: { createdAt: 'desc' },
        });

        const history = await this.prisma.emotionEntry.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
            take: 7,
        });

        return {
            user,
            today: todayEntry
                ? {
                    id: todayEntry.id,
                    text: todayEntry.text,
                    moodLabel: todayEntry.moodLabel,
                    moodScore: todayEntry.moodScore,
                    summary: todayEntry.summary,
                    createdAt: todayEntry.createdAt,
                }
                : null,
            history: history.map((entry) => ({
                id: entry.id,
                text: entry.text,
                moodLabel: entry.moodLabel,
                moodScore: entry.moodScore,
                summary: entry.summary,
                createdAt: entry.createdAt,
            })),
        };
    }
}