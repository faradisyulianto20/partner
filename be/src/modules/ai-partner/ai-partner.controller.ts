import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { AiPartnerService } from './ai-partner.service';
import { CreateMessageDto } from './dto/create-message.dto';
import { CreateSessionDto } from './dto/create-session.dto';

@Controller('ai')
export class AiPartnerController {
    constructor(private readonly aiPartnerService: AiPartnerService) { }

    @Post('chat/session')
    createSession(@Body() body: CreateSessionDto) {
        return this.aiPartnerService.createSession(body.userId, body.title);
    }

    @Get('chat/session/:id')
    getSession(@Param('id') id: string) {
        return this.aiPartnerService.getSession(id);
    }

    @Post('chat/session/:id/message')
    sendMessage(
        @Param('id') id: string,
        @Body() body: CreateMessageDto,
    ) {
        return this.aiPartnerService.sendMessage(id, body.userId, body.content);
    }
}
