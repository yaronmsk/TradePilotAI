import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/strategy_timeframe_plan.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';

void main() {
  group('StrategyTimeframePlan', () {
    test('Trader defaults to 5m with 1h confirmation and daily backdrop', () {
      final plan = StrategyTimeframePlan.forStrategy(StrategyType.trader);

      expect(plan.primaryTimeframe, '5m');
      expect(plan.confirmationTimeframe, '1h');
      expect(plan.regimeTimeframe, '1d');
    });

    test('Trader exposes selectable intraday primary intervals', () {
      expect(
        StrategyTimeframePlan.primaryTimeframesFor(StrategyType.trader),
        <String>['1m', '5m', '15m', '30m', '1h'],
      );
    });

    test('15m Trader analysis keeps 1h confirmation and daily backdrop', () {
      final plan = StrategyTimeframePlan.traderForPrimary('15m');

      expect(plan.primaryTimeframe, '15m');
      expect(plan.confirmationTimeframe, '1h');
      expect(plan.regimeTimeframe, '1d');
    });

    test('30m Trader analysis uses 4h confirmation and daily backdrop', () {
      final plan = StrategyTimeframePlan.traderForPrimary('30m');

      expect(plan.primaryTimeframe, '30m');
      expect(plan.confirmationTimeframe, '4h');
      expect(plan.regimeTimeframe, '1d');
    });

    test('Swing defaults to daily analysis with weekly/monthly context', () {
      final plan = StrategyTimeframePlan.forStrategy(StrategyType.swing);

      expect(plan.primaryTimeframe, '1d');
      expect(plan.confirmationTimeframe, '1w');
      expect(plan.regimeTimeframe, '1mo');
    });

    test('Investor defaults to weekly analysis with long-term context', () {
      final plan = StrategyTimeframePlan.forStrategy(StrategyType.investor);

      expect(plan.primaryTimeframe, '1w');
      expect(plan.confirmationTimeframe, '1mo');
      expect(plan.regimeTimeframe, '3mo');
    });

    test('rejects unsupported Trader primary interval', () {
      expect(
        () => StrategyTimeframePlan.traderForPrimary('2h'),
        throwsArgumentError,
      );
    });
  });
}
