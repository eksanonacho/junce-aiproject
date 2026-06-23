import { Module } from '@nestjs/common';
import { BusinessDashboardService } from './business-dashboard.service';

@Module({
  providers: [BusinessDashboardService],
  exports: [BusinessDashboardService],
})
export class BusinessDashboardModule {}
