import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { CurrentUser } from '../auth/current-user.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt.guard';
import type { JwtPayload } from '../../common/guards/jwt.guard';
import { AnalyzeTextDto } from './dto/analyze-text.dto';
import { AnalyzeTextDevDto } from './dto/analyze-text-dev.dto';
import { InsightsService } from './insights.service';

@Controller('emotions')
@UseGuards(JwtAuthGuard)
export class EmotionsController {
    constructor(private readonly insightsService: InsightsService) { }

    @Post('analyze-text')
    async analyzeText(@CurrentUser() user: JwtPayload, @Body() body: AnalyzeTextDto) {
        return this.insightsService.analyzeText(user.sub, body.text);
    }
}

@Controller('emotions')
export class DevEmotionsController {
    constructor(private readonly insightsService: InsightsService) { }

    @Post('analyze-text-dev')
    async analyzeTextDev(@Body() body: AnalyzeTextDevDto) {
        return this.insightsService.analyzeText(body.userId, body.text);
    }
}
