import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/strategy/event_risk_strategy_policy.dart';

void main() {
  group('EventRiskStrategyPolicy', () {
    test('Trader preserves validated timing penalties', () {
      const policy = EventRiskStrategyPolicy.trader;

      expect(policy.useExistingProfilePenalty, isTrue);
      expect(policy.maximumRelevantEarningsHours, 168);
      expect(policy.maximumRelevantMacroHours, 48);

      expect(
        policy.penaltyFor(earningsHoursAway: 28, macroEventHoursAway: 36),
        7,
      );
    });

    test('Swing extends relevance into the days-to-weeks horizon', () {
      const policy = EventRiskStrategyPolicy.swing;

      expect(policy.useExistingProfilePenalty, isFalse);
      expect(policy.maximumRelevantEarningsHours, 336);
      expect(policy.maximumRelevantMacroHours, 168);

      expect(
        policy.penaltyFor(earningsHoursAway: 28, macroEventHoursAway: 36),
        11,
      );

      expect(
        policy.penaltyFor(earningsHoursAway: 200, macroEventHoursAway: 100),
        4.5,
      );
    });

    test('Swing ignores events outside its relevance windows', () {
      const policy = EventRiskStrategyPolicy.swing;

      expect(
        policy.penaltyFor(earningsHoursAway: 337, macroEventHoursAway: 169),
        0,
      );
    });

    test('combined Swing Event Risk can never exceed twelve points', () {
      const policy = EventRiskStrategyPolicy.swing;

      expect(
        policy.penaltyFor(earningsHoursAway: 2, macroEventHoursAway: 2),
        EventRiskStrategyPolicy.maximumPenaltyPoints,
      );
    });

    test('Investor Event Risk remains deferred to v0.12', () {
      expect(
        EventRiskStrategyPolicy.forStrategy(StrategyType.investor),
        isNull,
      );
    });
  });
}
