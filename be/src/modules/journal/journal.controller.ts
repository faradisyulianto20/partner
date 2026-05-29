import { Body, Controller, Delete, Get, Param, Post, Put, Query, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUser } from '../auth/dto/current-user.decorator';
import type { CurrentUserPayload } from '../auth/dto/current-user.decorator';
import { JournalService } from './journal.service';
import { CreateJournalDto } from './dto/create-journal.dto';
import { UpdateJournalDto } from './dto/update-journal.dto';

@Controller('journal')
@UseGuards(JwtAuthGuard)
export class JournalController {
    constructor(private readonly journalService: JournalService) { }

    @Post()
    create(@Body() dto: CreateJournalDto) {
        return this.journalService.createJournal(dto.userId ?? '', dto);
    }

    @Get()
    list(
        @Query('userId') userId?: string,
        @Query('limit') limit?: string,
        @Query('offset') offset?: string,
    ) {
        return this.journalService.listJournals(
            userId ?? '',
            limit ? Number(limit) : undefined,
            offset ? Number(offset) : undefined,
        );
    }

    @Get(':id')
    detail(@Query('userId') userId: string, @Param('id') id: string) {
        return this.journalService.getJournal(userId ?? '', id);
    }

    @Put(':id')
    update(
        @Param('id') id: string,
        @Body() dto: UpdateJournalDto,
    ) {
        return this.journalService.updateJournal(dto.userId ?? '', id, dto);
    }

    @Delete(':id')
    remove(@Query('userId') userId: string, @Param('id') id: string) {
        return this.journalService.deleteJournal(userId ?? '', id);
    }
}
