import {
  ConnectedSocket,
  MessageBody,
  SubscribeMessage,
  WebSocketGateway,
} from '@nestjs/websockets';
import { Socket } from 'socket.io';
import { HumanPartnerService } from './human-partner.service';
import { PrismaService } from '../prisma/prisma.service';

@WebSocketGateway({ namespace: '/partner/chat', cors: true })
export class HumanPartnerChatGateway {
  constructor(
    private readonly humanPartnerService: HumanPartnerService,
    private readonly prismaService: PrismaService,
  ) {}

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

  @SubscribeMessage('message')
  async handleMessage(
    @ConnectedSocket() socket: Socket,
    @MessageBody()
    body: {
      matchId: string;
      userId: string;
      content: string;
      roomType?: 'HUMAN' | 'PSYCHOLOGIST';
      role?: 'USER' | 'PSYCHOLOGIST';
    },
  ) {
    const roomType = body.roomType ?? 'HUMAN';
    await this.validateRoom(roomType, body.matchId, body.userId, body.role);

    const message =
      roomType === 'HUMAN'
        ? await this.humanPartnerService.saveMessage(
            body.matchId,
            body.userId,
            body.content,
          )
        : await this.prismaService.psychologistMessage.create({
            data: {
              bookingId: body.matchId,
              senderRole:
                body.role === 'PSYCHOLOGIST' ? 'PSYCHOLOGIST' : 'USER',
              senderId: body.userId,
              content: body.content,
            },
          });

    const roomId = this.buildRoomId(roomType, body.matchId);
    socket.to(roomId).emit('message', message);
    socket.emit('message', message);
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
