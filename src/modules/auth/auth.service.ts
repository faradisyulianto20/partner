import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { OAuth2Client } from 'google-auth-library';
import { PrismaService } from '../../prisma/prisma.service';
import { AuthRole } from './dto/google-auth.dto';

@Injectable()
export class AuthService {
    private googleClient: OAuth2Client;

    constructor(
        private readonly prisma: PrismaService,
        private readonly configService: ConfigService,
        private readonly jwtService: JwtService,
    ) {
        const clientId = this.configService.get<string>('GOOGLE_CLIENT_ID');
        this.googleClient = new OAuth2Client(clientId);
    }

    async loginWithGoogle(idToken: string, role: AuthRole) {
        const ticket = await this.googleClient.verifyIdToken({
            idToken,
            audience: this.configService.get<string>('GOOGLE_CLIENT_ID'),
        });
        const payload = ticket.getPayload();

        if (!payload || !payload.sub || !payload.email) {
            throw new UnauthorizedException('Invalid Google token');
        }

        const existing = await this.prisma.user.findUnique({
            where: { googleId: payload.sub },
        });

        const user = existing
            ? await this.prisma.user.update({
                where: { id: existing.id },
                data: {
                    email: payload.email,
                    name: payload.name ?? existing.name,
                    photoUrl: existing.photoUrl ?? payload.picture ?? null,
                },
            })
            : await this.prisma.user.create({
                data: {
                    role,
                    googleId: payload.sub,
                    email: payload.email,
                    name: payload.name ?? null,
                    photoUrl: payload.picture ?? null,
                },
            });

        const accessToken = await this.jwtService.signAsync({
            sub: user.id,
            role: user.role,
            email: user.email,
        });

        return {
            accessToken,
            user,
            isProfileComplete: Boolean(user.username && user.birthDate && user.gender && user.photoUrl),
        };
    }
}
