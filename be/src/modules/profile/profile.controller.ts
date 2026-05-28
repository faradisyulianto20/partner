import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { ProfileService } from './profile.service';
import { ClientProfileDto } from './dto/client-profile.dto';
import { PsychologistProfileDto } from './dto/psychologist-profile.dto';
import { PsychologistDocumentsDto } from './dto/psychologist-documents.dto';
import { SupabaseJwtGuard } from '../auth/supabase-jwt.guard';
import { CurrentUser } from '../auth/current-user.decorator';
import type { CurrentUserPayload } from '../auth/current-user.decorator';

@Controller('profile')
export class ProfileController {
    constructor(private readonly profileService: ProfileService) { }

    @Post('client')
    @UseGuards(SupabaseJwtGuard)
    async upsertClientProfile(
        @CurrentUser() user: CurrentUserPayload,
        @Body() dto: ClientProfileDto,
    ) {

        dto.userId = user?.sub ?? dto.userId;
        dto.email ??= user?.email;
        dto.displayName ??= user?.user_metadata?.full_name ?? user?.user_metadata?.name;

        return this.profileService.upsertClientProfile(dto);
    }

    @Post('psychologist')
    @UseGuards(SupabaseJwtGuard)
    async upsertPsychologistProfile(
        @CurrentUser() user: CurrentUserPayload,
        @Body() dto: PsychologistProfileDto,
    ) {
        dto.userId = user?.sub ?? dto.userId;
        dto.email ??= user?.email;

        return this.profileService.upsertPsychologistProfile(dto);
    }

    @Post('psychologist/documents')
    @UseGuards(SupabaseJwtGuard)
    async submitPsychologistDocuments(
        @CurrentUser() user: CurrentUserPayload,
        @Body() dto: PsychologistDocumentsDto,
    ) {
        dto.userId = user?.sub ?? dto.userId;

        const result = await this.profileService.submitPsychologistDocuments(dto);
        return result ?? { message: 'Psychologist profile not found' };
    }
}
