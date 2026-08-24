import '../../market/models/market_snapshot.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_result.dart';
import '../models/strategy_summary.dart';

abstract interface class EvidenceProvider {
  String get name;

  EvidenceDefinition get definition;

  EvidenceResult evaluate(MarketSnapshot snapshot);
}

/// Implemented only by evidence providers whose calculation has an explicit
/// strategy-specific implementation.
///
/// A provider being in Swing scope is not enough. It must implement this
/// interface and be marked implementation-ready in StrategyAnalysisPolicy
/// before the Swing evidence collector may execute it.
abstract interface class StrategyAwareEvidenceProvider
    implements EvidenceProvider {
  EvidenceResult evaluateForStrategy(
    MarketSnapshot snapshot, {
    required StrategyType strategy,
  });
}
