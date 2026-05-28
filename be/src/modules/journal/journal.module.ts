import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from '../prisma/prisma.module';
import { JournalController } from './journal.controller';
import { JournalService } from './journal.service';

@Module({
    imports: [ConfigModule, PrismaModule],
    controllers: [JournalController],
    providers: [JournalService],
})
export class JournalModule { }
