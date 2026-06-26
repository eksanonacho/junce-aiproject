import { Module, Logger } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';

function getJwtSecret(): string {
  const secret = process.env['JWT_SECRET'];
  if (!secret) {
    Logger.error('JWT_SECRET environment variable is not set. Refusing to start.', 'AuthModule');
    process.exit(1);
  }
  if (secret === 'ai-diagnosis-dev-secret') {
    Logger.warn('⚠️  JWT_SECRET is using the known dev-secret value — NOT safe for production.', 'AuthModule');
  }
  return secret;
}

@Module({
  imports: [
    JwtModule.register({
      secret: getJwtSecret(),
      signOptions: { expiresIn: '7d' as const },
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService],
  exports: [JwtModule, AuthService],
})
export class AuthModule {}
