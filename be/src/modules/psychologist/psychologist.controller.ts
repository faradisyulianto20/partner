import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { PsychologistService } from './psychologist.service';
import { SearchPsychologistDto } from './dto/search-psychologist.dto';
import { CreateBookingDto } from './dto/create-booking.dto';
import { PayBookingDto } from './dto/pay-booking.dto';
import { CreateReviewDto } from './dto/create-review.dto';
import { RequestVerificationDto } from './dto/request-verification.dto';

import { CurrentUser } from '../auth/current-user.decorator';
import type { CurrentUserPayload } from '../auth/current-user.decorator';

@Controller('psychologist')
export class PsychologistController {
    constructor(private readonly psychologistService: PsychologistService) { }

    @Post('search')
    search(@CurrentUser() user: CurrentUserPayload, @Body() body: SearchPsychologistDto) {
        return this.psychologistService.search(user?.sub ?? body.userId, body.criteria, body.limit);
    }

    @Get(':id')
    getDetail(@Param('id') id: string) {
        return this.psychologistService.getDetail(id);
    }

    @Post('booking')
    createBooking(@CurrentUser() user: CurrentUserPayload, @Body() body: CreateBookingDto) {
        return this.psychologistService.createBooking(
            user?.sub ?? body.userId,
            body.psychologistId,
            body.fullName,
            body.method,
            body.price,
            body.notes,
            body.scheduledAt,
        );
    }

    @Post('booking/:id/pay')
    payBooking(@CurrentUser() user: CurrentUserPayload, @Param('id') id: string, @Body() body: PayBookingDto) {
        return this.psychologistService.payBooking(id, user?.sub ?? body.userId);
    }

    @Post('review')
    addReview(@CurrentUser() user: CurrentUserPayload, @Body() body: CreateReviewDto) {
        return this.psychologistService.addReview(
            user?.sub ?? body.userId,
            body.psychologistId,
            body.rating,
            body.comment,
        );
    }

    @Post('verification/request')
    requestVerification(@Body() body: RequestVerificationDto) {
        return this.psychologistService.requestEmailVerification(body.psychologistId);
    }

    @Get('verification/confirm/:token')
    confirmVerification(@Param('token') token: string) {
        return this.psychologistService.confirmEmailVerification(token);
    }
}
