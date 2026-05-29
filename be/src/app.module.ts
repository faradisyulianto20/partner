import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AnalysisModule } from './modules/analysis/analysis.module';
import { AiPartnerModule } from './modules/ai-partner/ai-partner.module';
import { AuthModule } from './modules/auth/auth.module';
import { HumanPartnerModule } from './modules/human-partner/human-partner.module';
import { JournalModule } from './modules/journal/journal.module';
import { PsychologistModule } from './modules/psychologist/psychologist.module';
import { ProfileModule } from './modules/profile/profile.module';
import { PrismaModule } from './modules/prisma/prisma.module';
import { AuthModule } from './modules/auth/auth.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AuthModule,
    AnalysisModule,
    AiPartnerModule,
    HumanPartnerModule,
    JournalModule,
    PsychologistModule,
    ProfileModule,
    AuthModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }
