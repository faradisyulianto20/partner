import {
    ConnectedSocket,
    MessageBody,
    SubscribeMessage,
    WebSocketGateway,
} from '@nestjs/websockets';
import { Socket } from 'socket.io';
import { HumanPartnerService } from './human-partner.service';

@WebSocketGateway({ namespace: '/partner/call', cors: true })
export class HumanPartnerCallGateway {
    constructor(private readonly humanPartnerService: HumanPartnerService) { }

    @SubscribeMessage('join')
    async handleJoin(
        @ConnectedSocket() socket: Socket,
        @MessageBody() body: { matchId: string; userId: string },
    ) {
        await this.humanPartnerService.validateParticipant(body.matchId, body.userId);
        socket.join(body.matchId);
        socket.emit('joined', { matchId: body.matchId });
    }

    @SubscribeMessage('offer')
    async handleOffer(
        @ConnectedSocket() socket: Socket,
        @MessageBody() body: { matchId: string; userId: string; offer: unknown },
    ) {
        await this.humanPartnerService.validateParticipant(body.matchId, body.userId);
        socket.to(body.matchId).emit('offer', { userId: body.userId, offer: body.offer });
    }

    @SubscribeMessage('answer')
    async handleAnswer(
        @ConnectedSocket() socket: Socket,
        @MessageBody() body: { matchId: string; userId: string; answer: unknown },
    ) {
        await this.humanPartnerService.validateParticipant(body.matchId, body.userId);
        socket.to(body.matchId).emit('answer', { userId: body.userId, answer: body.answer });
    }

    @SubscribeMessage('ice')
    async handleIce(
        @ConnectedSocket() socket: Socket,
        @MessageBody() body: { matchId: string; userId: string; candidate: unknown },
    ) {
        await this.humanPartnerService.validateParticipant(body.matchId, body.userId);
        socket.to(body.matchId).emit('ice', { userId: body.userId, candidate: body.candidate });
    }
}
