import '../../models/evidence_definition.dart';
import '../models/investor_data_contracts.dart';
import '../models/investor_metric_assessment.dart';

/// Investor-specific evidence boundary.
///
/// Investor evidence consumes point-in-time company/context data rather than a
/// short-horizon MarketSnapshot. It still emits the shared EvidenceResult
/// format through [InvestorEvidenceAssessment], so later Investor orchestration
/// can feed the existing consensus architecture without creating a parallel
/// recommendation engine.
abstract interface class InvestorEvidenceProvider {
  String get name;
  EvidenceDefinition get definition;

  InvestorEvidenceAssessment evaluate(InvestorPointInTimeSnapshot snapshot);
}
