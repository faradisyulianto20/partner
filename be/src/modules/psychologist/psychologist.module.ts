import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { PsychologistController } from './psychologist.controller';
import { PsychologistService } from './psychologist.service';

@Module({
    imports: [AuthModule],
    controllers: [PsychologistController],
    providers: [PsychologistService],
})
export class PsychologistModule { }
