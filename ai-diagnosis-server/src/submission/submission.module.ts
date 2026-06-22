import { Module } from '@nestjs/common';
import { SubmissionController } from './submission.controller';
import { SubmissionService } from './submission.service';
import { DiagnosisModule } from '../diagnosis/diagnosis.module';

@Module({
  imports: [DiagnosisModule],
  controllers: [SubmissionController],
  providers: [SubmissionService],
})
export class SubmissionModule {}
