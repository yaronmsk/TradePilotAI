import 'package:flutter/material.dart';

import '../recommendation/models/recommendation.dart';
import '../recommendation/widgets/recommendation_card.dart';
import 'widgets/historical_evidence_card.dart';
import 'widgets/market_status_card.dart';
import 'widgets/risk_card.dart';
import 'widgets/watchlist_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TradePilot AI'),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            const MarketStatusCard(),
            RecommendationCard(
              recommendation: Recommendation.empty(),
            ),
            const HistoricalEvidenceCard(),
            const RiskCard(),
            const WatchlistCard(),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Version 0.2',
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