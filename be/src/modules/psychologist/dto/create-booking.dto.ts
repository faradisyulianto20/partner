export class CreateBookingDto {
    userId!: string;
    psychologistId!: string;
    fullName!: string;
    method!: 'CHAT' | 'VOICE' | 'VIDEO';
    price!: number;
    notes?: string;
    scheduledAt!: string;
}
