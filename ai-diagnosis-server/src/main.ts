import 'dotenv/config';
import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { AppModule } from './app.module';
import helmet from 'helmet';

// Validate critical env vars at startup
function validateEnv() {
  const missing: string[] = [];
  if (!process.env['JWT_SECRET'] || process.env['JWT_SECRET'] === 'ai-diagnosis-dev-secret') {
    Logger.warn('⚠️  JWT_SECRET is using default dev value — NOT safe for production', 'EnvCheck');
  }
  if (!process.env['DATABASE_URL']) {
    missing.push('DATABASE_URL');
  }
  // Production node_env check
  const isProduction = process.env['NODE_ENV'] === 'production';
  if (isProduction) {
    if (!process.env['JWT_SECRET'] || process.env['JWT_SECRET'] === 'ai-diagnosis-dev-secret') {
      Logger.error('JWT_SECRET is missing or using dev default in production. Refusing to start.', 'EnvCheck');
      process.exit(1);
    }
  }
  if (missing.length > 0) {
    Logger.error(`Missing required env vars: ${missing.join(', ')}. Refusing to start.`, 'EnvCheck');
    process.exit(1);
  }
}

async function bootstrap() {
  validateEnv();

  const app = await NestFactory.create(AppModule);

  // Security: Helmet
  app.use(helmet());

  // Security: CORS whitelist from env
  const corsOrigins = process.env['CORS_ORIGINS'];
  if (corsOrigins) {
    app.enableCors({
      origin: corsOrigins.split(',').map((s) => s.trim()),
      credentials: true,
    });
  } else {
    // Dev default: allow local dev servers
    const isProduction = process.env['NODE_ENV'] === 'production';
    if (isProduction) {
      Logger.warn('CORS_ORIGINS not set in production — allowing only same-origin', 'CORS');
    } else {
      app.enableCors({
        origin: ['http://localhost:5173', 'http://localhost:8080', 'http://localhost:3001'],
        credentials: true,
      });
    }
  }

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  const port = process.env['PORT'] ?? 3001;
  await app.listen(port, '0.0.0.0');
  Logger.log(`AI Diagnosis Server running on http://localhost:${port}`, 'Bootstrap');
}
bootstrap();
