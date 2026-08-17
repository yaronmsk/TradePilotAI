import '../models/evidence_result.dart';
import 'strategy_timeframe_plan.dart';

enum TimeframeRole { primary, confirmation, regime }

enum TimeframeAlignment { unknown, aligned, mixed, opposed }

class TimeframeTrendSignal {
  const TimeframeTrendSignal({
    required this.role,
    required this.timeframe,
    required this.direction,
    required this.movePercent,
    required this.strengthScore,
    required this.trendEfficiency,
    required this.sampleSize,
  });

  const TimeframeTrendSignal.unknown({
    required this.role,
    required this.timeframe,
  }) : direction = EvidenceDirection.unknown,
       movePercent = 0,
       strengthScore = 0,
       trendEfficiency = 0,
       sampleSize = 0;

  final TimeframeRole role;
  final String timeframe;
  final EvidenceDirection direction;
  final double movePercent;
  final double strengthScore;
  final double trendEfficiency;
  final int sampleSize;

  bool get isAvailable =>
      direction != EvidenceDirection.unknown && sampleSize >= 3;
}

class MultiTimeframeProfile {
  const MultiTimeframeProfile({
    required this.plan,
    required this.primary,
    required this.confirmation,
    required this.regime,
    required this.alignment,
    required this.directionScore,
    required this.agreement,
    required this.reliability,
  });

  MultiTimeframeProfile.unknown({
    StrategyTimeframePlan plan = StrategyTimeframePlan.trader,
  }) : plan = plan,
       primary = TimeframeTrendSignal.unknown(
         role: TimeframeRole.primary,
         timeframe: plan.primaryTimeframe,
       ),
       confirmation = TimeframeTrendSignal.unknown(
         role: TimeframeRole.confirmation,
         timeframe: plan.confirmationTimeframe,
       ),
       regime = TimeframeTrendSignal.unknown(
         role: TimeframeRole.regime,
         timeframe: plan.regimeTimeframe,
       ),
       alignment = TimeframeAlignment.unknown,
       directionScore = 0,
       agreement = 0,
       reliability = 0;

  final StrategyTimeframePlan plan;
  final TimeframeTrendSignal primary;
  final TimeframeTrendSignal confirmation;
  final TimeframeTrendSignal regime;
  final TimeframeAlignment alignment;

  /// Signed multi-timeframe trend score from -100 to +100.
  final double directionScore;

  /// Directional agreement between the configured timeframe roles, 0 to 1.
  final double agreement;

  /// Data and alignment reliability, 0 to 1.
  final double reliability;

  bool get hasSufficientData =>
      primary.isAvailable && confirmation.isAvailable && regime.isAvailable;
}
