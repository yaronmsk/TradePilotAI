import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/multi_timeframe_profile.dart';
import 'package:mobile/features/recommendation/context/strategy_timeframe_plan.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/providers/multi_timeframe_trend_evidence_provider.dart';

void main() {
  const provider = MultiTimeframeTrendEvidenceProvider();

  TimeframeTrendSignal signal({
    required TimeframeRole role,
    required String timeframe,
    required EvidenceDirection direction,
    double strength = 70,
  }) {
    return TimeframeTrendSignal(
      role: role,
      timeframe: timeframe,
      direction: direction,
      movePercent: direction == EvidenceDirection.bearish ? -8 : 8,
      strengthScore: strength,
      trendEfficiency: 0.75,
      sampleSize: 60,
    );
  }

  MultiTimeframeProfile profile({
    required StrategyTimeframePlan plan,
    required EvidenceDirection primary,
    required EvidenceDirection confirmation,
    required EvidenceDirection regime,
    required TimeframeAlignment alignment,
    required double directionScore,
    double agreement = 1,
    double reliability = 0.90,
  }) {
    return MultiTimeframeProfile(
      plan: plan,
      primary: signal(
        role: TimeframeRole.primary,
        timeframe: plan.primaryTimeframe,
        direction: primary,
      ),
      confirmation: signal(
        role: TimeframeRole.confirmation,
        timeframe: plan.confirmationTimeframe,
        direction: confirmation,
      ),
      regime: signal(
        role: TimeframeRole.regime,
        timeframe: plan.regimeTimeframe,
        direction: regime,
      ),
      alignment: alignment,
      directionScore: directionScore,
      agreement: agreement,
      reliability: reliability,
    );
  }

  test('preserves Trader direction-score interpretation', () {
    final result = provider.evaluate(
      profile(
        plan: StrategyTimeframePlan.trader,
        primary: EvidenceDirection.bullish,
        confirmation: EvidenceDirection.bullish,
        regime: EvidenceDirection.bullish,
        alignment: TimeframeAlignment.aligned,
        directionScore: 72,
      ),
    );

    expect(result.status, EvidenceStatus.available);
    expect(result.direction, EvidenceDirection.bullish);
    expect(result.score, 72);
    expect(result.reliability, 0.90);
  });

  test('aligned Swing profile produces bullish evidence', () {
    final result = provider.evaluate(
      profile(
        plan: StrategyTimeframePlan.swing,
        primary: EvidenceDirection.bullish,
        confirmation: EvidenceDirection.bullish,
        regime: EvidenceDirection.bullish,
        alignment: TimeframeAlignment.aligned,
        directionScore: 84,
      ),
      strategy: StrategyType.swing,
    );

    expect(result.status, EvidenceStatus.available);
    expect(result.direction, EvidenceDirection.bullish);
    expect(result.score, 84);
    expect(result.baselineValue, '1d / 1w / 1mo');
    expect(result.explanation, contains('primary setup'));
  });

  test('broader Swing opposition weakens without flipping primary', () {
    final result = provider.evaluate(
      profile(
        plan: StrategyTimeframePlan.swing,
        primary: EvidenceDirection.bullish,
        confirmation: EvidenceDirection.bearish,
        regime: EvidenceDirection.bearish,
        alignment: TimeframeAlignment.opposed,
        directionScore: 18,
        agreement: 0,
      ),
      strategy: StrategyType.swing,
    );

    expect(result.direction, EvidenceDirection.bullish);
    expect(result.currentValue, 'Opposed');
    expect(result.explanation, contains('cannot independently reverse'));
  });

  test('malformed Swing reversal cannot create opposite evidence', () {
    final result = provider.evaluate(
      profile(
        plan: StrategyTimeframePlan.swing,
        primary: EvidenceDirection.bullish,
        confirmation: EvidenceDirection.bearish,
        regime: EvidenceDirection.bearish,
        alignment: TimeframeAlignment.opposed,
        directionScore: -40,
      ),
      strategy: StrategyType.swing,
    );

    expect(result.direction, EvidenceDirection.neutral);
    expect(result.score, 0);
  });

  test('alternate 4H Swing hierarchy is supported', () {
    final plan = StrategyTimeframePlan.swingForPrimary('4h');

    final result = provider.evaluate(
      profile(
        plan: plan,
        primary: EvidenceDirection.bearish,
        confirmation: EvidenceDirection.bearish,
        regime: EvidenceDirection.bearish,
        alignment: TimeframeAlignment.aligned,
        directionScore: -78,
      ),
      strategy: StrategyType.swing,
    );

    expect(result.direction, EvidenceDirection.bearish);
    expect(result.baselineValue, '4h / 1d / 1w');
  });

  test('Trader profile cannot leak into Swing evaluation', () {
    final result = provider.evaluate(
      profile(
        plan: StrategyTimeframePlan.trader,
        primary: EvidenceDirection.bullish,
        confirmation: EvidenceDirection.bullish,
        regime: EvidenceDirection.bullish,
        alignment: TimeframeAlignment.aligned,
        directionScore: 80,
      ),
      strategy: StrategyType.swing,
    );

    expect(result.status, EvidenceStatus.unavailable);
    expect(result.direction, EvidenceDirection.unknown);
  });

  test('Investor remains unavailable in v0.11', () {
    final result = provider.evaluate(
      profile(
        plan: StrategyTimeframePlan.investor,
        primary: EvidenceDirection.bullish,
        confirmation: EvidenceDirection.bullish,
        regime: EvidenceDirection.bullish,
        alignment: TimeframeAlignment.aligned,
        directionScore: 80,
      ),
      strategy: StrategyType.investor,
    );

    expect(result.status, EvidenceStatus.unavailable);
    expect(result.direction, EvidenceDirection.unknown);
  });
}
