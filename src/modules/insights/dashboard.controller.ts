import { Controller, Get, UseGuards } from '@nestjs/common';
import { CurrentUser } from '../auth/current-user.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt.guard';
import type { JwtPayload } from '../../common/guards/jwt.guard';
import { InsightsService } from './insights.service';

@Controller('dashboard')
@UseGuards(JwtAuthGuard)
export class DashboardController {
    constructor(private readonly insightsService: InsightsService) { }

    @Get('home')
    async getHome(@CurrentUser() user: JwtPayload) {
        return this.insightsService.getHomeDashboard(user.sub);
    }
}
