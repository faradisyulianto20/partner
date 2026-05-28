import { BadRequestException, Body, Controller, Get, Post, Query, UploadedFile, UseGuards, UseInterceptors } from '@nestjs/common';
import { AnalysisService } from './analysis.service';
import { CreateAnalysisDto } from './dto/create-analysis.dto';
import { FileInterceptor } from '@nestjs/platform-express';
import 'multer';
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

    @Post('face')
    @UseGuards(SupabaseJwtGuard)
    @UseInterceptors(FileInterceptor('image'))
    analyzeFace(
        @UploadedFile() file?: Express.Multer.File,
        @Body() body?: { mimeType?: string; userId?: string },
        @CurrentUser() user?: CurrentUserPayload,
    ) {
        if (!file?.buffer) {
            throw new BadRequestException('image file is required');
        }

        const mimeType = body?.mimeType ?? file.mimetype;
        const base64 = file.buffer.toString('base64');

        return this.analysisService.analyzeFace(base64, mimeType, user?.sub ?? body?.userId);
    }

    @Get('dashboard')
    @UseGuards(SupabaseJwtGuard)
    getDashboard(@CurrentUser() user: CurrentUserPayload, @Query('userId') userId?: string) {
        return this.analysisService.getDashboard(user?.sub ?? userId);
    }
}
