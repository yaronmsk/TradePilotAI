import '../../market/models/market_snapshot.dart';
import '../models/evidence_result.dart';

abstract interface class EvidenceProvider {
  String get name;

  EvidenceResult evaluate(MarketSnapshot snapshot);
}
