import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { JWTPayload } from 'jose';

export type CurrentUserPayload = JWTPayload & {
    email?: string;
    user_metadata?: {
        full_name?: string;
        name?: string;
    };
};

export const CurrentUser = createParamDecorator(
    (_data: unknown, context: ExecutionContext) => {
        const request = context.switchToHttp().getRequest();
        return request.user as CurrentUserPayload | undefined;
    },
);
