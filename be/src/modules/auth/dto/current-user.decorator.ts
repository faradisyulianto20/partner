import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { UserRole } from '@prisma/client';

// Definisikan sendiri, tidak pakai JWTPayload dari jose
export type CurrentUserPayload = {
    sub: string;
    email?: string | null;
    displayName?: string | null;
    role?: UserRole;
    iat?: number;
    exp?: number;
};

export const CurrentUser = createParamDecorator(
    (_data: unknown, context: ExecutionContext) => {
        const request = context.switchToHttp().getRequest();
        return request.user as CurrentUserPayload | undefined;
    },
);