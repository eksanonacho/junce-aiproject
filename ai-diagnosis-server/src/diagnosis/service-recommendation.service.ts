import { Injectable } from '@nestjs/common';

interface RecommendationInput {
  serviceType: string;
  reason: string;
  priority: 'STRONG' | 'SUGGEST' | 'INFO';
}

@Injectable()
export class ServiceRecommendationService {
  /**
   * Collect, deduplicate, and sort service recommendations from matched rules.
   *
   * Priority mapping: HIGH risk source → STRONG, MEDIUM → SUGGEST, LOW → INFO
   */
  build(
    matchedRules: { riskLevel: string; recommendServices: unknown }[],
  ): RecommendationInput[] {
    const map = new Map<string, RecommendationInput>();

    for (const rule of matchedRules) {
      const services = this.extractServices(rule.recommendServices);
      if (!services || services.length === 0) continue;

      const priority = this.mapPriority(rule.riskLevel);

      for (const svc of services) {
        const existing = map.get(svc);
        // Upgrade priority if higher
        if (!existing || this.priorityRank(priority) > this.priorityRank(existing.priority)) {
          map.set(svc, {
            serviceType: svc,
            reason: `根据命中的风险项推荐`,
            priority,
          });
        }
      }
    }

    // Sort: STRONG first, then SUGGEST, then INFO
    const sorted = Array.from(map.values());
    sorted.sort((a, b) => this.priorityRank(b.priority) - this.priorityRank(a.priority));

    return sorted;
  }

  private extractServices(raw: unknown): string[] {
    if (!raw) return [];
    if (Array.isArray(raw)) return raw.filter((s) => typeof s === 'string');
    return [];
  }

  private mapPriority(riskLevel: string): 'STRONG' | 'SUGGEST' | 'INFO' {
    switch (riskLevel) {
      case 'HIGH': return 'STRONG';
      case 'MEDIUM': return 'SUGGEST';
      case 'LOW': return 'INFO';
      default: return 'INFO';
    }
  }

  private priorityRank(p: string): number {
    switch (p) {
      case 'STRONG': return 3;
      case 'SUGGEST': return 2;
      case 'INFO': return 1;
      default: return 0;
    }
  }
}
