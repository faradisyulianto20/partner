import { BadRequestException, Injectable, InternalServerErrorException, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Prisma, UserRole } from '@prisma/client';
import { randomBytes, randomUUID, scrypt as scryptCallback, timingSafeEqual } from 'node:crypto';
import { promisify } from 'node:util';
import jwt, { type SignOptions } from 'jsonwebtoken';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

const scrypt = promisify(scryptCallback);

type AuthTokenPayload = {
    sub: string;
    email?: string | null;
    role: UserRole;
    displayName?: string | null;
};

@Injectable()
export class AuthService {
    constructor(
        private readonly prisma: PrismaService,
        private readonly configService: ConfigService,
    ) { }

    async register(dto: RegisterDto) {
        const email = dto.email?.trim().toLowerCase();
        const password = dto.password?.trim();
        const role = dto.role ?? UserRole.CLIENT;

        if (!email) {
            throw new BadRequestException('email is required');
        }
        if (!password || password.length < 8) {
            throw new BadRequestException('password must be at least 8 characters');
        }
        if (!['CLIENT', 'PSYCHOLOGIST'].includes(role)) {
            throw new BadRequestException('role must be CLIENT or PSYCHOLOGIST');
        }

        const existing = await this.prisma.user.findFirst({ where: { email } });
        if (existing) {
            throw new BadRequestException('email already registered');
        }

        const passwordHash = await this.hashPassword(password);
        const user = await this.prisma.user.create({
            data: {
                id: randomUUID(),
                email,
                passwordHash,
                displayName: dto.displayName?.trim() || null,
                role,
            },
        });

        return this.createAuthResponse(user.id, user.email, user.displayName, user.role);
    }

    async login(dto: LoginDto) {
        const email = dto.email?.trim().toLowerCase();
        const password = dto.password?.trim();

        if (!email) {
            throw new BadRequestException('email is required');
        }
        if (!password) {
            throw new BadRequestException('password is required');
        }

        const user = await this.prisma.user.findFirst({ where: { email } });

        if (!user?.passwordHash) {
            throw new UnauthorizedException('invalid email or password');
        }

        const valid = await this.verifyPassword(password, user.passwordHash);
        if (!valid) {
            throw new UnauthorizedException('invalid email or password');
        }

        return this.createAuthResponse(user.id, user.email, user.displayName, user.role);
    }

    verifyToken(token: string) {
        const secret = this.getJwtSecret();
        try {
            return jwt.verify(token, secret) as AuthTokenPayload;
        } catch {
            throw new UnauthorizedException('invalid or expired token');
        }
    }

    private createAuthResponse(
        userId: string,
        email: string | null,
        displayName: string | null,
        role: UserRole,
    ) {
        const secret = this.getJwtSecret();
        const expiresIn = (this.configService.get<string>('JWT_EXPIRES_IN') || '7d') as SignOptions['expiresIn'];

        const payload: AuthTokenPayload = {
            sub: userId,
            email,
            role,
            displayName,
        };

        const accessToken = jwt.sign(payload, secret, { expiresIn });

        return {
            tokenType: 'Bearer',
            accessToken,
            expiresIn,
            user: {
                id: userId,
                email,
                displayName,
                role,
            },
        };
    }

    private async hashPassword(password: string) {
        const salt = randomBytes(16).toString('hex');
        const derivedKey = (await scrypt(password, salt, 64)) as Buffer;
        return `${salt}:${derivedKey.toString('hex')}`;
    }

    private async verifyPassword(password: string, storedHash: string) {
        const [salt, hash] = storedHash.split(':');
        if (!salt || !hash) {
            return false;
        }

        const derivedKey = (await scrypt(password, salt, 64)) as Buffer;
        const storedBuffer = Buffer.from(hash, 'hex');
        if (storedBuffer.length !== derivedKey.length) {
            return false;
        }

        return timingSafeEqual(storedBuffer, derivedKey);
    }

    private getJwtSecret() {
        const secret = this.configService.get<string>('JWT_SECRET') || process.env.JWT_SECRET;
        if (!secret) {
            // Jangan throw Error biasa — lempar yang NestJS mengerti
            throw new InternalServerErrorException('JWT_SECRET is not configured');
        }
        return secret;
    }
}
