import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { AiPartnerService } from './ai-partner.service';
import { CreateMessageDto } from './dto/create-message.dto';
import { CreateSessionDto } from './dto/create-session.dto';
import { SupabaseJwtGuard } from '../auth/supabase-jwt.guard';
import { CurrentUser } from '../auth/current-user.decorator';
import type { CurrentUserPayload } from '../auth/current-user.decorator';

@Controller('ai')
export class AiPartnerController {
    constructor(private readonly aiPartnerService: AiPartnerService) { }

    @Post('chat/session')
    @UseGuards(SupabaseJwtGuard)
    createSession(@CurrentUser() user: CurrentUserPayload, @Body() body: CreateSessionDto) {
        return this.aiPartnerService.createSession(user?.sub ?? body.userId, body.title);
    }

    @Get('chat/session/:id')
    @UseGuards(SupabaseJwtGuard)
    getSession(@Param('id') id: string) {
        return this.aiPartnerService.getSession(id);
    }

    @Post('chat/session/:id/message')
    @UseGuards(SupabaseJwtGuard)
    sendMessage(
        @CurrentUser() user: CurrentUserPayload,
        @Param('id') id: string,
        @Body() body: CreateMessageDto,
    ) {
        return this.aiPartnerService.sendMessage(id, user?.sub ?? body.userId, body.content);
    }
}
