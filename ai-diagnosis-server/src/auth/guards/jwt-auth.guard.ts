import { Injectable, CanActivate, ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private readonly jwt: JwtService) {}

  canActivate(context: ExecutionContext): boolean {
    const req = context.switchToHttp().getRequest();
    const auth = req.headers.authorization;
    if (!auth || !auth.startsWith('Bearer ')) {
      throw new UnauthorizedException({ code: 'UNAUTHORIZED', message: '未提供认证令牌' });
    }
    try {
      const payload = this.jwt.verify(auth.slice(7));
      req.user = payload;
      return true;
    } catch {
      throw new UnauthorizedException({ code: 'UNAUTHORIZED', message: '认证令牌无效或已过期' });
    }
  }
}
