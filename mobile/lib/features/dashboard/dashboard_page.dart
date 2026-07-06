import 'package:flutter/material.dart';

import 'widgets/dashboard_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TradePilot AI"),
      ),
      body: SafeArea(
        child: ListView(
          children: const [

            DashboardCard(
              title: "Market Status",
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: Colors.green,
                    size: 14,
                  ),
                  SizedBox(width: 8),
                  Text("Connected"),
                ],
              ),
            ),

            DashboardCard(
              title: "Recommendation",
              child: Text(
                "Waiting for analysis...",
              ),
            ),

            DashboardCard(
              title: "Historical Evidence",
              child: Text(
                "No analysis available.",
              ),
            ),

            DashboardCard(
              title: "Risk",
              child: Text(
                "No analysis available.",
              ),
            ),

            DashboardCard(
              title: "Watchlist",
              child: Text(
                "No stocks added.",
              ),
            ),

            SizedBox(height: 20),

            Center(
              child: Text(
                "Version 0.2",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}