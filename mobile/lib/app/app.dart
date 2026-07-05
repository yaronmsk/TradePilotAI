import 'package:flutter/material.dart';

import '../features/dashboard/dashboard_page.dart';
import 'theme.dart';

class TradePilotApp extends StatelessWidget {
  const TradePilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradePilot AI',
      debugShowCheckedModeBanner: false,
      theme: buildTradePilotTheme(),
      home: const DashboardPage(),
    );
  }
}