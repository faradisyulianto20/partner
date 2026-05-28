export class ClientProfileDto {
    userId!: string;
    email?: string;
    displayName?: string;
    username!: string;
    birthDate?: string;
    gender?: 'MALE' | 'FEMALE';
    photoUrl?: string;
}
