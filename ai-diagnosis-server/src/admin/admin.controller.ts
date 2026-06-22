import { Body, Controller, Get, Param, Patch, Post, Query, UseGuards, Req } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { AdminService } from './admin.service';

@Controller('api/admin')
@UseGuards(JwtAuthGuard, RolesGuard)
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('submissions')
  async listSubmissions(
    @Query('page') page?: string,
    @Query('pageSize') pageSize?: string,
    @Query('riskLevel') riskLevel?: string,
    @Query('reviewStatus') reviewStatus?: string,
    @Query('keyword') keyword?: string,
  ) {
    return this.adminService.listSubmissions({
      page: page ? parseInt(page) : undefined,
      pageSize: pageSize ? parseInt(pageSize) : undefined,
      riskLevel,
      reviewStatus,
      keyword,
    });
  }

  @Get('reports/:publicId')
  async getReportDetail(@Param('publicId') publicId: string) {
    return this.adminService.getReportDetail(publicId);
  }

  @Post('reports/:publicId/review')
  async review(
    @Param('publicId') publicId: string,
    @Req() req: any,
    @Body() body: { action: string; comment?: string },
  ) {
    const action = body.action as 'APPROVE' | 'REJECT';
    return this.adminService.review(publicId, req.user.sub, action, body.comment);
  }

  @Patch('reports/:publicId')
  @Roles('MANAGER', 'ADMIN')
  async updateReport(
    @Param('publicId') publicId: string,
    @Req() req: any,
    @Body() body: { htmlContent?: string; customerVisible?: boolean; riskLevel?: string; reviewStatus?: string; comment?: string },
  ) {
    return this.adminService.updateReport(publicId, req.user.sub, req.user.role, body);
  }
}
