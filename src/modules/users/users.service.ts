import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateUploadUrlDto, GenderDto, UpdateProfileDto } from './dto/update-profile.dto';

@Injectable()
export class UsersService {
    private supabase: SupabaseClient;

    constructor(
        private readonly prisma: PrismaService,
        private readonly configService: ConfigService,
    ) {
        const url = this.configService.get<string>('SUPABASE_URL');
        const key = this.configService.get<string>('SUPABASE_SERVICE_ROLE_KEY');
        this.supabase = createClient(url ?? '', key ?? '');
    }

    async getMe(userId: string) {
        const user = await this.prisma.user.findUnique({ where: { id: userId } });
        if (!user) {
            throw new NotFoundException('User not found');
        }
        return user;
    }

    async updateProfile(userId: string, dto: UpdateProfileDto) {
        return this.prisma.user.update({
            where: { id: userId },
            data: {
                username: dto.username,
                birthDate: new Date(dto.birthDate),
                gender: dto.gender === GenderDto.MALE ? 'MALE' : 'FEMALE',
                photoUrl: dto.photoUrl,
            },
        });
    }

    async createPhotoUploadUrl(userId: string, dto: CreateUploadUrlDto) {
        const bucket = this.configService.get<string>('SUPABASE_STORAGE_BUCKET');
        if (!bucket) {
            throw new BadRequestException('Supabase bucket is not configured');
        }
        const filePath = `${userId}/${Date.now()}-${dto.fileName}`;

        const { data, error } = await this.supabase.storage
            .from(bucket ?? '')
            .createSignedUploadUrl(filePath, { upsert: false });

        if (error) {
            throw new BadRequestException(error.message);
        }

        return {
            path: data.path,
            signedUrl: data.signedUrl,
            token: data.token,
        };
    }
}
