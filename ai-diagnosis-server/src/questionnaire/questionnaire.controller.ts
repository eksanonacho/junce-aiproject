import { Controller, Get, Query } from '@nestjs/common';
import { QuestionnaireService } from './questionnaire.service';

@Controller('api/questionnaire')
export class QuestionnaireController {
  constructor(private readonly questionnaireService: QuestionnaireService) {}

  @Get()
  async getActive(@Query('version') version?: string) {
    return this.questionnaireService.getActiveQuestionnaire(version || 'v1');
  }
}
