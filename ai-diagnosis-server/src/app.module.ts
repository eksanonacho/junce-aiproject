import { Module } from '@nestjs/common';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';
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
    ThrottlerModule.forRoot([{ ttl: 60000, limit: 100 }]), // global default: 100 req/min
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
  providers: [
    AppService,
    { provide: APP_GUARD, useClass: ThrottlerGuard },
  ],
})
export class AppModule {}
