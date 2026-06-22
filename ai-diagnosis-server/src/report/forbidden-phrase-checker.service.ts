import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class ForbiddenPhraseCheckerService {
  private readonly logger = new Logger(ForbiddenPhraseCheckerService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Scan htmlContent for forbidden phrases, replace with safe alternatives.
   * Returns cleaned content and a count of replacements made.
   */
  async check(htmlContent: string): Promise<{ cleaned: string; replacements: number }> {
    const phrases = await this.prisma.forbiddenPhrase.findMany({
      where: { isActive: true },
    });

    let cleaned = htmlContent;
    let replacements = 0;

    for (const fp of phrases) {
      if (cleaned.includes(fp.phrase)) {
        const regex = new RegExp(fp.phrase.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g');
        const count = (cleaned.match(regex) || []).length;
        if (count > 0) {
          cleaned = cleaned.replace(regex, fp.safeAlternative);
          replacements += count;
          this.logger.warn(`Replaced forbidden phrase "${fp.phrase}" → "${fp.safeAlternative}" (${count} occurrences)`);
        }
      }
    }

    return { cleaned, replacements };
  }
}
