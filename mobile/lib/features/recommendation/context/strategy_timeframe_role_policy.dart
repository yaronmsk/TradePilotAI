import '../models/strategy_summary.dart';
import 'multi_timeframe_profile.dart';

/// Strategy-specific semantic policy for the three timeframe roles.
///
/// These weights operate only inside Multi-Timeframe Trend context. They are
/// not user-facing recommendation attribution percentages.
///
/// Recommendation attribution is calculated later from actual effective
/// evidence contributions after weighting, reliability, family aggregation
/// and family caps.
class StrategyTimeframeRolePolicy {
  const StrategyTimeframeRolePolicy({
    required this.strategy,
    required this.implementationReady,
    required this.primaryAnchorsDirection,
    required this.primaryDirectionWeight,
    required this.confirmationDirectionWeight,
    required this.regimeDirectionWeight,
    required this.primaryAgreementWeight,
    required this.confirmationAgreementWeight,
    required this.regimeAgreementWeight,
  });

  /// Preserves the v0.10.1 Trader calculation.
  static const trader = StrategyTimeframeRolePolicy(
    strategy: StrategyType.trader,
    implementationReady: true,
    primaryAnchorsDirection: false,
    primaryDirectionWeight: 0.45,
    confirmationDirectionWeight: 0.35,
    regimeDirectionWeight: 0.20,
    primaryAgreementWeight: 0.45,
    confirmationAgreementWeight: 0.35,
    regimeAgreementWeight: 0.20,
  );

  /// Initial deterministic Swing role policy.
  ///
  /// The primary timeframe defines the active Swing setup direction.
  /// Confirmation and regime timeframes may reinforce that setup or weaken it
  /// toward neutral, but they do not independently flip the setup direction.
  ///
  /// These values are architectural policy assumptions, not historical
  /// optimization results.
  static const swing = StrategyTimeframeRolePolicy(
    strategy: StrategyType.swing,
    implementationReady: true,
    primaryAnchorsDirection: true,
    primaryDirectionWeight: 0.60,
    confirmationDirectionWeight: 0.25,
    regimeDirectionWeight: 0.15,
    primaryAgreementWeight: 0,
    confirmationAgreementWeight: 0.65,
    regimeAgreementWeight: 0.35,
  );

  /// Investor semantics are intentionally not decided during v0.11.0.
  static const investorDeferred = StrategyTimeframeRolePolicy(
    strategy: StrategyType.investor,
    implementationReady: false,
    primaryAnchorsDirection: true,
    primaryDirectionWeight: 0,
    confirmationDirectionWeight: 0,
    regimeDirectionWeight: 0,
    primaryAgreementWeight: 0,
    confirmationAgreementWeight: 0,
    regimeAgreementWeight: 0,
  );

  final StrategyType strategy;
  final bool implementationReady;

  /// When true, higher timeframes can strengthen or weaken the primary setup
  /// but cannot independently reverse its direction.
  final bool primaryAnchorsDirection;

  final double primaryDirectionWeight;
  final double confirmationDirectionWeight;
  final double regimeDirectionWeight;

  final double primaryAgreementWeight;
  final double confirmationAgreementWeight;
  final double regimeAgreementWeight;

  static StrategyTimeframeRolePolicy forStrategy(StrategyType strategy) {
    return switch (strategy) {
      StrategyType.trader => trader,
      StrategyType.swing => swing,
      StrategyType.investor => investorDeferred,
    };
  }

  double directionWeightFor(TimeframeRole role) {
    return switch (role) {
      TimeframeRole.primary => primaryDirectionWeight,
      TimeframeRole.confirmation => confirmationDirectionWeight,
      TimeframeRole.regime => regimeDirectionWeight,
    };
  }

  double agreementWeightFor(TimeframeRole role) {
    return switch (role) {
      TimeframeRole.primary => primaryAgreementWeight,
      TimeframeRole.confirmation => confirmationAgreementWeight,
      TimeframeRole.regime => regimeAgreementWeight,
    };
  }

  double get totalDirectionWeight =>
      primaryDirectionWeight +
      confirmationDirectionWeight +
      regimeDirectionWeight;

  double get totalAgreementWeight =>
      primaryAgreementWeight +
      confirmationAgreementWeight +
      regimeAgreementWeight;

  bool get isComplete {
    if (!implementationReady) {
      return strategy == StrategyType.investor &&
          totalDirectionWeight == 0 &&
          totalAgreementWeight == 0;
    }

    return _approximatelyOne(totalDirectionWeight) &&
        _approximatelyOne(totalAgreementWeight) &&
        primaryDirectionWeight >= 0 &&
        confirmationDirectionWeight >= 0 &&
        regimeDirectionWeight >= 0 &&
        primaryAgreementWeight >= 0 &&
        confirmationAgreementWeight >= 0 &&
        regimeAgreementWeight >= 0;
  }

  bool _approximatelyOne(double value) => (value - 1).abs() < 0.000001;
}
