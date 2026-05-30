import { Body, Controller, Get, Param, Patch, Post, Put, Query, UseGuards } from '@nestjs/common';
import { PsychologistService } from './psychologist.service';
import { SearchPsychologistDto } from './dto/search-psychologist.dto';
import { CreateBookingDto } from './dto/create-booking.dto';
import { PayBookingDto } from './dto/pay-booking.dto';
import { CreateReviewDto } from './dto/create-review.dto';
import { RequestVerificationDto } from './dto/request-verification.dto';
import { UpdatePsychologistStatusDto } from './dto/update-psychologist-status.dto';
import { UpdatePsychologistSchedulesDto } from './dto/update-psychologist-schedules.dto';
import { RespondBookingDto } from './dto/respond-booking.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

import { CurrentUser } from '../auth/dto/current-user.decorator';
import type { CurrentUserPayload } from '../auth/dto/current-user.decorator';

@Controller('psychologist')
export class PsychologistController {
    constructor(private readonly psychologistService: PsychologistService) { }

    @Post('search')
    search(@CurrentUser() user: CurrentUserPayload, @Body() body: SearchPsychologistDto) {
        return this.psychologistService.search(user?.sub ?? body.userId, body.criteria, body.limit);
    }

    @UseGuards(JwtAuthGuard)
    @Get('me/dashboard')
    getDashboard(@CurrentUser() user: CurrentUserPayload, @Query('userId') userId?: string) {
        return this.psychologistService.getDashboard(user?.sub ?? userId ?? '');
    }

    @UseGuards(JwtAuthGuard)
    @Patch('me/status')
    updateStatus(
        @CurrentUser() user: CurrentUserPayload,
        @Body() body: UpdatePsychologistStatusDto,
    ) {
        return this.psychologistService.updateConsultationStatus(
            user?.sub ?? body.userId,
            body.isAcceptingSessions,
        );
    }

    @UseGuards(JwtAuthGuard)
    @Put('me/schedules')
    replaceSchedules(
        @CurrentUser() user: CurrentUserPayload,
        @Body() body: UpdatePsychologistSchedulesDto,
    ) {
        return this.psychologistService.replaceSchedules(user?.sub ?? body.userId, body.schedules);
    }

    @Post('booking/:id/respond')
    @UseGuards(JwtAuthGuard)
    respondBooking(
        @CurrentUser() user: CurrentUserPayload,
        @Param('id') id: string,
        @Body() body: RespondBookingDto,
    ) {
        return this.psychologistService.respondToBooking(id, user?.sub ?? body.userId, body.action);
    }

    @Patch('booking/:id/complete')
    @UseGuards(JwtAuthGuard)
    completeBooking(@CurrentUser() user: CurrentUserPayload, @Param('id') id: string) {
        return this.psychologistService.completeBooking(id, user?.sub ?? '');
    }

    @UseGuards(JwtAuthGuard)
    @Get('booking/me/upcoming')
    getMyUpcomingSessions(@CurrentUser() user: CurrentUserPayload) {
        return this.psychologistService.getClientUpcomingSessions(user?.sub ?? '');
    }

    @UseGuards(JwtAuthGuard)
    @Get('booking/me/history')
    getMySessionHistory(@CurrentUser() user: CurrentUserPayload) {
        return this.psychologistService.getClientSessionHistory(user?.sub ?? '');
    }

    @Get('booking/:id/detail')
    getBookingDetail(@Param('id') id: string) {
        return this.psychologistService.getBookingDetail(id);
    }

    @UseGuards(JwtAuthGuard)
    @Get('me/sessions')
    getDaySessions(@CurrentUser() user: CurrentUserPayload, @Query('date') date?: string) {
        return this.psychologistService.getDaySessions(user?.sub ?? '', date);
    }

    @UseGuards(JwtAuthGuard)
    @Get('me/clients')
    getClients(
        @CurrentUser() user: CurrentUserPayload,
        @Query('search') search?: string,
        @Query('status') status?: string,
    ) {
        return this.psychologistService.getClients(user?.sub ?? '', search, status);
    }

    @UseGuards(JwtAuthGuard)
    @Get('me/income')
    getIncomeHistory(@CurrentUser() user: CurrentUserPayload, @Query('limit') limit?: string) {
        return this.psychologistService.getIncomeHistory(user?.sub ?? '', Number(limit) || 50);
    }

    @UseGuards(JwtAuthGuard)
    @Get('me/reviews')
    getReviewSummary(
        @CurrentUser() user: CurrentUserPayload,
        @Query('limit') limit?: string,
        @Query('page') page?: string,
    ) {
        return this.psychologistService.getReviewSummary(user?.sub ?? '', Number(limit) || 20, Number(page) || 1);
    }

    @Get(':id/available-slots')
    getAvailableSlots(@Param('id') id: string, @Query('date') date?: string) {
        return this.psychologistService.getAvailableSlots(id, date);
    }

    @Get(':id')
    getDetail(@Param('id') id: string) {
        return this.psychologistService.getDetail(id);
    }

    @Post('booking')
    @UseGuards(JwtAuthGuard)
    createBooking(@CurrentUser() user: CurrentUserPayload, @Body() body: CreateBookingDto) {
        return this.psychologistService.createBooking(
            user?.sub ?? body.userId,
            body.psychologistId,
            body.fullName,
            body.method,
            body.notes,
            body.scheduledAt,
            body.selectedSlots,
        );
    }

    @Post('booking/:id/pay')
    @UseGuards(JwtAuthGuard)
    payBooking(@CurrentUser() user: CurrentUserPayload, @Param('id') id: string, @Body() body: PayBookingDto) {
        return this.psychologistService.payBooking(id, user?.sub ?? body.userId);
    }

    @Post('review')
    @UseGuards(JwtAuthGuard)
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
