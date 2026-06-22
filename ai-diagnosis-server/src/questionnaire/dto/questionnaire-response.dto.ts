class QuestionDto {
  id: number;
  publicId: string;
  text: string;
  type: string;
  options: unknown;
  required: boolean;
  riskDimension: string | null;
}

class QuestionGroupDto {
  label: string;
  order: number;
  questions: QuestionDto[];
}

export class QuestionnaireResponseDto {
  id: number;
  version: string;
  title: string;
  description: string | null;
  groups: QuestionGroupDto[];
}
