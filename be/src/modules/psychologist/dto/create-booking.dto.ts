export class CreateBookingDto {
    userId!: string;
    psychologistId!: string;
    fullName!: string;
    method!: 'CHAT' | 'VOICE' | 'VIDEO';
    notes?: string;
    scheduledAt?: string;
    selectedSlots?: string[];
}
