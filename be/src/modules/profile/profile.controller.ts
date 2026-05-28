import { Body, Controller, Get, Post } from '@nestjs/common';
import { ProfileService } from './profile.service';
import { ClientProfileDto } from './dto/client-profile.dto';
import { PsychologistProfileDto } from './dto/psychologist-profile.dto';
import { PsychologistDocumentsDto } from './dto/psychologist-documents.dto';

import { CurrentUser } from '../auth/current-user.decorator';
import type { CurrentUserPayload } from '../auth/current-user.decorator';

@Controller('profile')
export class ProfileController {
    constructor(private readonly profileService: ProfileService) { }

    @Get('me')
    getMe(@CurrentUser() user: CurrentUserPayload) {
        return this.profileService.getCurrentProfile(user?.sub ?? '');
    }

    @Get('me/client')
    getClientProfile(@CurrentUser() user: CurrentUserPayload) {
        return this.profileService.getClientProfile(user?.sub ?? '');
    }

    @Get('me/psychologist')
    getPsychologistProfile(@CurrentUser() user: CurrentUserPayload) {
        return this.profileService.getPsychologistProfile(user?.sub ?? '');
    }

    @Post('client')
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
    async upsertPsychologistProfile(
        @CurrentUser() user: CurrentUserPayload,
        @Body() dto: PsychologistProfileDto,
    ) {
        dto.userId = user?.sub ?? dto.userId;
        dto.email ??= user?.email;

        return this.profileService.upsertPsychologistProfile(dto);
    }

    @Post('psychologist/documents')
    async submitPsychologistDocuments(
        @CurrentUser() user: CurrentUserPayload,
        @Body() dto: PsychologistDocumentsDto,
    ) {
        dto.userId = user?.sub ?? dto.userId;

        const result = await this.profileService.submitPsychologistDocuments(dto);
        return result ?? { message: 'Psychologist profile not found' };
    }
}
