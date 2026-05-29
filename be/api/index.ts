import { NestFactory } from '@nestjs/core';
import { ExpressAdapter } from '@nestjs/platform-express';
import express from 'express';
import { AppModule } from '../src/app.module';

let cachedServer: ReturnType<typeof express> | null = null;

async function bootstrapServer() {
    if (cachedServer) {
        return cachedServer;
    }

    const expressApp = express();
    const app = await NestFactory.create(AppModule, new ExpressAdapter(expressApp));

    app.enableCors();
    await app.init();

    cachedServer = expressApp;
    return cachedServer;
}

export default async function handler(req: unknown, res: unknown) {
    const server = await bootstrapServer();
    return server(req as never, res as never);
}
