import 'historical_setup_case.dart';
import 'historical_setup_fingerprint.dart';

class HistoricalComparisonSelector {
  const HistoricalComparisonSelector({this.maximumObservations = 160});

  final int maximumObservations;

  List<HistoricalComparisonObservation> select({
    required String currentSymbol,
    required HistoricalSetupFingerprint current,
    required List<HistoricalComparisonObservation> observations,
  }) {
    final normalizedSymbol = currentSymbol.trim().toUpperCase();

    final selected =
        observations
            .where((observation) {
              final fingerprint = observation.fingerprint;

              return observation.symbol.trim().toUpperCase() ==
                      normalizedSymbol &&
                  fingerprint.strategy == current.strategy &&
                  fingerprint.primaryTimeframe == current.primaryTimeframe &&
                  fingerprint.stockBehaviorType == current.stockBehaviorType &&
                  fingerprint.volatilityRegime == current.volatilityRegime &&
                  fingerprint.marketBackdrop == current.marketBackdrop;
            })
            .toList(growable: false)
          ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

    return List<HistoricalComparisonObservation>.unmodifiable(
      selected.take(maximumObservations),
    );
  }
}
