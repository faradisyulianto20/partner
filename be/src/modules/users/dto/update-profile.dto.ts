import { IsDateString, IsEnum, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export enum GenderDto {
    MALE = 'MALE',
    FEMALE = 'FEMALE',
}

export class UpdateProfileDto {
    @IsString()
    @IsNotEmpty()
    username!: string;

    @IsDateString()
    birthDate!: string;

    @IsEnum(GenderDto)
    gender!: GenderDto;

    @IsString()
    @IsNotEmpty()
    photoUrl!: string;
}

export class CreateUploadUrlDto {
    @IsString()
    @IsNotEmpty()
    fileName!: string;

    @IsString()
    @IsNotEmpty()
    contentType!: string;
}
