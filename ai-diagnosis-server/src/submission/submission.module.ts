import { Module } from '@nestjs/common';
import { SubmissionController } from './submission.controller';
import { SubmissionService } from './submission.service';
import { DiagnosisModule } from '../diagnosis/diagnosis.module';
import { ReportModule } from '../report/report.module';

@Module({
  imports: [DiagnosisModule, ReportModule],
  controllers: [SubmissionController],
  providers: [SubmissionService],
})
export class SubmissionModule {}
