import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ExpressAdapter } from '@nestjs/platform-express';
import express from 'express';

// Singleton app untuk Vercel serverless (menghindari cold start tiap request)
let app: any;
const server = express();

async function createNestApp() {
  if (!app) {
    app = await NestFactory.create(AppModule, new ExpressAdapter(server), {
      logger: ['error', 'warn'],
    });
    app.enableCors();
    await app.init();
  }
  return app;
}

// Handler Vercel serverless
export default async function handler(req: any, res: any) {
  await createNestApp();
  server(req, res);
}

// Local dev: jalankan server HTTP biasa
if (process.env.NODE_ENV !== 'production' || !process.env.VERCEL) {
  (async () => {
    const localApp = await NestFactory.create(AppModule);
    localApp.enableCors();
    await localApp.listen(process.env.PORT ?? 3000);
    console.log(`🚀 Backend berjalan di port ${process.env.PORT ?? 3000}`);
  })();
}

