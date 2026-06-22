import { Module } from '@nestjs/common';
import { ReportController } from './report.controller';
import { ReportService } from './report.service';
import { ReportTemplateService } from './report-template.service';
import { ReportAccessTokenService } from './report-access-token.service';
import { ForbiddenPhraseCheckerService } from './forbidden-phrase-checker.service';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [AuthModule],
  controllers: [ReportController],
  providers: [
    ReportService,
    ReportTemplateService,
    ReportAccessTokenService,
    ForbiddenPhraseCheckerService,
  ],
  exports: [ReportService, ForbiddenPhraseCheckerService],
})
export class ReportModule {}
