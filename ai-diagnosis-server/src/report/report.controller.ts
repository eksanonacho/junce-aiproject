import { Controller, Get, Param, Post, Query } from '@nestjs/common';
import { ReportService } from './report.service';

@Controller('api/reports')
export class ReportController {
  constructor(private readonly reportService: ReportService) {}

  /**
   * GET /api/reports/:publicId/status
   */
  @Get(':publicId/status')
  async getStatus(@Param('publicId') publicId: string) {
    return this.reportService.getReportStatus(publicId);
  }

  /**
   * GET /api/reports/:publicId?token=xxx
   */
  @Get(':publicId')
  async getDetail(
    @Param('publicId') publicId: string,
    @Query('token') token: string,
  ) {
    if (!token) {
      // Return status only if no token
      return this.reportService.getReportStatus(publicId);
    }
    return this.reportService.getReportDetail(publicId, token);
  }

  /**
   * POST /api/reports/submissions/:submissionPublicId/generate
   */
  @Post('submissions/:submissionPublicId/generate')
  async generate(@Param('submissionPublicId') submissionPublicId: string) {
    return this.reportService.generateReport(submissionPublicId);
  }
}
