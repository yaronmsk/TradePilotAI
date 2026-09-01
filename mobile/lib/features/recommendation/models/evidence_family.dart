enum EvidenceFamily {
  generic,
  trend,
  momentum,
  participation,
  priceStructure,
  volatility,
  marketContext,

  /// Legacy/reserved umbrella retained for compatibility.
  ///
  /// Investor v0.12 uses the independent families below instead of collapsing
  /// all company economics into one capped Fundamentals family.
  fundamentals,
  sentiment,

  growth,
  profitabilityQuality,
  financialStrength,
  valuation,
  revisions,
  competitiveDurability,
  capitalAllocation,
  ownershipPositioning,
}

extension EvidenceFamilyPresentation on EvidenceFamily {
  String get label {
    switch (this) {
      case EvidenceFamily.generic:
        return 'Other';
      case EvidenceFamily.trend:
        return 'Trend';
      case EvidenceFamily.momentum:
        return 'Momentum';
      case EvidenceFamily.participation:
        return 'Participation';
      case EvidenceFamily.priceStructure:
        return 'Price Structure';
      case EvidenceFamily.volatility:
        return 'Volatility';
      case EvidenceFamily.marketContext:
        return 'Market Context';
      case EvidenceFamily.fundamentals:
        return 'Fundamentals';
      case EvidenceFamily.sentiment:
        return 'Sentiment';
      case EvidenceFamily.growth:
        return 'Growth';
      case EvidenceFamily.profitabilityQuality:
        return 'Profitability & Quality';
      case EvidenceFamily.financialStrength:
        return 'Financial Strength';
      case EvidenceFamily.valuation:
        return 'Valuation';
      case EvidenceFamily.revisions:
        return 'Revisions';
      case EvidenceFamily.competitiveDurability:
        return 'Competitive Durability';
      case EvidenceFamily.capitalAllocation:
        return 'Capital Allocation';
      case EvidenceFamily.ownershipPositioning:
        return 'Ownership & Positioning';
    }
  }
}
