import { Body, Controller, Delete, Get, Param, Post, Put, Query, UseGuards } from '@nestjs/common';
import { SupabaseJwtGuard } from '../auth/supabase-jwt.guard';
import { CurrentUser } from '../auth/current-user.decorator';
import type { CurrentUserPayload } from '../auth/current-user.decorator';
import { JournalService } from './journal.service';
import { CreateJournalDto } from './dto/create-journal.dto';
import { UpdateJournalDto } from './dto/update-journal.dto';

@Controller('journal')
@UseGuards(SupabaseJwtGuard)
export class JournalController {
    constructor(private readonly journalService: JournalService) { }

    @Post()
    create(@CurrentUser() user: CurrentUserPayload, @Body() dto: CreateJournalDto) {
        return this.journalService.createJournal(user?.sub ?? '', dto);
    }

    @Get()
    list(
        @CurrentUser() user: CurrentUserPayload,
        @Query('limit') limit?: string,
        @Query('offset') offset?: string,
    ) {
        return this.journalService.listJournals(
            user?.sub ?? '',
            limit ? Number(limit) : undefined,
            offset ? Number(offset) : undefined,
        );
    }

    @Get(':id')
    detail(@CurrentUser() user: CurrentUserPayload, @Param('id') id: string) {
        return this.journalService.getJournal(user?.sub ?? '', id);
    }

    @Put(':id')
    update(
        @CurrentUser() user: CurrentUserPayload,
        @Param('id') id: string,
        @Body() dto: UpdateJournalDto,
    ) {
        return this.journalService.updateJournal(user?.sub ?? '', id, dto);
    }

    @Delete(':id')
    remove(@CurrentUser() user: CurrentUserPayload, @Param('id') id: string) {
        return this.journalService.deleteJournal(user?.sub ?? '', id);
    }
}
