import 'package:flutter/material.dart';

import '../models/market_history_range.dart';

class MarketHistoryRangeSelector extends StatelessWidget {
  const MarketHistoryRangeSelector({
    required this.selectedRange,
    required this.onSelected,
    super.key,
  });

  final MarketHistoryRange selectedRange;
  final ValueChanged<MarketHistoryRange> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: MarketHistoryRange.values
          .map((range) {
            return ChoiceChip(
              label: Text(range.label),
              selected: range == selectedRange,
              onSelected: (_) {
                onSelected(range);
              },
            );
          })
          .toList(growable: false),
    );
  }
}
