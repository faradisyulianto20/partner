export class CreateReviewDto {
    userId!: string;
    psychologistId!: string;
    rating!: number;
    comment?: string;
}
