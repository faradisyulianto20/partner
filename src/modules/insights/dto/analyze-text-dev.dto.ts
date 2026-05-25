import { IsNotEmpty, IsString, MinLength } from 'class-validator';

export class AnalyzeTextDevDto {
    @IsString()
    @IsNotEmpty()
    userId!: string;

    @IsString()
    @IsNotEmpty()
    @MinLength(8)
    text!: string;
}
