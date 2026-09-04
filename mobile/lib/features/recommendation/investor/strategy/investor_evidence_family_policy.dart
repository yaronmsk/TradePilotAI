import '../../models/evidence_family.dart';

/// v0.12 Investor family classification foundation.
///
/// This class does not assign scoring weights or thresholds. It only records
/// which independent evidence families are considered core company/business
/// evidence so later recommendation policy can require genuine fundamental
/// breadth.
class InvestorEvidenceFamilyPolicy {
  InvestorEvidenceFamilyPolicy._();

  static const Set<EvidenceFamily> coreFundamentalFamilies = {
    EvidenceFamily.growth,
    EvidenceFamily.profitabilityQuality,
    EvidenceFamily.financialStrength,
    EvidenceFamily.valuation,
    EvidenceFamily.revisions,
    EvidenceFamily.competitiveDurability,
    EvidenceFamily.capitalAllocation,
  };

  /// Core families currently allowed to satisfy actionable breadth.
  ///
  /// Competitive Durability remains a core business concept, but Batch 5
  /// demonstrated raw-input overlap with Profitability & Quality. It therefore
  /// stays excluded from breadth until Batch 8 defines the overlap policy.
  static const Set<EvidenceFamily> breadthEligibleCoreFundamentalFamilies = {
    EvidenceFamily.growth,
    EvidenceFamily.profitabilityQuality,
    EvidenceFamily.financialStrength,
    EvidenceFamily.valuation,
    EvidenceFamily.revisions,
    EvidenceFamily.capitalAllocation,
  };

  static const Set<EvidenceFamily> contextualFamilies = {
    EvidenceFamily.marketContext,
    EvidenceFamily.trend,
    EvidenceFamily.sentiment,
    EvidenceFamily.ownershipPositioning,
  };

  static bool isCoreFundamental(EvidenceFamily family) =>
      coreFundamentalFamilies.contains(family);

  static int countCoreFundamentalFamilies(Iterable<EvidenceFamily> families) {
    return families.toSet().where(coreFundamentalFamilies.contains).length;
  }

  static bool isBreadthEligibleCoreFundamental(EvidenceFamily family) =>
      breadthEligibleCoreFundamentalFamilies.contains(family);

  static int countBreadthEligibleCoreFundamentalFamilies(
    Iterable<EvidenceFamily> families,
  ) {
    return families
        .toSet()
        .where(breadthEligibleCoreFundamentalFamilies.contains)
        .length;
  }

  static bool hasCoreFundamentalBreadth(
    Iterable<EvidenceFamily> families, {
    required int minimumFamilies,
  }) {
    assert(minimumFamilies >= 0);
    return countBreadthEligibleCoreFundamentalFamilies(families) >=
        minimumFamilies;
  }
}
