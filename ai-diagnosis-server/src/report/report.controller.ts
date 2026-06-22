import { Controller, Get, Param, Post, Query, UseGuards } from '@nestjs/common';
import { ReportService } from './report.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';

@Controller('api/reports')
export class ReportController {
  constructor(private readonly reportService: ReportService) {}

  @Get(':publicId/status')
  async getStatus(@Param('publicId') publicId: string) {
    return this.reportService.getReportStatus(publicId);
  }

  @Get(':publicId')
  async getDetail(
    @Param('publicId') publicId: string,
    @Query('token') token: string,
  ) {
    if (!token) return this.reportService.getReportStatus(publicId);
    return this.reportService.getReportDetail(publicId, token);
  }

  @Post('submissions/:submissionPublicId/generate')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MANAGER', 'ADMIN')
  async generate(@Param('submissionPublicId') submissionPublicId: string) {
    return this.reportService.generateReport(submissionPublicId);
  }
}
