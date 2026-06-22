import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';
import { AuthModule } from '../auth/auth.module';
import { ReportModule } from '../report/report.module';
import { ForbiddenPhraseCheckerService } from '../report/forbidden-phrase-checker.service';

@Module({
  imports: [AuthModule, ReportModule],
  controllers: [AdminController],
  providers: [AdminService, ForbiddenPhraseCheckerService],
})
export class AdminModule {}
