import '../models/evidence_definition.dart';
import '../models/strategy_summary.dart';
import '../providers/evidence_provider.dart';
import 'strategy_analysis_policy.dart';
import 'strategy_analysis_policy_catalog.dart';

/// Applies the strategy policy at the evidence-collection boundary.
///
/// Scope approval alone is not enough to execute a provider. The provider's
/// current implementation must also be explicitly marked ready for the
/// requested strategy.
class StrategyEvidenceSelector {
  const StrategyEvidenceSelector();

  StrategyAnalysisPolicy policyFor(StrategyType strategy) {
    return StrategyAnalysisPolicyCatalog.forStrategy(strategy);
  }

  bool allowsDefinition({
    required EvidenceDefinition definition,
    required StrategyType strategy,
  }) {
    // Generic evidence is retained for Trader compatibility and isolated
    // testing/extensions. It is never allowed to leak into Swing or Investor
    // without explicit production classification.
    if (definition.kind == EvidenceKind.generic) {
      return strategy == StrategyType.trader;
    }

    final policy = policyFor(strategy).policyFor(definition.kind);

    return policy?.canUseCurrentImplementation ?? false;
  }

  bool allowsProvider({
    required EvidenceProvider provider,
    required StrategyType strategy,
  }) {
    final definitionAllowed = allowsDefinition(
      definition: provider.definition,
      strategy: strategy,
    );

    if (!definitionAllowed) {
      return false;
    }

    if (strategy == StrategyType.trader) {
      return true;
    }

    // A non-Trader provider must explicitly implement strategy-aware
    // evaluation before its implementation-ready policy may execute it.
    return provider is StrategyAwareEvidenceProvider;
  }

  List<EvidenceProvider> selectProviders({
    required List<EvidenceProvider> providers,
    required StrategyType strategy,
  }) {
    return List<EvidenceProvider>.unmodifiable(
      providers.where(
        (provider) => allowsProvider(provider: provider, strategy: strategy),
      ),
    );
  }
}
