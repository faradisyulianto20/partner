import { Body, Controller, Get, Post, Put, UseGuards } from '@nestjs/common';
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
  constructor(private readonly profileService: ProfileService) {}

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
    return this.profileService.replacePsychologistSchedules(
      dto.userId ?? '',
      dto.schedules,
    );
  }

  @Post('client')
  async upsertClientProfile(
    @CurrentUser() user: CurrentUserPayload,
    @Body() dto: ClientProfileDto,
  ) {
    dto.userId = user?.sub ?? dto.userId;
    dto.email ??= user?.email ?? undefined;
    dto.displayName ??= user?.displayName ?? undefined; // ← pakai displayName dari token langsung

    return this.profileService.upsertClientProfile(dto);
  }

  @Post('psychologist')
  async upsertPsychologistProfile(
    @CurrentUser() user: CurrentUserPayload,
    @Body() dto: PsychologistProfileDto,
  ) {
    dto.userId = user?.sub ?? dto.userId;
    dto.email ??= user?.email ?? undefined;

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
