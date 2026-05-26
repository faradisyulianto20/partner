import { Module } from '@nestjs/common';
import { HumanPartnerController } from './human-partner.controller';
import { HumanPartnerService } from './human-partner.service';
import { HumanPartnerChatGateway } from './human-partner.chat.gateway';
import { HumanPartnerCallGateway } from './human-partner.call.gateway';

@Module({
    controllers: [HumanPartnerController],
    providers: [HumanPartnerService, HumanPartnerChatGateway, HumanPartnerCallGateway],
})
export class HumanPartnerModule { }
