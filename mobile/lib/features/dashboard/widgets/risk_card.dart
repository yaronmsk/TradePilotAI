import 'package:flutter/material.dart';
import '../../../shared/widgets/dashboard_card.dart';

class RiskCard extends StatelessWidget {
  const RiskCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardCard(
      title: "Risk",
      child: Text("No analysis available."),
    );
  }
}