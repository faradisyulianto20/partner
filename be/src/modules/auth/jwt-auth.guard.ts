import { CanActivate, ExecutionContext, Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AuthService } from './auth.service';

@Injectable()
export class JwtAuthGuard implements CanActivate {
    constructor(
        private readonly authService: AuthService,
        private readonly configService: ConfigService,
    ) { }

    canActivate(context: ExecutionContext): boolean {
        const request = context.switchToHttp().getRequest();
        const header = request.headers?.authorization as string | undefined;
        const token = header?.startsWith('Bearer ') ? header.slice(7) : undefined;

        if (!token) {
            throw new UnauthorizedException('Authorization Bearer token missing');
        }

        const payload = this.authService.verifyToken(token);
        if (!payload) {
            throw new UnauthorizedException('Invalid or expired token');
        }
        request.user = payload;
        return true;
    }
}
