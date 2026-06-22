import { Controller, Get } from '@nestjs/common';
import { QuestionnaireService } from './questionnaire.service';

@Controller('api/questionnaire')
export class QuestionnaireController {
  constructor(private readonly questionnaireService: QuestionnaireService) {}

  @Get()
  async getActive() {
    return this.questionnaireService.getActiveQuestionnaire();
  }
}
