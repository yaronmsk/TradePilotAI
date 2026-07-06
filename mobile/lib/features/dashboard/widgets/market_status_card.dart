import 'package:flutter/material.dart';
import 'dashboard_card.dart';

class MarketStatusCard extends StatelessWidget {
  const MarketStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardCard(
      title: "Market Status",
      child: Row(
        children: [
          Icon(Icons.circle, color: Colors.green, size: 14),
          SizedBox(width: 8),
          Text("Connected"),
        ],
      ),
    );
  }
}