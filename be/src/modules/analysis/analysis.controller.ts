import { BadRequestException, Body, Controller, Get, Post, Query, UnauthorizedException, UploadedFile, UseGuards, UseInterceptors } from '@nestjs/common';
import { AnalysisService } from './analysis.service';
import { CreateAnalysisDto } from './dto/create-analysis.dto';
import { FileInterceptor } from '@nestjs/platform-express';
import 'multer';
import { CurrentUser } from '../auth/dto/current-user.decorator';
import type { CurrentUserPayload } from '../auth/dto/current-user.decorator';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('analysis')
export class AnalysisController {
    constructor(private readonly analysisService: AnalysisService) { }

    @Post('text')
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
    @UseInterceptors(FileInterceptor('image'))
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
    getDashboard(@CurrentUser() user: CurrentUserPayload) {
        if (!user?.sub) {
            throw new UnauthorizedException('Token tidak valid');
        }

        return this.analysisService.getDashboard(user.sub);
    }
}
