import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AnalysisModule } from './modules/analysis/analysis.module';
import { AiPartnerModule } from './modules/ai-partner/ai-partner.module';
import { PrismaModule } from './modules/prisma/prisma.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AnalysisModule,
    AiPartnerModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }
