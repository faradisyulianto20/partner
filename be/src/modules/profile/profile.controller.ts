import {
    Body,
    Controller,
    Get,
    Post,
    Put,
    UploadedFile,
    UploadedFiles,
    UseGuards,
    UseInterceptors,
} from '@nestjs/common';
import { FileFieldsInterceptor, FileInterceptor } from '@nestjs/platform-express';
import { ProfileService } from './profile.service';
import { ClientProfileDto } from './dto/client-profile.dto';
import { PsychologistProfileDto } from './dto/psychologist-profile.dto';
import { PsychologistDocumentsDto } from './dto/psychologist-documents.dto';
import { UpdatePsychologistSchedulesDto } from './dto/update-psychologist-schedules.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

import { CurrentUser } from '../auth/dto/current-user.decorator';
import type { CurrentUserPayload } from '../auth/dto/current-user.decorator';

@Controller('profile')
@UseGuards(JwtAuthGuard)
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

    @Put('me/psychologist/schedules')
    replacePsychologistSchedules(
        @CurrentUser() user: CurrentUserPayload,
        @Body() dto: UpdatePsychologistSchedulesDto,
    ) {
        dto.userId = user?.sub ?? dto.userId;
        return this.profileService.replacePsychologistSchedules(dto.userId ?? '', dto.schedules);
    }

    @Post('client')
    @UseInterceptors(FileInterceptor('photo'))
    async upsertClientProfile(
        @CurrentUser() user: CurrentUserPayload,
        @Body() dto: ClientProfileDto,
        @UploadedFile() photoFile?: Express.Multer.File,
    ) {
        dto.userId = user?.sub ?? dto.userId;
        dto.email ??= user?.email ?? undefined;
        dto.displayName ??= user?.displayName ?? undefined; // ← pakai displayName dari token langsung

        return this.profileService.upsertClientProfile(dto, photoFile);
    }

    @Post('psychologist')
    @UseInterceptors(FileInterceptor('photo'))
    async upsertPsychologistProfile(
        @CurrentUser() user: CurrentUserPayload,
        @Body() dto: PsychologistProfileDto,
        @UploadedFile() photoFile?: Express.Multer.File,
    ) {
        dto.userId = user?.sub ?? dto.userId;
        dto.email ??= user?.email ?? undefined;

        return this.profileService.upsertPsychologistProfile(dto, photoFile);
    }

    @Post('psychologist/documents')
    @UseInterceptors(
        FileFieldsInterceptor([
            { name: 'ktp', maxCount: 1 },
            { name: 'faceWithKtp', maxCount: 1 },
            { name: 'strLicense', maxCount: 1 },
        ]),
    )
    async submitPsychologistDocuments(
        @CurrentUser() user: CurrentUserPayload,
        @Body() dto: PsychologistDocumentsDto,
        @UploadedFiles()
        files?: {
            ktp?: Express.Multer.File[];
            faceWithKtp?: Express.Multer.File[];
            strLicense?: Express.Multer.File[];
        },
    ) {
        dto.userId = user?.sub ?? dto.userId;

        const result = await this.profileService.submitPsychologistDocuments(dto, {
            ktp: files?.ktp?.[0],
            faceWithKtp: files?.faceWithKtp?.[0],
            strLicense: files?.strLicense?.[0],
        });
        return result ?? { message: 'Psychologist profile not found' };
    }
}
