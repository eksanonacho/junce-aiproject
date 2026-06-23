import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { QuestionnaireModule } from './questionnaire/questionnaire.module';
import { SubmissionModule } from './submission/submission.module';
import { DiagnosisModule } from './diagnosis/diagnosis.module';
import { ReportModule } from './report/report.module';
import { AuthModule } from './auth/auth.module';
import { AdminModule } from './admin/admin.module';
import { DocumentModule } from './document/document.module';
import { BusinessDashboardModule } from './business-dashboard/business-dashboard.module';

@Module({
  imports: [
    PrismaModule,
    QuestionnaireModule,
    SubmissionModule,
    DiagnosisModule,
    ReportModule,
    AuthModule,
    AdminModule,
    DocumentModule,
    BusinessDashboardModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
