import { Body, Controller, Post, Param } from '@nestjs/common';
import { SubmissionService } from './submission.service';
import { SubmitQuestionnaireDto } from './dto/submit-questionnaire.dto';

@Controller('api/submissions')
export class SubmissionController {
  constructor(private readonly submissionService: SubmissionService) {}

  // V1: existing submit endpoint
  @Post()
  async submit(@Body() dto: SubmitQuestionnaireDto) {
    return this.submissionService.submit(dto);
  }

  // V2: start diagnosis with mode
  @Post('start')
  async start(@Body() dto: { phone?: string; mode: string }) {
    return this.submissionService.startV2Submission(dto.phone, dto.mode);
  }

  // V2: complete questionnaire and trigger diagnosis
  @Post(':publicId/complete')
  async complete(
    @Param('publicId') publicId: string,
    @Body() dto: { questionnaireVersion?: string; answers: { questionPublicId: string; value: unknown }[] },
  ) {
    return this.submissionService.completeV2Submission(publicId, dto);
  }
}
