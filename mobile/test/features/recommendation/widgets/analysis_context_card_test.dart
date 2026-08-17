import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/market_context_profile.dart';
import 'package:mobile/features/recommendation/context/market_context_target.dart';
import 'package:mobile/features/recommendation/context/multi_timeframe_profile.dart';
import 'package:mobile/features/recommendation/context/recommendation_analysis_context.dart';
import 'package:mobile/features/recommendation/context/strategy_timeframe_plan.dart';
import 'package:mobile/features/recommendation/models/evidence_result.dart';
import 'package:mobile/features/recommendation/models/strategy_summary.dart';
import 'package:mobile/features/recommendation/widgets/analysis_context_card.dart';

void main() {
  final analysisContext = RecommendationAnalysisContext(
    multiTimeframeProfile: MultiTimeframeProfile(
      plan: StrategyTimeframePlan.trader,
      primary: const TimeframeTrendSignal(
        role: TimeframeRole.primary,
        timeframe: '5m',
        direction: EvidenceDirection.bullish,
        movePercent: 2,
        strengthScore: 70,
        trendEfficiency: 0.8,
        sampleSize: 48,
      ),
      confirmation: const TimeframeTrendSignal(
        role: TimeframeRole.confirmation,
        timeframe: '1h',
        direction: EvidenceDirection.bullish,
        movePercent: 5,
        strengthScore: 80,
        trendEfficiency: 0.85,
        sampleSize: 48,
      ),
      regime: const TimeframeTrendSignal(
        role: TimeframeRole.regime,
        timeframe: '1d',
        direction: EvidenceDirection.bullish,
        movePercent: 10,
        strengthScore: 90,
        trendEfficiency: 0.9,
        sampleSize: 48,
      ),
      alignment: TimeframeAlignment.aligned,
      directionScore: 80,
      agreement: 1,
      reliability: 0.9,
    ),
    marketContextProfile: MarketContextProfile(
      target: const MarketContextTarget(
        marketSymbol: 'SPY',
        sectorSymbol: 'XLK',
        sectorName: 'Technology',
        hasSectorBenchmark: true,
      ),
      backdrop: MarketBackdrop.supportive,
      relativeStrength: RelativeStrengthState.outperforming,
      directionScore: 70,
      reliability: 0.9,
      stockVsMarketPercent: 4.5,
      stockVsSectorPercent: 2.5,
      sectorVsMarketPercent: 2,
      marketCompositeReturnPercent: 3,
      sectorCompositeReturnPercent: 5,
    ),
  );

  testWidgets('presents clear strategy-aware timeframe and market context', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AnalysisContextCard(
              strategy: StrategyType.trader,
              analysisContext: analysisContext,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Trader Analysis Context'), findsOneWidget);
    expect(find.text('Timeframe Alignment'), findsOneWidget);
    expect(find.text('Aligned'), findsOneWidget);
    expect(find.text('Market Environment'), findsOneWidget);
    expect(find.text('Market Backdrop'), findsNothing);
    expect(find.text('Supportive'), findsOneWidget);
    expect(find.text('Relative Strength'), findsOneWidget);
    expect(find.text('Outperforming'), findsOneWidget);
    expect(
      find.textContaining('Short-term trend (5-minute candles): Bullish'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Near-term trend (1-hour candles): Bullish'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Daily backdrop (1-day candles): Bullish'),
      findsOneWidget,
    );
  });

  testWidgets('explains candle intervals and market environment clearly', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnalysisContextCard(
            strategy: StrategyType.trader,
            analysisContext: analysisContext,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('About Analysis Context'));
    await tester.pumpAndSettle();

    expect(find.text('What is Analysis Context?'), findsOneWidget);
    expect(
      find.textContaining('candle intervals, not the total holding period'),
      findsOneWidget,
    );
    expect(find.textContaining('Market Environment evaluates'), findsOneWidget);
    expect(
      find.textContaining('do not override the complete evidence set'),
      findsOneWidget,
    );
  });
}
