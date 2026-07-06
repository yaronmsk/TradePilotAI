import 'package:flutter/material.dart';
import 'dashboard_card.dart';

class WatchlistCard extends StatelessWidget {
  const WatchlistCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardCard(
      title: "Watchlist",
      child: Text("No stocks added."),
    );
  }
}