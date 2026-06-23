import { Module } from '@nestjs/common';
import { DiagnosisController } from './diagnosis.controller';
import { DiagnosisService } from './diagnosis.service';
import { RuleEngineService } from './rule-engine.service';
import { RiskLevelService } from './risk-level.service';
import { ServiceRecommendationService } from './service-recommendation.service';
import { BusinessDashboardModule } from '../business-dashboard/business-dashboard.module';

@Module({
  imports: [BusinessDashboardModule],
  controllers: [DiagnosisController],
  providers: [
    DiagnosisService,
    RuleEngineService,
    RiskLevelService,
    ServiceRecommendationService,
  ],
  exports: [DiagnosisService],
})
export class DiagnosisModule {}
