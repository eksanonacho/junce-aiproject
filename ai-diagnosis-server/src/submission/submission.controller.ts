import { Body, Controller, Post } from '@nestjs/common';
import { SubmissionService } from './submission.service';
import { SubmitQuestionnaireDto } from './dto/submit-questionnaire.dto';

@Controller('api/submissions')
export class SubmissionController {
  constructor(private readonly submissionService: SubmissionService) {}

  @Post()
  async submit(@Body() dto: SubmitQuestionnaireDto) {
    return this.submissionService.submit(dto);
  }
}
