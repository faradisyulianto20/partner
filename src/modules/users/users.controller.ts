import { Body, Controller, Get, Post, Put, UseGuards } from '@nestjs/common';
import { CurrentUser } from '../auth/current-user.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt.guard';
import type { JwtPayload } from '../../common/guards/jwt.guard';
import { CreateUploadUrlDto, UpdateProfileDto } from './dto/update-profile.dto';
import { UsersService } from './users.service';

@Controller('me')
@UseGuards(JwtAuthGuard)
export class UsersController {
    constructor(private readonly usersService: UsersService) { }

    @Get()
    async getMe(@CurrentUser() user: JwtPayload) {
        return this.usersService.getMe(user.sub);
    }

    @Put('profile')
    async updateProfile(@CurrentUser() user: JwtPayload, @Body() body: UpdateProfileDto) {
        return this.usersService.updateProfile(user.sub, body);
    }

    @Post('photo-upload-url')
    async createPhotoUploadUrl(
        @CurrentUser() user: JwtPayload,
        @Body() body: CreateUploadUrlDto,
    ) {
        return this.usersService.createPhotoUploadUrl(user.sub, body);
    }
}
