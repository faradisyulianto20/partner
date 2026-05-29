import { BadRequestException, Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GoogleGenAI } from '@google/genai';
import { PrismaService } from '../prisma/prisma.service';

export type AnalysisResult = {
    emotionLabel: string;
    summary: string;
    recommendations: {
        title: string;
        narrative: string;
        items: Array<{
            key: 'AI_PARTNER' | 'HUMAN_PARTNER' | 'PROFESSIONAL_PARTNER';
            title: string;
            description: string;
        }>;
    };
    confidence?: number;
};

@Injectable()
export class AnalysisService {
    private readonly ai: GoogleGenAI;

    constructor(
        private readonly configService: ConfigService,
        private readonly prismaService: PrismaService,
    ) {
        const apiKey = process.env.GEMINI_API_KEY || this.configService.get<string>('GEMINI_API_KEY');
        if (!apiKey) {
            throw new Error('GEMINI_API_KEY is missing');
        }
        this.ai = new GoogleGenAI({ apiKey });
    }

    async analyzeText(inputText: string, userId?: string) {
        if (!inputText?.trim()) {
            throw new BadRequestException('text is required');
        }

        const prompt = [
            'Kamu adalah asisten kesehatan mental yang sangat empatik, hangat, dan suportif.',
            'Analisis teks berikut dan kembalikan JSON murni tanpa markdown.',
            'Format JSON wajib: {"emotionLabel": string, "summary": string, "recommendations": string, "confidence": number}',
            'Gunakan Bahasa Indonesia yang lembut dan menenangkan.',
            '',
            'ATURAN KHUSUS UNTUK "recommendations":',
            '- JANGAN menulis dalam bentuk poin-poin (bullet points), list, atau kalimat perintah yang kaku.',
            '- Tuliskan rekomendasi dalam SATU PARAGRAF UTUH yang mengalir secara alami dan suportif.',
            '- Hubungkan setiap saran tindakan dengan efek positifnya secara lembut. Contoh gaya bahasa: "Luangkan waktu 1–2 menit untuk menarik napas perlahan dan menenangkan pikiranmu sejenak, musik yang lembut dapat membantu tubuh dan pikiran terasa lebih rileks..."',
            '',
            'Teks:',
            inputText,
        ].join('\n');

        let rawText = '';
        try {
            const response = await this.ai.models.generateContent({
                model: 'gemini-2.5-flash',
                contents: prompt,
                config: {
                    responseMimeType: 'application/json',
                }
            });
            rawText = response.text || '';
        } catch (error: any) {
            console.error('Gemini Error:', error);
            throw new InternalServerErrorException(`failed to call Gemini API: ${error?.message || error}`);
        }

        const { parsed, result } = this.parseGeminiResult(rawText);

        const saved = await this.prismaService.analysis.create({
            data: {
                userId: (() => {
                    const id = userId?.trim();
                    if (!id) throw new BadRequestException('userId is required');
                    return id;
                })(),
                inputText,
                emotionLabel: result.emotionLabel,
                summary: result.summary,
                recommendations: result.recommendations,
                energyCategory: this.deriveEnergyCategory(result.emotionLabel, result.summary),
                rawJson: parsed,
            },
        });

        return {
            id: saved.id,
            createdAt: saved.createdAt,
            ...result,
        };
    }

    async analyzeFace(imageBase64: string, mimeType?: string, userId?: string) {
        if (!imageBase64?.trim()) {
            throw new BadRequestException('imageBase64 is required');
        }

        const imagePayload = this.normalizeBase64Image(imageBase64, mimeType);
        if (!imagePayload.data) {
            throw new BadRequestException('invalid imageBase64');
        }

        const prompt = [
            'Kamu adalah asisten kesehatan mental yang sangat empatik, hangat, dan suportif.',
            'Analisis ekspresi wajah dari gambar berikut dan kembalikan JSON murni tanpa markdown.',
            'Format JSON wajib: {"emotionLabel": string, "summary": string, "recommendations": string, "confidence": number}',
            'Gunakan Bahasa Indonesia yang lembut dan menenangkan.',
            '',
            'ATURAN KHUSUS UNTUK "recommendations":',
            '- JANGAN menulis dalam bentuk poin-poin (bullet points), list, atau kalimat perintah yang kaku.',
            '- Tuliskan rekomendasi dalam SATU PARAGRAF UTUH yang mengalir secara alami dan suportif.',
            '- Hubungkan setiap saran tindakan dengan efek positifnya secara lembut.',
        ].join('\n');

        let rawText = '';
        try {
            const response = await this.ai.models.generateContent({
                model: 'gemini-2.5-flash',
                contents: [
                    {
                        role: 'user',
                        parts: [
                            { text: prompt },
                            {
                                inlineData: {
                                    mimeType: imagePayload.mimeType,
                                    data: imagePayload.data,
                                },
                            },
                        ],
                    },
                ],
                config: {
                    responseMimeType: 'application/json',
                },
            });
            rawText = response.text || '';
        } catch (error: any) {
            console.error('Gemini Error:', error);
            throw new InternalServerErrorException(`failed to call Gemini API: ${error?.message || error}`);
        }

        const { parsed, result } = this.parseGeminiResult(rawText);

        const saved = await this.prismaService.analysis.create({
            data: {
                userId: (() => {
                    const id = userId?.trim();
                    if (!id) throw new BadRequestException('userId is required');
                    return id;
                })(),
                inputText: '[face-image]',
                emotionLabel: result.emotionLabel,
                summary: result.summary,
                recommendations: result.recommendations,
                energyCategory: this.deriveEnergyCategory(result.emotionLabel, result.summary),
                rawJson: parsed,
            },
        });

        return {
            id: saved.id,
            createdAt: saved.createdAt,
            ...result,
        };
    }

    async getDashboard(userId?: string) {
        const trimmedUserId = userId?.trim();

        // Jika tidak ada userId, jangan query ke DB, langsung return dashboard kosong
        if (!trimmedUserId) {
            return {
                last7Days: Array.from({ length: 7 }, (_, index) => {
                    const date = new Date();
                    date.setDate(date.getDate() - 6 + index);
                    return {
                        date: this.toDateKey(date),
                        dayLabel: this.getDayLabel(date),
                        emotionLabel: null,
                    };
                }),
                today: null,
            };
        }

        const now = new Date();
        const startDate = new Date(now);
        startDate.setHours(0, 0, 0, 0);
        startDate.setDate(startDate.getDate() - 6);

        const analyses = await this.prismaService.analysis.findMany({
            where: {
                createdAt: {
                    gte: startDate,
                },
                userId: trimmedUserId, // 🛡️ SEKARANG AMAN: Wajib mencocokkan ID user tersebut
            },
            orderBy: {
                createdAt: 'desc',
            },
        });

        // ... sisa kode ke bawah tetap sama

        const byDay = new Map<string, typeof analyses[number]>();
        for (const item of analyses) {
            const dayKey = this.toDateKey(item.createdAt);
            if (!byDay.has(dayKey)) {
                byDay.set(dayKey, item);
            }
        }

        const last7Days = Array.from({ length: 7 }, (_, index) => {
            const date = new Date(startDate);
            date.setDate(startDate.getDate() + index);
            const dayKey = this.toDateKey(date);
            const analysis = byDay.get(dayKey);

            return {
                date: dayKey,
                dayLabel: this.getDayLabel(date),
                emotionLabel: analysis?.emotionLabel ?? null,
            };
        });

        const todayKey = this.toDateKey(now);
        const todayAnalysis = byDay.get(todayKey) ?? null;

        return {
            last7Days,
            today: todayAnalysis
                ? {
                    id: todayAnalysis.id,
                    createdAt: todayAnalysis.createdAt,
                    emotionLabel: todayAnalysis.emotionLabel,
                    summary: todayAnalysis.summary,
                    recommendations: this.normalizeRecommendation(todayAnalysis.recommendations),
                }
                : null,
        };
    }

    private parseGeminiResult(rawText: string) {
        const parsed = this.safeParseJson(rawText);
        if (!parsed) {
            throw new InternalServerErrorException('invalid response format from Gemini');
        }

        const recommendationsValue =
            parsed.recommendations ?? parsed.recommendation ?? parsed.rekomendasi;
        const recommendationsText = this.extractRecommendationText(recommendationsValue);
        const safeRecommendationsText = recommendationsText ||
            'Luangkan waktu sebentar untuk menarik napas perlahan dan memberi diri ruang beristirahat.';
        const supportRecommendations = this.buildSupportRecommendations(safeRecommendationsText);

        const result: AnalysisResult = {
            emotionLabel: String(parsed.emotionLabel ?? '').trim(),
            summary: String(parsed.summary ?? '').trim(),
            recommendations: supportRecommendations,
            confidence: typeof parsed.confidence === 'number' ? parsed.confidence : undefined,
        };

        if (!result.emotionLabel || !result.summary) {
            throw new InternalServerErrorException('incomplete response from Gemini');
        }

        return { parsed, result };
    }

    private normalizeRecommendation(value: unknown) {
        if (value && typeof value === 'object') {
            const maybe = value as {
                title?: unknown;
                narrative?: unknown;
                items?: unknown;
            };

            if (Array.isArray(maybe.items)) {
                return {
                    title: typeof maybe.title === 'string' ? maybe.title : 'Rekomendasi Dukungan Untukmu',
                    narrative:
                        typeof maybe.narrative === 'string'
                            ? maybe.narrative
                            : 'Kamu bisa mencoba dukungan bertahap sesuai kebutuhanmu.',
                    items: maybe.items,
                };
            }
        }

        const narrative = this.extractRecommendationText(value);
        if (!narrative) {
            return null;
        }

        return this.buildSupportRecommendations(narrative);
    }

    private extractRecommendationText(value: unknown) {
        if (value && typeof value === 'object' && !Array.isArray(value)) {
            const maybe = value as { narrative?: unknown; text?: unknown };
            if (typeof maybe.narrative === 'string' && maybe.narrative.trim()) {
                return maybe.narrative.trim();
            }
            if (typeof maybe.text === 'string' && maybe.text.trim()) {
                return maybe.text.trim();
            }
        }

        if (Array.isArray(value)) {
            return value.map((item: unknown) => String(item)).join(' ').trim();
        }

        if (typeof value === 'string') {
            return value.trim();
        }

        return '';
    }

    private buildSupportRecommendations(narrative: string) {
        return {
            title: 'Rekomendasi Dukungan Untukmu',
            narrative,
            items: [
                {
                    key: 'AI_PARTNER' as const,
                    title: 'AI Partner',
                    description:
                        'AI Partner dapat membantu menemanimu berbicara, menenangkan pikiran, dan memberikan refleksi emosional secara perlahan.',
                },
                {
                    key: 'HUMAN_PARTNER' as const,
                    title: 'Human Partner',
                    description:
                        'Jika kamu ingin merasa lebih dipahami secara emosional, kamu juga bisa mencoba berbicara dengan Human Partner secara anonim.',
                },
                {
                    key: 'PROFESSIONAL_PARTNER' as const,
                    title: 'Professional Partner',
                    description:
                        'Apabila emosi mulai terasa berat atau berlangsung cukup lama, berbicara dengan psikolog dapat membantu memahami kondisimu dengan lebih baik.',
                },
            ],
        };
    }

    private toDateKey(date: Date) {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    }

    private getDayLabel(date: Date) {
        const labels = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
        return labels[date.getDay()];
    }

    private deriveEnergyCategory(emotionLabel: string, summary: string) {
        const text = `${emotionLabel} ${summary}`.toLowerCase();
        const positiveKeywords = [
            'bahagia',
            'senang',
            'lega',
            'tenang',
            'damai',
            'positif',
            'semangat',
        ];
        const negativeKeywords = [
            'sedih',
            'cemas',
            'khawatir',
            'takut',
            'marah',
            'lelah',
            'stres',
            'tertekan',
            'overthinking',
            'gelisah',
        ];

        if (negativeKeywords.some((word) => text.includes(word))) {
            return 'NEGATIVE';
        }
        if (positiveKeywords.some((word) => text.includes(word))) {
            return 'POSITIVE';
        }
        return 'NEUTRAL';
    }

    private normalizeBase64Image(imageBase64: string, mimeType?: string) {
        const trimmed = imageBase64.trim();
        const match = trimmed.match(/^data:(.+);base64,(.*)$/);
        if (match) {
            return { mimeType: match[1], data: match[2] };
        }

        return { mimeType: mimeType ?? 'image/jpeg', data: trimmed };
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
}
