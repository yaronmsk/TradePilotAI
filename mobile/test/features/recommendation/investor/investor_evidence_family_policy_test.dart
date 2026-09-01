import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/investor/strategy/investor_evidence_family_policy.dart';
import 'package:mobile/features/recommendation/models/evidence_family.dart';

void main() {
  group('InvestorEvidenceFamilyPolicy', () {
    test('defines seven independent core fundamental families', () {
      expect(InvestorEvidenceFamilyPolicy.coreFundamentalFamilies, {
        EvidenceFamily.growth,
        EvidenceFamily.profitabilityQuality,
        EvidenceFamily.financialStrength,
        EvidenceFamily.valuation,
        EvidenceFamily.revisions,
        EvidenceFamily.competitiveDurability,
        EvidenceFamily.capitalAllocation,
      });
      expect(InvestorEvidenceFamilyPolicy.coreFundamentalFamilies.length, 7);
    });

    test('does not treat context or legacy fundamentals as core breadth', () {
      expect(
        InvestorEvidenceFamilyPolicy.isCoreFundamental(
          EvidenceFamily.marketContext,
        ),
        isFalse,
      );
      expect(
        InvestorEvidenceFamilyPolicy.isCoreFundamental(
          EvidenceFamily.ownershipPositioning,
        ),
        isFalse,
      );
      expect(
        InvestorEvidenceFamilyPolicy.isCoreFundamental(
          EvidenceFamily.fundamentals,
        ),
        isFalse,
      );
    });

    test('breadth de-duplicates repeated families', () {
      const families = [
        EvidenceFamily.growth,
        EvidenceFamily.growth,
        EvidenceFamily.valuation,
        EvidenceFamily.marketContext,
      ];

      expect(
        InvestorEvidenceFamilyPolicy.countCoreFundamentalFamilies(families),
        2,
      );
      expect(
        InvestorEvidenceFamilyPolicy.hasCoreFundamentalBreadth(
          families,
          minimumFamilies: 3,
        ),
        isFalse,
      );
    });
  });

  group('Investor evidence-family presentation', () {
    test('uses human-readable labels', () {
      expect(EvidenceFamily.growth.label, 'Growth');
      expect(
        EvidenceFamily.profitabilityQuality.label,
        'Profitability & Quality',
      );
      expect(EvidenceFamily.financialStrength.label, 'Financial Strength');
      expect(EvidenceFamily.valuation.label, 'Valuation');
      expect(EvidenceFamily.revisions.label, 'Revisions');
      expect(
        EvidenceFamily.competitiveDurability.label,
        'Competitive Durability',
      );
      expect(EvidenceFamily.capitalAllocation.label, 'Capital Allocation');
      expect(
        EvidenceFamily.ownershipPositioning.label,
        'Ownership & Positioning',
      );
    });
  });
}
