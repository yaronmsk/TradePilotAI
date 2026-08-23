import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/external_context_profile.dart';
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
    externalContextProfile: const ExternalContextProfile(
      marketBreadth: MarketBreadthProfile(
        state: MarketBreadthState.healthy,
        advancingPercent: 61,
        above50DayPercent: 64,
        sectorParticipationPercent: 58,
        volatilityPercentile: 42,
        directionScore: 32,
        reliability: 0.9,
        summary: 'Broad participation is healthy.',
      ),
      eventRisk: EventRiskProfile(
        level: EventRiskLevel.high,
        earningsHoursAway: 28,
        macroEventHoursAway: 36,
        macroEventLabel: 'High-impact macro event',
        confidencePenaltyPoints: 6,
        summary: 'Event risk is elevated.',
      ),
      newsSentiment: NewsSentimentProfile(
        state: NewsSentimentState.positive,
        sentimentScore: 45,
        articleCount: 9,
        sourceCount: 5,
        freshnessHours: 2.5,
        materiality: 0.8,
        reliability: 0.88,
        summary: 'Recent news is positive.',
      ),
      isSynthetic: true,
      sourceLabel: 'Development simulation',
    ),
  );

  Widget buildCard({ValueChanged<String>? onSelected}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: AnalysisContextCard(
            strategy: StrategyType.trader,
            analysisContext: analysisContext,
            timeframePlan: StrategyTimeframePlan.trader,
            availablePrimaryTimeframes:
                StrategyTimeframePlan.traderPrimaryTimeframes,
            onPrimaryTimeframeSelected: onSelected,
          ),
        ),
      ),
    );
  }

  testWidgets('presents selectable strategy-aware analysis context', (
    tester,
  ) async {
    await tester.pumpWidget(buildCard());

    expect(find.text('Trader Analysis Context'), findsOneWidget);
    expect(find.text('Primary Analysis Interval'), findsOneWidget);
    expect(find.text('1m'), findsOneWidget);
    expect(find.text('5m'), findsOneWidget);
    expect(find.text('15m'), findsOneWidget);
    expect(find.text('30m'), findsOneWidget);
    expect(find.text('1h'), findsOneWidget);
    expect(find.text('Confirmation Interval'), findsOneWidget);
    expect(find.textContaining('1-hour candles'), findsOneWidget);
    expect(find.text('Broader Regime Interval'), findsOneWidget);
    expect(find.textContaining('1-day candles'), findsOneWidget);
    expect(find.text('Timeframe Alignment'), findsOneWidget);
    expect(find.text('Aligned'), findsOneWidget);
    expect(find.text('Market Environment'), findsOneWidget);
    expect(find.text('Market Backdrop'), findsNothing);
    expect(find.text('Supportive'), findsOneWidget);
    expect(find.text('Market Breadth'), findsOneWidget);
    expect(find.text('Healthy'), findsOneWidget);
    expect(find.text('Relative Strength'), findsOneWidget);
    expect(find.text('Outperforming'), findsOneWidget);
    expect(find.text('Event Risk'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
    expect(find.text('News Sentiment'), findsOneWidget);
    expect(find.text('Positive'), findsOneWidget);
    expect(
      find.textContaining(
        'Both broader trend views support the primary Trader setup',
      ),
      findsOneWidget,
    );
  });

  testWidgets('notifies when the user selects another Trader interval', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      buildCard(
        onSelected: (timeframe) {
          selected = timeframe;
        },
      ),
    );

    await tester.tap(find.text('15m'));
    await tester.pump();

    expect(selected, '15m');
  });

  testWidgets('explains selectable candle intervals and market environment', (
    tester,
  ) async {
    await tester.pumpWidget(buildCard());

    await tester.tap(find.byTooltip('About Analysis Context'));
    await tester.pumpAndSettle();

    expect(find.text('What is Analysis Context?'), findsOneWidget);
    expect(
      find.textContaining('The Primary Analysis Interval controls'),
      findsOneWidget,
    );
    expect(
      find.textContaining('candle intervals, not the expected holding period'),
      findsOneWidget,
    );
    expect(find.textContaining('Market Environment evaluates'), findsOneWidget);
    expect(
      find.textContaining('Market Breadth asks whether many stocks'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Event Risk covers scheduled catalysts'),
      findsOneWidget,
    );
    expect(
      find.textContaining('News Sentiment is directional evidence'),
      findsOneWidget,
    );
  });

  testWidgets(
    'provides an individual explainability path for every context metric',
    (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1000);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildCard());

      const tooltips = [
        'About Primary Analysis Interval',
        'About Confirmation Interval',
        'About Broader Regime Interval',
        'About Timeframe Alignment',
        'About Market Environment',
        'About Market Breadth',
        'About Relative Strength',
        'About Event Risk',
        'About News Sentiment',
      ];

      for (final tooltip in tooltips) {
        expect(
          find.byTooltip(tooltip),
          findsOneWidget,
          reason: '$tooltip must be available.',
        );
      }

      await tester.tap(find.byTooltip('About Event Risk'));
      await tester.pumpAndSettle();

      expect(find.text('About Event Risk'), findsOneWidget);
      expect(find.text('Confidence / risk only'), findsOneWidget);
      expect(find.textContaining('at most 12 points'), findsOneWidget);
      expect(
        find.textContaining('cannot create Buy/Sell direction'),
        findsOneWidget,
      );
      expect(find.text('Supportive interpretation'), findsNothing);
      expect(find.text('Opposing interpretation'), findsNothing);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('About Primary Analysis Interval'));
      await tester.pumpAndSettle();

      expect(find.text('About Primary Analysis Interval'), findsOneWidget);
      expect(find.text('Context / configuration'), findsOneWidget);
      expect(
        find.textContaining('does not create bullish or bearish evidence'),
        findsOneWidget,
      );

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('About Timeframe Alignment'));
      await tester.pumpAndSettle();

      expect(find.text('About Timeframe Alignment'), findsOneWidget);
      expect(find.text('Directional / evaluative'), findsOneWidget);
      expect(find.text('Supportive interpretation'), findsOneWidget);
      expect(find.text('Opposing interpretation'), findsOneWidget);
    },
  );
  testWidgets(
    'presents human-readable Swing timeframe roles with individual info paths',
    (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(900, 1200);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final swingContext = RecommendationAnalysisContext(
        multiTimeframeProfile: MultiTimeframeProfile(
          plan: StrategyTimeframePlan.swing,
          primary: const TimeframeTrendSignal(
            role: TimeframeRole.primary,
            timeframe: '1d',
            direction: EvidenceDirection.bullish,
            movePercent: 8,
            strengthScore: 75,
            trendEfficiency: 0.72,
            sampleSize: 90,
          ),
          confirmation: const TimeframeTrendSignal(
            role: TimeframeRole.confirmation,
            timeframe: '1w',
            direction: EvidenceDirection.bullish,
            movePercent: 14,
            strengthScore: 80,
            trendEfficiency: 0.76,
            sampleSize: 78,
          ),
          regime: const TimeframeTrendSignal(
            role: TimeframeRole.regime,
            timeframe: '1mo',
            direction: EvidenceDirection.bearish,
            movePercent: -12,
            strengthScore: 65,
            trendEfficiency: 0.68,
            sampleSize: 60,
          ),
          alignment: TimeframeAlignment.mixed,
          directionScore: 48,
          agreement: 0.65,
          reliability: 0.82,
        ),
        marketContextProfile: analysisContext.marketContextProfile,
        externalContextProfile: analysisContext.externalContextProfile,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AnalysisContextCard(
                strategy: StrategyType.swing,
                analysisContext: swingContext,
                timeframePlan: StrategyTimeframePlan.swing,
                availablePrimaryTimeframes:
                    StrategyTimeframePlan.swingPrimaryTimeframes,
                onPrimaryTimeframeSelected: null,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Swing Analysis Context'), findsOneWidget);
      expect(find.text('Confirmation Interval'), findsOneWidget);
      expect(find.textContaining('1-week candles • Bullish'), findsOneWidget);
      expect(find.text('Broader Regime Interval'), findsOneWidget);
      expect(find.textContaining('1-month candles • Bearish'), findsOneWidget);

      expect(find.byTooltip('About Confirmation Interval'), findsOneWidget);
      expect(find.byTooltip('About Broader Regime Interval'), findsOneWidget);

      await tester.tap(find.byTooltip('About Confirmation Interval'));
      await tester.pumpAndSettle();

      expect(find.text('About Confirmation Interval'), findsOneWidget);
      expect(find.text('Context / configuration'), findsOneWidget);
      expect(find.textContaining('cannot independently flip'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('About Timeframe Alignment'));
      await tester.pumpAndSettle();

      expect(find.text('About Timeframe Alignment'), findsOneWidget);
      expect(find.text('Directional / evaluative'), findsOneWidget);
      expect(find.textContaining('60%'), findsOneWidget);
      expect(
        find.textContaining('not percentages of the final recommendation'),
        findsOneWidget,
      );
    },
  );
}
