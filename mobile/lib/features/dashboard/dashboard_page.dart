import 'package:flutter/material.dart';

import '../recommendation/models/strategy_recommendation.dart';
import '../recommendation/models/strategy_summary.dart';
import '../recommendation/services/strategy_summary_service.dart';
import '../recommendation/services/swing_decision_helper_service.dart';
import '../recommendation/widgets/analysis_context_card.dart';
import '../recommendation/widgets/consensus_summary_card.dart';
import '../recommendation/widgets/evidence_list.dart';
import '../recommendation/widgets/recommendation_card.dart';
import '../recommendation/widgets/stock_behavior_card.dart';
import '../recommendation/widgets/strategy_summary_card.dart';
import '../recommendation/widgets/swing_decision_helper_card.dart';
import '../watchlist/models/watchlist_item.dart';
import '../watchlist/widgets/add_stock_dialog.dart';
import '../watchlist/widgets/watchlist_card.dart';
import 'controllers/dashboard_controller.dart';
import 'widgets/market_status_card.dart';
import 'widgets/risk_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({required this.dashboardController, super.key});

  final DashboardController dashboardController;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardController get dashboardController => widget.dashboardController;

  static const _strategySummaryService = StrategySummaryService();
  static const _swingDecisionHelperService = SwingDecisionHelperService();

  StrategyType _selectedStrategy = StrategyType.trader;

  Future<void> _openAddStockDialog() async {
    final WatchlistItem? item = await AddStockDialog.show(context);

    if (item == null || !mounted) {
      return;
    }

    final watchlistController = dashboardController.watchlistController;
    final previousItemCount = watchlistController.state.items.length;

    watchlistController.addItem(item);

    final wasAdded = watchlistController.state.items.length > previousItemCount;

    if (wasAdded) {
      await _selectSymbol(item.symbol);
    }
  }

  Future<void> _selectSymbol(String symbol) async {
    if (_selectedStrategy != StrategyType.trader) {
      setState(() {
        _selectedStrategy = StrategyType.trader;
      });
    }

    await dashboardController.selectSymbol(symbol);
  }

  Future<void> _selectStrategy(StrategyType strategy) async {
    if (dashboardController.isAnalysisReloading) {
      return;
    }

    if (_selectedStrategy == strategy &&
        dashboardController.activeAnalysisStrategy == strategy) {
      return;
    }

    setState(() {
      _selectedStrategy = strategy;
    });

    try {
      // Market snapshot and chart state are shared. Re-running the selected
      // strategy keeps those visible inputs aligned while the controller
      // continues to retain independent Trader/Swing recommendation states.
      await dashboardController.analyzeStrategy(strategy);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not analyze ${strategy.title}: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final marketController = dashboardController.marketController;
    final historyController = dashboardController.marketHistoryController;
    final watchlistController = dashboardController.watchlistController;

    return Scaffold(
      appBar: AppBar(title: const Text('TradePilot AI')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          children: [
            WatchlistCard(
              controller: watchlistController,
              onSymbolSelected: _selectSymbol,
              onAddPressed: _openAddStockDialog,
            ),
            MarketStatusCard(
              marketController: marketController,
              historyController: historyController,
            ),
            AnimatedBuilder(
              animation: dashboardController,
              builder: (context, _) {
                final strategyRecommendations =
                    dashboardController.strategyRecommendations;

                final strategies = _strategySummaryService.build(
                  recommendations: strategyRecommendations,
                );

                final selectedState = dashboardController
                    .recommendationStateFor(_selectedStrategy);
                final selectedResult = selectedState.recommendation;
                final selectedRecommendation = selectedResult == null
                    ? null
                    : StrategyRecommendation(
                        strategy: _selectedStrategy,
                        recommendation: selectedResult,
                      );

                final swingDecisionHelper = selectedRecommendation == null
                    ? null
                    : _swingDecisionHelperService.build(selectedRecommendation);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StrategySummaryCard(
                      strategies: strategies,
                      selectedType: _selectedStrategy,
                      onStrategySelected: (strategy) {
                        _selectStrategy(strategy);
                      },
                    ),
                    if (dashboardController.isAnalysisReloading) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: LinearProgressIndicator(),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (selectedState.analysisContext != null)
                      AnalysisContextCard(
                        strategy: _selectedStrategy,
                        analysisContext: selectedState.analysisContext!,
                        timeframePlan: dashboardController.analysisPlanFor(
                          _selectedStrategy,
                        ),
                        availablePrimaryTimeframes: dashboardController
                            .availablePrimaryTimeframesFor(_selectedStrategy),
                        onPrimaryTimeframeSelected: (timeframe) {
                          dashboardController.selectAnalysisTimeframe(
                            _selectedStrategy,
                            timeframe,
                          );
                        },
                        isReloading: dashboardController.isAnalysisReloading,
                      ),
                    if (selectedState.stockBehaviorProfile != null)
                      StockBehaviorCard(
                        profile: selectedState.stockBehaviorProfile!,
                      ),
                    if (selectedRecommendation != null) ...[
                      RecommendationCard(
                        strategyRecommendation: selectedRecommendation,
                      ),
                      ConsensusSummaryCard(
                        strategyRecommendation: selectedRecommendation,
                      ),
                      if (swingDecisionHelper != null)
                        SwingDecisionHelperCard(summary: swingDecisionHelper),
                      const SizedBox(height: 8),
                      Text(
                        '${selectedRecommendation.title} Evidence',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      EvidenceList(
                        results: selectedRecommendation
                            .recommendation
                            .evidenceReport
                            .results,
                        familySummaries: selectedRecommendation
                            .recommendation
                            .consensus
                            .familySummaries,
                      ),
                      RiskCard(strategy: selectedRecommendation.strategy),
                    ] else if (!dashboardController.isAnalysisReloading)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          '${_selectedStrategy.title} is ready. '
                          'Select the strategy above to run its analysis.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Version 0.11.0',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
