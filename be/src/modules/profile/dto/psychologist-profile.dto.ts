export class PsychologistProfileDto {
    userId!: string;
    email?: string;
    fullName!: string;
    phoneNumber!: string;
    gender!: 'MALE' | 'FEMALE';
    location!: string;
    clinicName!: string;
    specialization!: string;
    yearsExperience!: number;
    nik!: string;
    strNumber!: string;
    photoUrl?: string;
    education!: string[];
    clientsHandled?: number;
    bio?: string;
    tags?: string[];
}
