import { Controller, Get, Param, Post } from '@nestjs/common';
import { DiagnosisService } from './diagnosis.service';

@Controller('api/diagnosis')
export class DiagnosisController {
  constructor(private readonly diagnosisService: DiagnosisService) {}

  /**
   * GET /api/diagnosis/submissions/:publicId
   * Query structured diagnosis result for a submission.
   */
  @Get('submissions/:publicId')
  async getResult(@Param('publicId') publicId: string) {
    return this.diagnosisService.getResult(publicId);
  }

  /**
   * POST /api/diagnosis/submissions/:publicId/run
   * Manually trigger (or re-run) diagnosis for a submission.
   */
  @Post('submissions/:publicId/run')
  async runDiagnosis(@Param('publicId') publicId: string) {
    return this.diagnosisService.runDiagnosis(publicId);
  }
}
