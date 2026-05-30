export class UpdatePsychologistSchedulesDto {
  userId?: string;
  schedules!: Array<{
    dayOfWeek: number;
    startTime: string;
    endTime: string;
    isAvailable?: boolean;
  }>;
}
