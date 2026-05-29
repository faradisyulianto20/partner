export class RespondBookingDto {
    userId!: string;
    action!: 'ACCEPT' | 'REJECT';
}
