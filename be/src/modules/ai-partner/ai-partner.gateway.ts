import {
    ConnectedSocket,
    MessageBody,
    OnGatewayDisconnect,
    SubscribeMessage,
    WebSocketGateway,
} from '@nestjs/websockets';
import { Socket } from 'socket.io';
import { AiPartnerService } from './ai-partner.service';

type VoiceSession = {
    sessionId: string;
    userId: string;
    sampleRate: number;
    recognizeStream: NodeJS.WritableStream;
    transcriptParts: string[];
    endPromise: Promise<void>;
    resolveEnd: () => void;
};

@WebSocketGateway({ namespace: '/ai/voice', cors: true })
export class AiPartnerGateway implements OnGatewayDisconnect {
    private readonly sessions = new Map<string, VoiceSession>();

    constructor(private readonly aiPartnerService: AiPartnerService) { }

    @SubscribeMessage('start')
    async handleStart(
        @ConnectedSocket() socket: Socket,
        @MessageBody()
        body?: { sessionId?: string; userId?: string; sampleRate?: number },
    ) {
        const sampleRate = body?.sampleRate ?? 16000;
        const userId = body?.userId?.trim() || 'demo-user';
        const sessionId = body?.sessionId ||
            (await this.aiPartnerService.createSession(userId)).id;

        const transcriptParts: string[] = [];
        let resolveEnd: () => void = () => { };
        const endPromise = new Promise<void>((resolve) => {
            resolveEnd = resolve;
        });

        const recognizeStream = this.aiPartnerService.createSpeechStream(
            sampleRate,
            (chunk) => {
                if (chunk.isFinal) {
                    transcriptParts.push(chunk.text);
                }
                socket.emit('transcript', chunk);
            },
            (error) => {
                socket.emit('error', { message: error.message });
            },
            () => {
                resolveEnd();
            },
        );

        this.sessions.set(socket.id, {
            sessionId,
            userId,
            sampleRate,
            recognizeStream,
            transcriptParts,
            endPromise,
            resolveEnd,
        });

        socket.emit('session', { sessionId, userId, sampleRate });
    }

    @SubscribeMessage('audio')
    handleAudio(
        @ConnectedSocket() socket: Socket,
        @MessageBody() payload: Buffer | ArrayBuffer | { chunk?: string },
    ) {
        const session = this.sessions.get(socket.id);
        if (!session) {
            socket.emit('error', { message: 'voice session not started' });
            return;
        }

        const buffer = this.extractBuffer(payload);
        if (!buffer?.length) {
            return;
        }

        session.recognizeStream.write(buffer);
    }

    @SubscribeMessage('stop')
    async handleStop(@ConnectedSocket() socket: Socket) {
        const session = this.sessions.get(socket.id);
        if (!session) {
            socket.emit('error', { message: 'voice session not started' });
            return;
        }

        session.recognizeStream.end();
        await session.endPromise;

        const transcript = session.transcriptParts.join(' ').trim();
        if (!transcript) {
            socket.emit('error', { message: 'no speech detected' });
            this.sessions.delete(socket.id);
            return;
        }

        let assistantText = '';
        try {
            const assistantMessage = await this.aiPartnerService.sendMessage(
                session.sessionId,
                session.userId,
                transcript,
            );
            assistantText = assistantMessage?.content || '';
        } catch (error: any) {
            socket.emit('error', { message: error?.message || error });
            this.sessions.delete(socket.id);
            return;
        }

        socket.emit('assistant_text', {
            sessionId: session.sessionId,
            text: assistantText,
        });

        if (assistantText) {
            const audioBuffer = await this.aiPartnerService.synthesizeSpeech(assistantText);
            this.emitAudioChunks(socket, audioBuffer);
        }

        this.sessions.delete(socket.id);
    }

    handleDisconnect(socket: Socket) {
        const session = this.sessions.get(socket.id);
        if (session) {
            session.recognizeStream.end();
            this.sessions.delete(socket.id);
        }
    }

    private extractBuffer(payload: Buffer | ArrayBuffer | { chunk?: string }) {
        if (Buffer.isBuffer(payload)) {
            return payload;
        }

        if (payload instanceof ArrayBuffer) {
            return Buffer.from(payload);
        }

        if (payload?.chunk) {
            return Buffer.from(payload.chunk, 'base64');
        }

        return null;
    }

    private emitAudioChunks(socket: Socket, audioBuffer: Buffer) {
        const chunkSize = 16000;
        for (let offset = 0; offset < audioBuffer.length; offset += chunkSize) {
            const slice = audioBuffer.subarray(offset, offset + chunkSize);
            socket.emit('assistant_audio', {
                chunk: slice.toString('base64'),
                mimeType: 'audio/mpeg',
                isLast: offset + chunkSize >= audioBuffer.length,
            });
        }
    }
}
