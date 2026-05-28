import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { HumanPartnerService } from './human-partner.service';
import { JoinQueueDto } from './dto/join-queue.dto';
import { LeaveQueueDto } from './dto/leave-queue.dto';
import { MatchActionDto } from './dto/match-action.dto';
import { SupabaseJwtGuard } from '../auth/supabase-jwt.guard';
import { CurrentUser } from '../auth/current-user.decorator';
import type { CurrentUserPayload } from '../auth/current-user.decorator';

@Controller('partner')
export class HumanPartnerController {
    constructor(private readonly humanPartnerService: HumanPartnerService) { }

    @Post('queue/join')
    @UseGuards(SupabaseJwtGuard)
    joinQueue(@CurrentUser() user: CurrentUserPayload, @Body() body: JoinQueueDto) {
        return this.humanPartnerService.joinQueue(user?.sub ?? body.userId);
    }

    @Post('queue/leave')
    @UseGuards(SupabaseJwtGuard)
    leaveQueue(@CurrentUser() user: CurrentUserPayload, @Body() body: LeaveQueueDto) {
        return this.humanPartnerService.leaveQueue(user?.sub ?? body.userId);
    }

    @Get('match/:id')
    @UseGuards(SupabaseJwtGuard)
    getMatch(@Param('id') id: string) {
        return this.humanPartnerService.getMatch(id);
    }

    @Post('match/:id/favorite')
    @UseGuards(SupabaseJwtGuard)
    addFavorite(
        @CurrentUser() user: CurrentUserPayload,
        @Param('id') id: string,
        @Body() body: MatchActionDto,
    ) {
        return this.humanPartnerService.addFavorite(user?.sub ?? body.userId, body.targetUserId);
    }

    @Post('match/:id/block')
    @UseGuards(SupabaseJwtGuard)
    blockPartner(
        @CurrentUser() user: CurrentUserPayload,
        @Param('id') id: string,
        @Body() body: MatchActionDto,
    ) {
        return this.humanPartnerService.blockUser(user?.sub ?? body.userId, body.targetUserId, body.reason);
    }

    @Post('match/:id/report')
    @UseGuards(SupabaseJwtGuard)
    reportPartner(
        @CurrentUser() user: CurrentUserPayload,
        @Param('id') id: string,
        @Body() body: MatchActionDto,
    ) {
        return this.humanPartnerService.reportUser(
            user?.sub ?? body.userId,
            body.targetUserId,
            body.reason || 'unspecified',
        );
    }

    @Get('favorites/:userId')
    @UseGuards(SupabaseJwtGuard)
    listFavorites(@CurrentUser() user: CurrentUserPayload, @Param('userId') userId: string) {
        return this.humanPartnerService.listFavorites(user?.sub ?? userId);
    }
}
