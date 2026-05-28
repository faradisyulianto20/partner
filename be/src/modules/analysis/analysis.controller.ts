import { BadRequestException, Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { AnalysisService } from './analysis.service';
import { CreateAnalysisDto } from './dto/create-analysis.dto';
import { SupabaseJwtGuard } from '../auth/supabase-jwt.guard';
import { CurrentUser } from '../auth/current-user.decorator';
import type { CurrentUserPayload } from '../auth/current-user.decorator';

@Controller('analysis')
export class AnalysisController {
    constructor(private readonly analysisService: AnalysisService) { }

    @Post('text')
    @UseGuards(SupabaseJwtGuard)
    analyze(@CurrentUser() user: CurrentUserPayload, @Body() body: CreateAnalysisDto) {
        return this.analysisService.analyzeText(body.text, user?.sub ?? body.userId);
    }

    /**
     * POST /analysis/face
     * Menerima gambar dalam format base64 via JSON body.
     * Body: { imageBase64: string, mimeType?: string, userId?: string }
     *
     * Pendekatan JSON dipilih karena multipart/form-data tidak reliabel
     * di lingkungan Vercel serverless.
     */
    @Post('face')
    @UseGuards(SupabaseJwtGuard)
    analyzeFace(
        @Body() body: { imageBase64?: string; mimeType?: string; userId?: string },
        @CurrentUser() user?: CurrentUserPayload,
    ) {
        if (!body?.imageBase64?.trim()) {
            throw new BadRequestException('imageBase64 is required');
        }

        return this.analysisService.analyzeFace(
            body.imageBase64,
            body.mimeType ?? 'image/jpeg',
            user?.sub ?? body?.userId,
        );
    }

    @Get('dashboard')
    @UseGuards(SupabaseJwtGuard)
    getDashboard(@CurrentUser() user: CurrentUserPayload, @Query('userId') userId?: string) {
        return this.analysisService.getDashboard(user?.sub ?? userId);
    }
}
