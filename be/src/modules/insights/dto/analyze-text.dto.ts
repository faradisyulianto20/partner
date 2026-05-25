import { IsNotEmpty, IsString, MinLength } from 'class-validator';

export class AnalyzeTextDto {
    @IsString()
    @IsNotEmpty()
    @MinLength(8)
    text!: string;
}
