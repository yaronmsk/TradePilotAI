import 'evidence_report.dart';
import 'scoring_result.dart';

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
  const Recommendation({
    required this.type,
    required this.evidenceScore,
    required this.oneLineExplanation,
    required this.timeframe,
    required this.candleCount,
    required this.analysisTime,
    required this.evidenceReport,
    this.consensus = const ScoringResult.empty(),
  });

  final RecommendationType type;

  /// Confidence from 0 to 100. The legacy field name is preserved so the
  /// current public model remains source-compatible while the UI now calls
  /// this value "Confidence".
  final double evidenceScore;

  /// Consensus details used to separate recommendation direction from
  /// confidence and to explain supporting/opposing evidence families.
  final ScoringResult consensus;

  final String oneLineExplanation;
  final String timeframe;
  final int candleCount;
  final DateTime? analysisTime;
  final EvidenceReport evidenceReport;

  double get confidenceScore => evidenceScore;

  double get directionScore => consensus.directionScore ?? 0;

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
