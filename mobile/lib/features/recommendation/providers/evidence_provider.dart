import '../../market/models/market_snapshot.dart';
import '../models/evidence_definition.dart';
import '../models/evidence_result.dart';

abstract interface class EvidenceProvider {
  String get name;

  EvidenceDefinition get definition;

  EvidenceResult evaluate(MarketSnapshot snapshot);
}
