import { Controller, Post, Body, UseGuards, Request } from '@nestjs/common';
import { SupabaseJwtGuard } from './supabase-jwt.guard';
import { PrismaService } from '../prisma/prisma.service';
import { JwtService } from '@nestjs/jwt';

@Controller('auth')
export class AuthController {
    constructor(
        private readonly prisma: PrismaService,
        private readonly jwtService: JwtService,
    ) {}

    /**
     * POST /auth/login
     * Endpoint utama untuk mendapatkan custom accessToken.
     * Cukup kirim request dengan header Authorization: Bearer <supabase_access_token>
     * Backend akan memvalidasi Supabase JWT dan mengembalikan custom JWT.
     */
    @UseGuards(SupabaseJwtGuard)
    @Post('login')
    async login(@Request() req) {
        const supabaseUser = req.user;
        
        // Upsert user ke database
        const user = await this.prisma.user.upsert({
            where: { id: supabaseUser.sub },
            update: {
                email: supabaseUser.email,
            },
            create: {
                id: supabaseUser.sub,
                email: supabaseUser.email,
                role: 'CLIENT',
            },
        });

        // Generate custom JWT
        const payload = { sub: user.id, email: user.email, role: user.role };
        const accessToken = this.jwtService.sign(payload);

        return {
            message: 'Login successful',
            accessToken: accessToken,
            user: {
                id: user.id,
                email: user.email,
                role: user.role,
            },
        };
    }

    @UseGuards(SupabaseJwtGuard)
    @Post('provider-token')
    async saveProviderToken(
        @Request() req,
        @Body() body: { providerToken: string; providerRefreshToken?: string },
    ) {
        const userId = req.user.sub;
        const email = req.user.email;
        
        const user = await this.prisma.user.upsert({
            where: { id: userId },
            update: {
                providerToken: body.providerToken,
                providerRefreshToken: body.providerRefreshToken,
            },
            create: {
                id: userId,
                email: email,
                role: 'CLIENT',
                providerToken: body.providerToken,
                providerRefreshToken: body.providerRefreshToken,
            },
        });
        
        // Buat custom JWT dari backend
        const payload = { sub: user.id, email: user.email, role: user.role };
        const accessToken = this.jwtService.sign(payload);
        
        return { 
            message: 'Provider token saved successfully',
            accessToken: accessToken,
        };
    }
}
