import '../history/historical_setup_validation.dart';
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
    this.historicalValidation = const HistoricalSetupValidation.unavailable(),
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
  final HistoricalSetupValidation historicalValidation;

  double get confidenceScore => evidenceScore;

  double get directionScore => consensus.directionScore ?? 0;

  Recommendation copyWith({
    RecommendationType? type,
    double? evidenceScore,
    ScoringResult? consensus,
    String? oneLineExplanation,
    String? timeframe,
    int? candleCount,
    DateTime? analysisTime,
    EvidenceReport? evidenceReport,
    HistoricalSetupValidation? historicalValidation,
  }) {
    return Recommendation(
      type: type ?? this.type,
      evidenceScore: evidenceScore ?? this.evidenceScore,
      consensus: consensus ?? this.consensus,
      oneLineExplanation: oneLineExplanation ?? this.oneLineExplanation,
      timeframe: timeframe ?? this.timeframe,
      candleCount: candleCount ?? this.candleCount,
      analysisTime: analysisTime ?? this.analysisTime,
      evidenceReport: evidenceReport ?? this.evidenceReport,
      historicalValidation: historicalValidation ?? this.historicalValidation,
    );
  }

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
