import {
    ConnectedSocket,
    MessageBody,
    SubscribeMessage,
    WebSocketGateway,
} from '@nestjs/websockets';
import { Socket } from 'socket.io';
import { HumanPartnerService } from './human-partner.service';

@WebSocketGateway({ namespace: '/partner/chat', cors: true })
export class HumanPartnerChatGateway {
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

    @SubscribeMessage('message')
    async handleMessage(
        @ConnectedSocket() socket: Socket,
        @MessageBody() body: { matchId: string; userId: string; content: string },
    ) {
        await this.humanPartnerService.validateParticipant(body.matchId, body.userId);
        const message = await this.humanPartnerService.saveMessage(
            body.matchId,
            body.userId,
            body.content,
        );

        socket.to(body.matchId).emit('message', message);
        socket.emit('message', message);
    }
}
