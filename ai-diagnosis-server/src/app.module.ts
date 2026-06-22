import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { QuestionnaireModule } from './questionnaire/questionnaire.module';
import { SubmissionModule } from './submission/submission.module';

@Module({
  imports: [PrismaModule, QuestionnaireModule, SubmissionModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
