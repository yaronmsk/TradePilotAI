import '../models/strategy_summary.dart';

class MarketContextStrategyPolicy {
  const MarketContextStrategyPolicy({
    required this.strategy,
    required this.confirmationWeight,
    required this.regimeWeight,
    required this.minimumConfirmationCandles,
    required this.minimumRegimeCandles,
    required this.directionThreshold,
    required this.conflictDirectionThreshold,
    required this.providerBaseWeight,
    required this.conflictDynamicWeight,
    required this.reliabilityBase,
    required this.sectorReliabilityBonus,
    required this.agreementReliabilityBonus,
    required this.preserveMissingSectorDuplication,
  });

  static const trader = MarketContextStrategyPolicy(
    strategy: StrategyType.trader,
    confirmationWeight: 0.55,
    regimeWeight: 0.45,
    minimumConfirmationCandles: 3,
    minimumRegimeCandles: 3,
    directionThreshold: 8,
    conflictDirectionThreshold: 8,
    providerBaseWeight: 0.85,
    conflictDynamicWeight: 1,
    reliabilityBase: 0.72,
    sectorReliabilityBonus: 0.10,
    agreementReliabilityBonus: 0.13,
    preserveMissingSectorDuplication: true,
  );

  static const swing = MarketContextStrategyPolicy(
    strategy: StrategyType.swing,
    confirmationWeight: 0.65,
    regimeWeight: 0.35,
    minimumConfirmationCandles: 12,
    minimumRegimeCandles: 12,
    directionThreshold: 12,
    conflictDirectionThreshold: 35,
    providerBaseWeight: 0.75,
    conflictDynamicWeight: 0.70,
    reliabilityBase: 0.68,
    sectorReliabilityBonus: 0.12,
    agreementReliabilityBonus: 0.15,
    preserveMissingSectorDuplication: false,
  );

  final StrategyType strategy;

  final double confirmationWeight;
  final double regimeWeight;

  final int minimumConfirmationCandles;
  final int minimumRegimeCandles;

  final double directionThreshold;
  final double conflictDirectionThreshold;

  final double providerBaseWeight;
  final double conflictDynamicWeight;

  final double reliabilityBase;
  final double sectorReliabilityBonus;
  final double agreementReliabilityBonus;

  final bool preserveMissingSectorDuplication;

  static MarketContextStrategyPolicy? forStrategy(StrategyType strategy) {
    return switch (strategy) {
      StrategyType.trader => trader,
      StrategyType.swing => swing,
      StrategyType.investor => null,
    };
  }
}
