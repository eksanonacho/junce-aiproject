import { Body, Controller, Post, Param, Headers } from '@nestjs/common';
import { SubmissionService } from './submission.service';
import { SubmitQuestionnaireDto } from './dto/submit-questionnaire.dto';
import { StartDiagnosisDto, LookupPhoneDto, CompleteDiagnosisDto } from './dto/v2-submission.dto';
import { DocumentService } from '../document/document.service';

@Controller('api/submissions')
export class SubmissionController {
  constructor(
    private readonly submissionService: SubmissionService,
    private readonly documentService: DocumentService,
  ) {}

  // V1: existing submit endpoint
  @Post()
  async submit(@Body() dto: SubmitQuestionnaireDto) {
    return this.submissionService.submit(dto);
  }

  // V2: start diagnosis with mode
  @Post('start')
  async start(@Body() dto: StartDiagnosisDto) {
    return this.submissionService.startV2Submission(dto.phone, dto.mode);
  }

  // V2: lookup phone number history
  @Post('lookup')
  async lookup(@Body() dto: LookupPhoneDto) {
    return this.submissionService.lookupByPhone(dto.phone);
  }

  // V2: complete questionnaire and trigger diagnosis (requires X-Submission-Token)
  @Post(':publicId/complete')
  async complete(
    @Param('publicId') publicId: string,
    @Body() dto: CompleteDiagnosisDto,
    @Headers('x-submission-token') token?: string,
  ) {
    await this.documentService.validateSubmissionToken(publicId, token);
    return this.submissionService.completeV2Submission(publicId, dto);
  }
}
