import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { JwtAuthGuard } from '../../common/guards/jwt.guard';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';

@Module({
    imports: [
        ConfigModule,
        JwtModule.registerAsync({
            imports: [ConfigModule],
            inject: [ConfigService],
            useFactory: (configService: ConfigService) => {
                const expiresInRaw = configService.get<string>('JWT_EXPIRES_IN');
                const expiresInSeconds = expiresInRaw ? Number(expiresInRaw) : 7 * 24 * 60 * 60;
                return {
                    secret: configService.get<string>('JWT_SECRET'),
                    signOptions: {
                        expiresIn: Number.isFinite(expiresInSeconds) ? expiresInSeconds : 7 * 24 * 60 * 60,
                    },
                };
            },
        }),
    ],
    controllers: [AuthController],
    providers: [AuthService, JwtAuthGuard],
    exports: [JwtModule, JwtAuthGuard],
})
export class AuthModule { }
