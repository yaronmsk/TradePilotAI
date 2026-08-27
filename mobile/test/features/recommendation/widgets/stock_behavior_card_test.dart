import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/context/stock_behavior_profile.dart';
import 'package:mobile/features/recommendation/widgets/stock_behavior_card.dart';

void main() {
  const profile = StockBehaviorProfile(
    behaviorType: StockBehaviorType.volatile,
    volatilityRegime: VolatilityRegime.elevated,
    averageVolume: 1000000,
    relativeVolume: 1.7,
    atrPercent: 1.4,
    baselineAtrPercent: 1.0,
    volatilityRatio: 1.4,
    trendEfficiency: 0.72,
    sampleSize: 48,
    baselineSource: StockBaselineSource.oneYearDailyHistory,
    historicalSampleSize: 252,
    typicalDailyAtrPercent: 3.4,
    recentRealizedVolatilityPercent: 62,
    typicalRealizedVolatilityPercent: 48,
    volatilityPercentile: 86,
    averageDailyVolume20: 1200000,
    averageDailyVolume60: 1000000,
    volumeTrendRatio: 1.2,
    volumeVariability: 0.65,
    historicalTrendEfficiency20: 0.55,
    historicalTrendEfficiency60: 0.48,
  );

  testWidgets('presents historical stock context in user-friendly language', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: StockBehaviorCard(profile: profile),
          ),
        ),
      ),
    );

    expect(find.text('Stock DNA'), findsOneWidget);
    expect(find.text('Stock Type'), findsOneWidget);
    expect(find.text('Volatile'), findsOneWidget);
    expect(find.text('Typical Daily Range'), findsOneWidget);
    expect(find.text('How TradePilot uses this'), findsOneWidget);
  });

  testWidgets('explains Stock DNA from the info button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StockBehaviorCard(profile: profile)),
      ),
    );

    await tester.tap(find.byTooltip('About Stock DNA'));
    await tester.pumpAndSettle();

    expect(find.text('What is Stock DNA?'), findsOneWidget);
    expect(
      find.textContaining('does not create a Buy or Sell signal by itself'),
      findsOneWidget,
    );
  });

  testWidgets('every visible Stock DNA metric has its own info path', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: StockBehaviorCard(profile: profile),
          ),
        ),
      ),
    );

    expect(find.byTooltip('About Stock Type'), findsOneWidget);
    expect(find.byTooltip('About Volatility Now'), findsOneWidget);
    expect(find.byTooltip('About Typical Daily Range'), findsOneWidget);
    expect(find.byTooltip('About Volume Pattern'), findsOneWidget);
  });

  testWidgets('Stock Type info explains its non-directional role', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: StockBehaviorCard(profile: profile),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('About Stock Type'));
    await tester.pumpAndSettle();

    expect(find.text('About Stock Type'), findsOneWidget);
    expect(
      find.textContaining('does not create or flip Buy/Sell direction'),
      findsOneWidget,
    );
  });
}
