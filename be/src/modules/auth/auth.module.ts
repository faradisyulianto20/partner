import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { AuthController } from './auth.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtStrategy } from './jwt.strategy';

@Module({
    imports: [
        PrismaModule, 
        ConfigModule,
        PassportModule,
        JwtModule.registerAsync({
            imports: [ConfigModule],
            inject: [ConfigService],
            useFactory: async (configService: ConfigService) => ({
                secret: configService.get<string>('JWT_SECRET') || 'default-secret-key-for-hackathon-2026',
                signOptions: { expiresIn: '7d' }, // Custom JWT expires in 7 days
            }),
        }),
    ],
    controllers: [AuthController],
    providers: [JwtStrategy],
    exports: [JwtModule],
})
export class AuthModule {}
