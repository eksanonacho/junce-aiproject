import { Type } from 'class-transformer';
import {
  IsArray,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Matches,
  ValidateNested,
} from 'class-validator';

export class SubmitAnswerDto {
  @IsInt()
  questionId!: number;

  @IsNotEmpty()
  value!: unknown;
}

export class SubmitQuestionnaireDto {
  @IsInt()
  questionnaireId!: number;

  @IsOptional()
  @Matches(/^1[3-9]\d{9}$/, { message: '手机号格式不正确' })
  phone?: string;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => SubmitAnswerDto)
  answers!: SubmitAnswerDto[];
}
