import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AuthModule } from '../auth/auth.module';
import { DashboardController } from './dashboard.controller';
import { DevEmotionsController, EmotionsController } from './emotions.controller';
import { InsightsService } from './insights.service';

@Module({
    imports: [ConfigModule, AuthModule],
    controllers: [EmotionsController, DevEmotionsController, DashboardController],
    providers: [InsightsService],
})
export class InsightsModule { }
