import {
    CanActivate,
    ExecutionContext,
    Injectable,
    UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createRemoteJWKSet, jwtVerify, JWTPayload } from 'jose';

type SupabaseUser = JWTPayload & {
    email?: string;
    user_metadata?: {
        full_name?: string;
        name?: string;
    };
};

@Injectable()
export class SupabaseJwtGuard implements CanActivate {
    private jwks: ReturnType<typeof createRemoteJWKSet> | null = null;

    constructor(private readonly configService: ConfigService) { }

    async canActivate(context: ExecutionContext): Promise<boolean> {
        const request = context.switchToHttp().getRequest();
        const authHeader = request.headers?.authorization ?? '';
        const [scheme, token] = authHeader.split(' ');

        if (scheme !== 'Bearer' || !token) {
            throw new UnauthorizedException('Missing bearer token');
        }

        const { jwksUrl, issuer, audience } = this.getJwtConfig();

        if (!this.jwks) {
            this.jwks = createRemoteJWKSet(jwksUrl);
        }

        try {
            const { payload } = await jwtVerify(token, this.jwks, {
                issuer: issuer ?? undefined,
                audience: audience ?? undefined,
            });

            request.user = payload as SupabaseUser;
            return true;
        } catch (error) {
            throw new UnauthorizedException('Invalid bearer token');
        }
    }

    private getJwtConfig() {
        const supabaseUrl =
            this.configService.get<string>('SUPABASE_URL') ??
            this.configService.get<string>('SUPABASE_PROJECT_URL');

        if (!supabaseUrl) {
            throw new UnauthorizedException('SUPABASE_URL is not configured');
        }

        const baseUrl = supabaseUrl.replace(/\/$/, '');
        const jwksUrl = new URL(`${baseUrl}/auth/v1/.well-known/jwks.json`);
        const issuer =
            this.configService.get<string>('SUPABASE_JWT_ISSUER') ??
            `${baseUrl}/auth/v1`;
        const audience = this.configService.get<string>('SUPABASE_JWT_AUD');

        return { jwksUrl, issuer, audience };
    }
}
