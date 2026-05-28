import { Body, Controller, Post } from '@nestjs/common';
import { ProfileService } from './profile.service';
import { ClientProfileDto } from './dto/client-profile.dto';
import { PsychologistProfileDto } from './dto/psychologist-profile.dto';
import { PsychologistDocumentsDto } from './dto/psychologist-documents.dto';

@Controller('profile')
export class ProfileController {
    constructor(private readonly profileService: ProfileService) { }

    @Post('client')
    async upsertClientProfile(@Body() dto: ClientProfileDto) {
        return this.profileService.upsertClientProfile(dto);
    }

    @Post('psychologist')
    async upsertPsychologistProfile(@Body() dto: PsychologistProfileDto) {
        return this.profileService.upsertPsychologistProfile(dto);
    }

    @Post('psychologist/documents')
    async submitPsychologistDocuments(@Body() dto: PsychologistDocumentsDto) {
        const result = await this.profileService.submitPsychologistDocuments(dto);
        return result ?? { message: 'Psychologist profile not found' };
    }
}
