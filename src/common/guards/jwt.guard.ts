import { CanActivate, ExecutionContext, Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Request } from 'express';

export interface JwtPayload {
    sub: string;
    role: string;
    email: string;
}

export interface AuthRequest extends Request {
    user?: JwtPayload;
}

@Injectable()
export class JwtAuthGuard implements CanActivate {
    constructor(
        private readonly jwtService: JwtService,
        private readonly configService: ConfigService,
    ) { }

    async canActivate(context: ExecutionContext) {
        const request = context.switchToHttp().getRequest<AuthRequest>();
        const header = request.headers.authorization;

        if (!header || !header.startsWith('Bearer ')) {
            throw new UnauthorizedException('Missing token');
        }

        const token = header.slice('Bearer '.length).trim();
        try {
            const payload = await this.jwtService.verifyAsync<JwtPayload>(token, {
                secret: this.configService.get<string>('JWT_SECRET'),
            });
            request.user = payload;
            return true;
        } catch {
            throw new UnauthorizedException('Invalid token');
        }
    }
}
