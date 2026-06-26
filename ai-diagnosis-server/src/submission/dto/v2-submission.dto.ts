import { IsString, IsNotEmpty, IsOptional, IsIn, IsArray, ArrayMinSize, Matches } from 'class-validator';

export class StartDiagnosisDto {
  @IsOptional()
  @IsString()
  @Matches(/^1[3-9]\d{9}$/, { message: '手机号格式不正确' })
  phone?: string;

  @IsString()
  @IsNotEmpty()
  @IsIn(['QUICK', 'STANDARD', 'DEEP'], { message: 'mode 必须是 QUICK, STANDARD 或 DEEP' })
  mode!: string;
}

export class LookupPhoneDto {
  @IsString()
  @IsNotEmpty()
  @Matches(/^1[3-9]\d{9}$/, { message: '手机号格式不正确' })
  phone!: string;
}

class CompleteAnswer {
  @IsString() @IsNotEmpty()
  questionPublicId!: string;

  value: unknown;
}

export class CompleteDiagnosisDto {
  @IsOptional()
  @IsString()
  questionnaireVersion?: string;

  @IsArray()
  @ArrayMinSize(1, { message: '答案不能为空' })
  answers!: CompleteAnswer[];
}
