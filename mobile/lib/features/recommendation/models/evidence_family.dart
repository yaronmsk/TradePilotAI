enum EvidenceFamily {
  generic,
  trend,
  momentum,
  participation,
  volatility,
  marketContext,
  fundamentals,
  sentiment,
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
      case EvidenceFamily.volatility:
        return 'Volatility';
      case EvidenceFamily.marketContext:
        return 'Market Context';
      case EvidenceFamily.fundamentals:
        return 'Fundamentals';
      case EvidenceFamily.sentiment:
        return 'Sentiment';
    }
  }
}
