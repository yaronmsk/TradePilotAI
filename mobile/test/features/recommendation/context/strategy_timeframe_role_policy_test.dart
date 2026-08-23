import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/multi_timeframe_profile.dart';
import 'package:mobile/features/recommendation/context/strategy_timeframe_role_policy.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';

void main() {
  group('StrategyTimeframeRolePolicy', () {
    test('Trader preserves the validated v0.10.1 role weights', () {
      const policy = StrategyTimeframeRolePolicy.trader;

      expect(policy.strategy, StrategyType.trader);
      expect(policy.primaryAnchorsDirection, isFalse);
      expect(policy.directionWeightFor(TimeframeRole.primary), 0.45);
      expect(policy.directionWeightFor(TimeframeRole.confirmation), 0.35);
      expect(policy.directionWeightFor(TimeframeRole.regime), 0.20);
      expect(policy.totalDirectionWeight, 1);
      expect(policy.totalAgreementWeight, 1);
      expect(policy.isComplete, isTrue);
    });

    test('Swing makes the primary timeframe the directional anchor', () {
      const policy = StrategyTimeframeRolePolicy.swing;

      expect(policy.strategy, StrategyType.swing);
      expect(policy.primaryAnchorsDirection, isTrue);

      expect(policy.directionWeightFor(TimeframeRole.primary), 0.60);
      expect(policy.directionWeightFor(TimeframeRole.confirmation), 0.25);
      expect(policy.directionWeightFor(TimeframeRole.regime), 0.15);

      expect(policy.agreementWeightFor(TimeframeRole.primary), 0);
      expect(policy.agreementWeightFor(TimeframeRole.confirmation), 0.65);
      expect(policy.agreementWeightFor(TimeframeRole.regime), 0.35);

      expect(policy.totalDirectionWeight, 1);
      expect(policy.totalAgreementWeight, 1);
      expect(policy.isComplete, isTrue);
    });

    test('Investor timeframe semantics remain deferred', () {
      const policy = StrategyTimeframeRolePolicy.investorDeferred;

      expect(policy.strategy, StrategyType.investor);
      expect(policy.implementationReady, isFalse);
      expect(policy.totalDirectionWeight, 0);
      expect(policy.totalAgreementWeight, 0);
      expect(policy.isComplete, isTrue);
    });
  });
}
