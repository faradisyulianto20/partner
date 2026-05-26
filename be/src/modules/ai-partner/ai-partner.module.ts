import { Module } from '@nestjs/common';
import { AiPartnerController } from './ai-partner.controller';
import { AiPartnerGateway } from './ai-partner.gateway';
import { AiPartnerService } from './ai-partner.service';

@Module({
    controllers: [AiPartnerController],
    providers: [AiPartnerService, AiPartnerGateway],
})
export class AiPartnerModule { }
