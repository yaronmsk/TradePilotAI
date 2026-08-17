import 'package:flutter/material.dart';

import '../recommendation/models/recommendation.dart';
import '../recommendation/models/strategy_recommendation.dart';
import '../recommendation/models/strategy_summary.dart';
import '../recommendation/services/strategy_summary_service.dart';
import '../recommendation/widgets/consensus_summary_card.dart';
import '../recommendation/widgets/evidence_list.dart';
import '../recommendation/widgets/recommendation_card.dart';
import '../recommendation/widgets/stock_behavior_card.dart';
import '../recommendation/widgets/strategy_summary_card.dart';
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
      await dashboardController.selectSymbol(item.symbol);
    }
  }

  void _selectStrategy(StrategyType strategy) {
    if (_selectedStrategy == strategy) {
      return;
    }

    setState(() {
      _selectedStrategy = strategy;
    });
  }

  @override
  Widget build(BuildContext context) {
    final marketController = dashboardController.marketController;
    final historyController = dashboardController.marketHistoryController;
    final watchlistController = dashboardController.watchlistController;
    final recommendationController =
        dashboardController.recommendationController;

    return Scaffold(
      appBar: AppBar(title: const Text('TradePilot AI')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          children: [
            MarketStatusCard(
              marketController: marketController,
              historyController: historyController,
            ),
            AnimatedBuilder(
              animation: recommendationController,
              builder: (context, _) {
                final state = recommendationController.state;
                final recommendation =
                    state.recommendation ?? Recommendation.empty();

                final strategyRecommendations = <StrategyRecommendation>[
                  StrategyRecommendation(
                    strategy: StrategyType.trader,
                    recommendation: recommendation,
                  ),
                ];

                final strategies = _strategySummaryService.build(
                  recommendations: strategyRecommendations,
                );

                final selectedRecommendation = strategyRecommendations
                    .firstWhere(
                      (item) => item.strategy == _selectedStrategy,
                      orElse: () => strategyRecommendations.first,
                    );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state.stockBehaviorProfile != null)
                      StockBehaviorCard(profile: state.stockBehaviorProfile!),
                    StrategySummaryCard(
                      strategies: strategies,
                      selectedType: selectedRecommendation.strategy,
                      onStrategySelected: _selectStrategy,
                    ),
                    RecommendationCard(
                      strategyRecommendation: selectedRecommendation,
                    ),
                    ConsensusSummaryCard(
                      strategyRecommendation: selectedRecommendation,
                    ),
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
                    ),
                    RiskCard(strategy: selectedRecommendation.strategy),
                  ],
                );
              },
            ),
            WatchlistCard(
              controller: watchlistController,
              onSymbolSelected: dashboardController.selectSymbol,
              onAddPressed: _openAddStockDialog,
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text('Version 0.6', style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
