import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { HumanPartnerService } from './human-partner.service';
import { JoinQueueDto } from './dto/join-queue.dto';
import { LeaveQueueDto } from './dto/leave-queue.dto';
import { MatchActionDto } from './dto/match-action.dto';

import { CurrentUser } from '../auth/dto/current-user.decorator';
import type { CurrentUserPayload } from '../auth/dto/current-user.decorator';

@Controller('partner')
export class HumanPartnerController {
  constructor(private readonly humanPartnerService: HumanPartnerService) {}

  @Post('queue/join')
  joinQueue(
    @CurrentUser() user: CurrentUserPayload,
    @Body() body: JoinQueueDto,
  ) {
    return this.humanPartnerService.joinQueue(user?.sub ?? body.userId);
  }

  @Post('queue/leave')
  leaveQueue(
    @CurrentUser() user: CurrentUserPayload,
    @Body() body: LeaveQueueDto,
  ) {
    return this.humanPartnerService.leaveQueue(user?.sub ?? body.userId);
  }

  @Get('match/:id')
  getMatch(@Param('id') id: string) {
    return this.humanPartnerService.getMatch(id);
  }

  @Post('match/:id/favorite')
  addFavorite(@Param('id') id: string, @Body() body: MatchActionDto) {
    return this.humanPartnerService.addFavorite(body.userId, body.targetUserId);
  }

  @Post('match/:id/block')
  blockPartner(@Param('id') id: string, @Body() body: MatchActionDto) {
    return this.humanPartnerService.blockUser(
      body.userId,
      body.targetUserId,
      body.reason,
    );
  }

  @Post('match/:id/report')
  reportPartner(@Param('id') id: string, @Body() body: MatchActionDto) {
    return this.humanPartnerService.reportUser(
      body.userId,
      body.targetUserId,
      body.reason || 'unspecified',
    );
  }

  @Get('favorites/:userId')
  listFavorites(
    @CurrentUser() user: CurrentUserPayload,
    @Param('userId') userId: string,
  ) {
    return this.humanPartnerService.listFavorites(user?.sub ?? userId);
  }
}
