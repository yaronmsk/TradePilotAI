import '../../models/evidence_family.dart';

class InvestorRecommendationPolicy {
  InvestorRecommendationPolicy._();

  /// Six core families are currently eligible to satisfy action breadth.
  ///
  /// Competitive Durability remains a core business concept but its Batch 5
  /// proxy reuses Quality inputs, so it is deliberately excluded from breadth
  /// and recommendation weighting until genuinely independent durability data
  /// exists.
  static const Set<EvidenceFamily> breadthEligibleCoreFamilies = {
    EvidenceFamily.growth,
    EvidenceFamily.profitabilityQuality,
    EvidenceFamily.financialStrength,
    EvidenceFamily.valuation,
    EvidenceFamily.revisions,
    EvidenceFamily.capitalAllocation,
  };

  static const Set<EvidenceFamily> requiredCoreFamilies = {
    EvidenceFamily.valuation,
  };

  static const Set<EvidenceFamily> directionalContextFamilies = {
    EvidenceFamily.marketContext,
    EvidenceFamily.ownershipPositioning,
  };

  static const Set<EvidenceFamily> zeroRecommendationWeightFamilies = {
    EvidenceFamily.competitiveDurability,
  };

  static const int minimumCoreFamiliesForAction = 4;
  static const double minimumCoreCoverage = 2 / 3;

  static const double actionDirectionThreshold = 40;
  static const double strongDirectionThreshold = 70;
  static const double holdDirectionThreshold = 20;

  static const double minimumActionConfidence = 65;
  static const double strongActionConfidence = 80;

  static const double materialConflictThreshold = 0.50;

  /// Context can refine an established Investor thesis but cannot dominate it.
  ///
  /// This is a cap on the collective absolute direction-attribution share of
  /// Market Context + Ownership & Positioning after family de-duplication.
  static const double maximumContextDirectionShare = 0.20;

  /// Batch 8 deliberately assigns no confidence-point modifier to VIX.
  ///
  /// VIX remains risk context and zero-direction. A non-zero confidence
  /// penalty would require a separately validated, explicitly bounded policy.
  static const double marketImpliedVolatilityConfidenceImpactPoints = 0;

  /// The current durability proxy receives no recommendation direction,
  /// confidence, or breadth credit because it overlaps Quality inputs.
  static const double competitiveDurabilityRecommendationWeight = 0;

  static int get expectedCoreFamilyCount => breadthEligibleCoreFamilies.length;

  static bool isBreadthEligibleCore(EvidenceFamily family) =>
      breadthEligibleCoreFamilies.contains(family);

  static bool isDirectionalContext(EvidenceFamily family) =>
      directionalContextFamilies.contains(family);

  static bool hasRequiredCoreFamilies(Iterable<EvidenceFamily> families) {
    final available = families.toSet();
    return available.containsAll(requiredCoreFamilies);
  }
}
