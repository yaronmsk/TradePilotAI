import 'package:flutter/material.dart';

import 'widgets/historical_evidence_card.dart';
import 'widgets/market_status_card.dart';
import 'widgets/recommendation_card.dart';
import 'widgets/risk_card.dart';
import 'widgets/watchlist_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TradePilot AI"),
      ),
      body: const SafeArea(
        child: ListView(
          children: [
            MarketStatusCard(),
            RecommendationCard(),
            HistoricalEvidenceCard(),
            RiskCard(),
            WatchlistCard(),
            SizedBox(height: 20),
            Center(
              child: Text(
                "Version 0.2",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}