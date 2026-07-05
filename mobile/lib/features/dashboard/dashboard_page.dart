import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TradePilot AI"),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              Icons.show_chart,
              size: 72,
            ),

            SizedBox(height: 20),

            Text(
              "Welcome to TradePilot AI",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 12),

            Text(
              "Sprint 2 - Application Shell",
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 30),

            Text(
              "Version 0.1",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}