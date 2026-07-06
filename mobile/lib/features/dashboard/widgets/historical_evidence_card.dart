import 'package:flutter/material.dart';
import 'dashboard_card.dart';

class HistoricalEvidenceCard extends StatelessWidget {
  const HistoricalEvidenceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardCard(
      title: "Historical Evidence",
      child: Text("No analysis available."),
    );
  }
}