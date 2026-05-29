<<<<<<< HEAD
import { BadRequestException, Body, Controller, Get, Post, Query, UploadedFile, UseInterceptors } from '@nestjs/common';
import { AnalysisService } from './analysis.service';
import { CreateAnalysisDto } from './dto/create-analysis.dto';
import { FileInterceptor } from '@nestjs/platform-express';
import 'multer';
=======
import { BadRequestException, Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { AnalysisService } from './analysis.service';
import { CreateAnalysisDto } from './dto/create-analysis.dto';
import { SupabaseJwtGuard } from '../auth/supabase-jwt.guard';
import { CurrentUser } from '../auth/current-user.decorator';
import type { CurrentUserPayload } from '../auth/current-user.decorator';
>>>>>>> fix/user-page

@Controller('analysis')
export class AnalysisController {
    constructor(private readonly analysisService: AnalysisService) { }

    @Post('text')
    analyze(@Body() body: CreateAnalysisDto) {
        return this.analysisService.analyzeText(body.text, body.userId);
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
    getDashboard(@Query('userId') userId?: string) {
        return this.analysisService.getDashboard(userId);
    }
}
