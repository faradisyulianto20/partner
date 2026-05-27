import { BadRequestException, Body, Controller, Get, Post, Query, UploadedFile, UseInterceptors } from '@nestjs/common';
import { AnalysisService } from './analysis.service';
import { CreateAnalysisDto } from './dto/create-analysis.dto';
import { FileInterceptor } from '@nestjs/platform-express';
import { memoryStorage } from 'multer';

@Controller('analysis')
export class AnalysisController {
    constructor(private readonly analysisService: AnalysisService) { }

    @Post('text')
    analyze(@Body() body: CreateAnalysisDto) {
        return this.analysisService.analyzeText(body.text, body.userId);
    }

    @Post('face')
    @UseInterceptors(
        FileInterceptor('image', {
            storage: memoryStorage(),
        }),
    )
    analyzeFace(
        @UploadedFile() file?: Express.Multer.File,
        @Body() body?: { mimeType?: string; userId?: string },
    ) {
        if (!file?.buffer) {
            throw new BadRequestException('image file is required');
        }

        const mimeType = body?.mimeType ?? file.mimetype;
        const base64 = file.buffer.toString('base64');

        return this.analysisService.analyzeFace(base64, mimeType, body?.userId);
    }

    @Get('dashboard')
    getDashboard(@Query('userId') userId?: string) {
        return this.analysisService.getDashboard(userId);
    }
}
