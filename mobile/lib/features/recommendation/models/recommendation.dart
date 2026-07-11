import 'evidence_report.dart';

enum RecommendationType {
  strongBuy,
  buy,
  hold,
  sell,
  strongSell,
  wait,
  unknown,
}

class Recommendation {
  final RecommendationType type;

  /// Evidence strength from 0 to 100.
  final double evidenceScore;

  /// One-line explanation shown directly to the user.
  final String oneLineExplanation;

  /// Analysis interval, for example "5m".
  final String timeframe;

  /// Number of candles included in the analysis.
  final int candleCount;

  /// Time when the recommendation was generated.
  final DateTime? analysisTime;

  /// Detailed evidence supporting the recommendation.
  final EvidenceReport evidenceReport;

  const Recommendation({
    required this.type,
    required this.evidenceScore,
    required this.oneLineExplanation,
    required this.timeframe,
    required this.candleCount,
    required this.analysisTime,
    required this.evidenceReport,
  });

  factory Recommendation.empty() {
    return Recommendation(
      type: RecommendationType.unknown,
      evidenceScore: 0,
      oneLineExplanation: 'Waiting for market analysis.',
      timeframe: '5m',
      candleCount: 48,
      analysisTime: null,
      evidenceReport: EvidenceReport.fromResults(
        results: const [],
        expectedProviderCount: 0,
      ),
    );
  }
}