import { BadRequestException, Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GoogleGenAI } from '@google/genai';
import { PrismaService } from '../prisma/prisma.service';
import { SpeechClient } from '@google-cloud/speech';
import { TextToSpeechClient } from '@google-cloud/text-to-speech';

export type TranscriptChunk = {
    text: string;
    isFinal: boolean;
};

@Injectable()
export class AiPartnerService {
    private readonly ai: GoogleGenAI;
    private readonly speechClient: SpeechClient;
    private readonly ttsClient: TextToSpeechClient;

    constructor(
        private readonly configService: ConfigService,
        private readonly prismaService: PrismaService,
    ) {
        const apiKey =
            process.env.GEMINI_API_KEY || this.configService.get<string>('GEMINI_API_KEY');
        if (!apiKey) {
            throw new Error('GEMINI_API_KEY is missing');
        }

        this.ai = new GoogleGenAI({ apiKey });
        this.speechClient = new SpeechClient();
        this.ttsClient = new TextToSpeechClient();
    }

    async createSession(userId?: string, title?: string) {
        const safeUserId = userId?.trim() || 'demo-user';
        return this.prismaService.chatSession.create({
            data: {
                userId: safeUserId,
                title: title?.trim() || null,
            },
        });
    }

    async getSession(sessionId: string) {
        return this.prismaService.chatSession.findUnique({
            where: { id: sessionId },
            include: {
                messages: { orderBy: { createdAt: 'asc' } },
            },
        });
    }

    async sendMessage(sessionId: string, userId: string | undefined, content: string) {
        if (!content?.trim()) {
            throw new BadRequestException('content is required');
        }

        const safeUserId = userId?.trim() || 'demo-user';

        await this.prismaService.chatMessage.create({
            data: {
                sessionId,
                role: 'user',
                content: content.trim(),
            },
        });

        const assistantText = await this.generateAssistantReply(sessionId, safeUserId);

        const assistantMessage = await this.prismaService.chatMessage.create({
            data: {
                sessionId,
                role: 'assistant',
                content: assistantText,
            },
        });

        return assistantMessage;
    }

    async generateAssistantReply(sessionId: string, userId: string) {
        const history = await this.getRecentMessages(sessionId, 12);
        const prompt = this.buildPrompt(userId, history);

        let rawText = '';
        try {
            const response = await this.ai.models.generateContent({
                model: 'gemini-2.5-flash',
                contents: prompt,
            });
            rawText = response.text || '';
        } catch (error: any) {
            throw new InternalServerErrorException(
                `failed to call Gemini API: ${error?.message || error}`,
            );
        }

        const text = rawText.trim();
        if (!text) {
            throw new InternalServerErrorException('empty response from Gemini');
        }

        return text;
    }

    createSpeechStream(
        sampleRate: number,
        onTranscript: (chunk: TranscriptChunk) => void,
        onError: (error: Error) => void,
        onEnd: () => void,
    ): NodeJS.WritableStream {
        const request = {
            config: {
                encoding: 'LINEAR16' as const,
                sampleRateHertz: sampleRate,
                languageCode: 'id-ID',
                enableAutomaticPunctuation: true,
            },
            interimResults: true,
        };

        const recognizeStream = this.speechClient
            .streamingRecognize(request)
            .on('error', onError)
            .on('data', (data) => {
                const result = data?.results?.[0];
                const alternative = result?.alternatives?.[0];
                if (!alternative?.transcript) {
                    return;
                }
                onTranscript({
                    text: alternative.transcript,
                    isFinal: Boolean(result.isFinal),
                });
            })
            .on('end', onEnd);

        return recognizeStream as NodeJS.WritableStream;
    }

    async synthesizeSpeech(text: string) {
        const [response] = await this.ttsClient.synthesizeSpeech({
            input: { text },
            voice: {
                languageCode: 'id-ID',
                ssmlGender: 'FEMALE',
            },
            audioConfig: {
                audioEncoding: 'MP3',
            },
        });

        const audioContent = response.audioContent;
        if (!audioContent) {
            throw new InternalServerErrorException('empty audio from TTS');
        }

        return Buffer.isBuffer(audioContent)
            ? audioContent
            : Buffer.from(audioContent as Uint8Array);
    }

    private async getRecentMessages(sessionId: string, limit: number) {
        const messages = await this.prismaService.chatMessage.findMany({
            where: { sessionId },
            orderBy: { createdAt: 'desc' },
            take: limit,
        });

        return messages.reverse();
    }

    private buildPrompt(userId: string, history: { role: string; content: string }[]) {
        const safeHistory = history
            .map((item) =>
                item.role === 'user'
                    ? `User: ${item.content}`
                    : `Assistant: ${item.content}`,
            )
            .join('\n');

        return [
            'Kamu adalah AI Partner yang empatik, hangat, dan suportif untuk curhat.',
            'Jaga keamanan: jangan memberikan diagnosis medis, jangan menghakimi, dan jika ada tanda bahaya, sarankan mencari bantuan profesional.',
            'Jawaban singkat, lembut, dan relevan dengan percakapan.',
            'Akhiri jawaban dengan bagian "Rekomendasi:" berisi tepat 3 poin (gunakan bullet "-").',
            '',
            `UserId: ${userId}`,
            'Percakapan:',
            safeHistory || 'Belum ada percakapan sebelumnya.',
            'Assistant:',
        ].join('\n');
    }
}
