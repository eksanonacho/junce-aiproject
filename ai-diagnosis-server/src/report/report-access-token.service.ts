import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import * as crypto from 'crypto';
import * as bcrypt from 'bcryptjs';

@Injectable()
export class ReportAccessTokenService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Generate a token for report access.
   * Returns the plaintext token once. Database stores bcrypt hash.
   */
  async generateToken(reportId: number, expiresInDays = 7): Promise<string> {
    // Delete old tokens for this report
    await this.prisma.reportAccessToken.deleteMany({ where: { reportId } });

    const plainToken = crypto.randomBytes(32).toString('hex');
    const tokenHash = await bcrypt.hash(plainToken, 10);
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + expiresInDays);

    await this.prisma.reportAccessToken.create({
      data: {
        reportId,
        tokenHash,
        expiresAt,
      },
    });

    return plainToken;
  }

  /**
   * Validate a token for a report. Returns the reportId if valid.
   */
  async validateToken(publicId: string, plainToken: string): Promise<number> {
    const report = await this.prisma.report.findUnique({
      where: { publicId },
      include: { accessTokens: true },
    });

    if (!report || report.accessTokens.length === 0) {
      throw new BadRequestException({
        code: 'INVALID_REPORT_TOKEN',
        message: '报告访问凭证无效',
      });
    }

    // Find a matching token (check all, bcrypt compare is slow but acceptable here)
    for (const at of report.accessTokens) {
      const match = await bcrypt.compare(plainToken, at.tokenHash);
      if (match) {
        // Check expiry
        if (new Date() > at.expiresAt) {
          throw new BadRequestException({
            code: 'REPORT_TOKEN_EXPIRED',
            message: '报告访问凭证已过期',
          });
        }
        // Mark as used
        await this.prisma.reportAccessToken.update({
          where: { id: at.id },
          data: { usedAt: new Date() },
        });
        return report.id;
      }
    }

    throw new BadRequestException({
      code: 'INVALID_REPORT_TOKEN',
      message: '报告访问凭证无效',
    });
  }
}
