import {
    ConnectedSocket,
    MessageBody,
    SubscribeMessage,
    WebSocketGateway,
} from '@nestjs/websockets';
import { Socket } from 'socket.io';
import { HumanPartnerService } from './human-partner.service';
import { PrismaService } from '../prisma/prisma.service';

@WebSocketGateway({ namespace: '/partner/call', cors: true })
export class HumanPartnerCallGateway {
    constructor(
        private readonly humanPartnerService: HumanPartnerService,
        private readonly prismaService: PrismaService,
    ) { }

    @SubscribeMessage('join')
    async handleJoin(
        @ConnectedSocket() socket: Socket,
        @MessageBody()
        body: {
            matchId: string;
            userId: string;
            roomType?: 'HUMAN' | 'PSYCHOLOGIST';
            role?: 'USER' | 'PSYCHOLOGIST';
        },
    ) {
        const roomType = body.roomType ?? 'HUMAN';
        await this.validateRoom(roomType, body.matchId, body.userId, body.role);

        const roomId = this.buildRoomId(roomType, body.matchId);
        socket.join(roomId);
        socket.emit('joined', { matchId: body.matchId, roomType });
    }

    @SubscribeMessage('offer')
    async handleOffer(
        @ConnectedSocket() socket: Socket,
        @MessageBody()
        body: {
            matchId: string;
            userId: string;
            offer: unknown;
            roomType?: 'HUMAN' | 'PSYCHOLOGIST';
            role?: 'USER' | 'PSYCHOLOGIST';
        },
    ) {
        const roomType = body.roomType ?? 'HUMAN';
        await this.validateRoom(roomType, body.matchId, body.userId, body.role);
        socket
            .to(this.buildRoomId(roomType, body.matchId))
            .emit('offer', { userId: body.userId, offer: body.offer });
    }

    @SubscribeMessage('answer')
    async handleAnswer(
        @ConnectedSocket() socket: Socket,
        @MessageBody()
        body: {
            matchId: string;
            userId: string;
            answer: unknown;
            roomType?: 'HUMAN' | 'PSYCHOLOGIST';
            role?: 'USER' | 'PSYCHOLOGIST';
        },
    ) {
        const roomType = body.roomType ?? 'HUMAN';
        await this.validateRoom(roomType, body.matchId, body.userId, body.role);
        socket
            .to(this.buildRoomId(roomType, body.matchId))
            .emit('answer', { userId: body.userId, answer: body.answer });
    }

    @SubscribeMessage('ice')
    async handleIce(
        @ConnectedSocket() socket: Socket,
        @MessageBody()
        body: {
            matchId: string;
            userId: string;
            candidate: unknown;
            roomType?: 'HUMAN' | 'PSYCHOLOGIST';
            role?: 'USER' | 'PSYCHOLOGIST';
        },
    ) {
        const roomType = body.roomType ?? 'HUMAN';
        await this.validateRoom(roomType, body.matchId, body.userId, body.role);
        socket
            .to(this.buildRoomId(roomType, body.matchId))
            .emit('ice', { userId: body.userId, candidate: body.candidate });
    }

    private buildRoomId(roomType: 'HUMAN' | 'PSYCHOLOGIST', matchId: string) {
        return `${roomType}:${matchId}`;
    }

    private async validateRoom(
        roomType: 'HUMAN' | 'PSYCHOLOGIST',
        matchId: string,
        userId: string,
        role?: 'USER' | 'PSYCHOLOGIST',
    ) {
        if (roomType === 'HUMAN') {
            await this.humanPartnerService.validateParticipant(matchId, userId);
            return;
        }

        const booking = await this.prismaService.psychologistBooking.findUnique({
            where: { id: matchId },
        });
        if (!booking) {
            throw new Error('booking not found');
        }
        if (role === 'PSYCHOLOGIST') {
            if (booking.psychologistId !== userId) {
                throw new Error('psychologist not in booking');
            }
            return;
        }
        if (booking.userId !== userId) {
            throw new Error('user not in booking');
        }
    }
}
