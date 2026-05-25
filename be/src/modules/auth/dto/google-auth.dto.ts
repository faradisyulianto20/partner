import { IsEnum, IsNotEmpty, IsString } from 'class-validator';

export enum AuthRole {
    USER = 'USER',
    PSYCHOLOGIST = 'PSYCHOLOGIST',
}

export class GoogleAuthDto {
    @IsString()
    @IsNotEmpty()
    idToken!: string;

    @IsEnum(AuthRole)
    role!: AuthRole;
}
