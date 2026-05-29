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

    @Post('face')
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
    getDashboard(@CurrentUser() user: CurrentUserPayload) {
        if (!user?.sub) {
            throw new UnauthorizedException('Token tidak valid');
        }

        return this.analysisService.getDashboard(user.sub);
    }
}
