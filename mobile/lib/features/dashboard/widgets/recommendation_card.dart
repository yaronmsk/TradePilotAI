import 'package:flutter/material.dart';
import 'dashboard_card.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardCard(
      title: "Recommendation",
      child: Text("Waiting for analysis..."),
    );
  }
}