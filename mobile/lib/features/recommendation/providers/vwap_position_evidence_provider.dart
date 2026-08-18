import '../../market/models/market_snapshot.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_family.dart';
import '../models/evidence_result.dart';
import '../utils/technical_indicator_math.dart';
import 'evidence_provider.dart';

class VwapPositionEvidenceProvider implements EvidenceProvider {
  const VwapPositionEvidenceProvider();

  static const EvidenceDefinition kDefinition = EvidenceDefinition(
    kind: EvidenceKind.vwapPosition,
    family: EvidenceFamily.priceStructure,
    name: 'VWAP Position',
    description:
        'Compares the latest price with the volume-weighted average price across the active intraday analysis window.',
    whyItMatters:
        'VWAP helps show whether current price is trading above or below the average price paid during the analyzed window, giving useful intraday structure context.',
    calculation:
        'TradePilot calculates a volume-weighted average of each candle\'s typical price across the available analysis window, then measures the latest price\'s percentage distance from that VWAP.',
  );

  @override
  String get name => kDefinition.name;

  @override
  EvidenceDefinition get definition => kDefinition;

  @override
  EvidenceResult evaluate(MarketSnapshot snapshot) {
    final candles = snapshot.candles;

    if (candles.length < 3) {
      return _insufficient();
    }

    final price = snapshot.currentPrice;
    final vwap = TechnicalIndicatorMath.windowVwap(candles);

    if (price <= 0 || vwap <= 0) {
      return _error('VWAP requires positive price and volume data.');
    }

    final distancePercent = ((price - vwap) / vwap) * 100;
    final magnitude = distancePercent.abs();

    final direction = distancePercent > 0.15
        ? EvidenceDirection.bullish
        : distancePercent < -0.15
        ? EvidenceDirection.bearish
        : EvidenceDirection.neutral;

    final strength = direction == EvidenceDirection.neutral
        ? EvidenceStrength.weak
        : magnitude >= 1.50
        ? EvidenceStrength.exceptional
        : magnitude >= 0.75
        ? EvidenceStrength.strong
        : EvidenceStrength.moderate;

    final score = direction == EvidenceDirection.neutral
        ? 48.0
        : magnitude >= 1.50
        ? 88.0
        : magnitude >= 0.75
        ? 76.0
        : 62.0;

    final reliability = (0.55 + ((candles.length / 48).clamp(0.0, 1.0) * 0.35))
        .clamp(0.55, 0.90);

    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.available,
      direction: direction,
      strength: strength,
      score: score,
      baseWeight: 0.75,
      dynamicWeight: 1,
      reliability: reliability,
      currentValue: 'Price ${price.toStringAsFixed(2)}',
      baselineValue: 'VWAP ${vwap.toStringAsFixed(2)}',
      relativeValue:
          '${distancePercent >= 0 ? '+' : ''}${distancePercent.toStringAsFixed(2)}% vs VWAP',
      explanation:
          '${direction == EvidenceDirection.bullish
              ? 'Price is holding above the analysis-window VWAP.'
              : direction == EvidenceDirection.bearish
              ? 'Price is trading below the analysis-window VWAP.'
              : 'Price is close to the analysis-window VWAP.'} VWAP and support/resistance share the Price Structure evidence group, so related structure signals cannot multiply confidence independently.',
    );
  }

  EvidenceResult _insufficient() {
    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.insufficientData,
      direction: EvidenceDirection.unknown,
      strength: EvidenceStrength.veryWeak,
      score: 0,
      baseWeight: 0.75,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Not available',
      baselineValue: 'At least 3 candles required',
      relativeValue: 'Not available',
      explanation: 'There is not enough candle history to calculate VWAP.',
      unavailableReason: 'At least three candles are required.',
    );
  }

  EvidenceResult _error(String reason) {
    return EvidenceResult(
      providerName: name,
      definition: definition,
      status: EvidenceStatus.error,
      direction: EvidenceDirection.unknown,
      strength: EvidenceStrength.veryWeak,
      score: 0,
      baseWeight: 0.75,
      dynamicWeight: 1,
      reliability: 0,
      currentValue: 'Not available',
      baselineValue: 'VWAP calculation',
      relativeValue: 'Not available',
      explanation: 'VWAP position could not be calculated.',
      unavailableReason: reason,
    );
  }
}
