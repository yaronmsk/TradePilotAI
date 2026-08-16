import '../models/evidence_report.dart';
import '../models/scoring_result.dart';
import 'consensus_engine.dart';

/// Backwards-compatible scoring facade.
///
/// New recommendation code should think in terms of consensus rather than a
/// flat indicator score. The facade remains so older tests and call sites do
/// not need to understand the migration details.
class ScoringEngine {
  const ScoringEngine({this.consensusEngine = const ConsensusEngine()});

  final ConsensusEngine consensusEngine;

  ScoringResult calculate(EvidenceReport report) {
    return consensusEngine.calculate(report);
  }
}
