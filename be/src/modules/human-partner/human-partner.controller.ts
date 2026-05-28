import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { HumanPartnerService } from './human-partner.service';
import { JoinQueueDto } from './dto/join-queue.dto';
import { LeaveQueueDto } from './dto/leave-queue.dto';
import { MatchActionDto } from './dto/match-action.dto';

@Controller('partner')
export class HumanPartnerController {
    constructor(private readonly humanPartnerService: HumanPartnerService) { }

    @Post('queue/join')
    joinQueue(@Body() body: JoinQueueDto) {
        return this.humanPartnerService.joinQueue(body.userId);
    }

    @Post('queue/leave')
    leaveQueue(@Body() body: LeaveQueueDto) {
        return this.humanPartnerService.leaveQueue(body.userId);
    }

    @Get('match/:id')
    getMatch(@Param('id') id: string) {
        return this.humanPartnerService.getMatch(id);
    }

    @Post('match/:id/favorite')
    addFavorite(
        @Param('id') id: string,
        @Body() body: MatchActionDto,
    ) {
        return this.humanPartnerService.addFavorite(body.userId, body.targetUserId);
    }

    @Post('match/:id/block')
    blockPartner(
        @Param('id') id: string,
        @Body() body: MatchActionDto,
    ) {
        return this.humanPartnerService.blockUser(body.userId, body.targetUserId, body.reason);
    }

    @Post('match/:id/report')
    reportPartner(
        @Param('id') id: string,
        @Body() body: MatchActionDto,
    ) {
        return this.humanPartnerService.reportUser(
            body.userId,
            body.targetUserId,
            body.reason || 'unspecified',
        );
    }

    @Get('favorites/:userId')
    listFavorites(@Param('userId') userId: string) {
        return this.humanPartnerService.listFavorites(userId);
    }
}
