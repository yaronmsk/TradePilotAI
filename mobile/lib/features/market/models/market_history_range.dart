enum MarketHistoryRange { oneDay, fiveDays, oneMonth, threeMonths, oneYear }

extension MarketHistoryRangePresentation on MarketHistoryRange {
  String get label {
    switch (this) {
      case MarketHistoryRange.oneDay:
        return '1D';
      case MarketHistoryRange.fiveDays:
        return '5D';
      case MarketHistoryRange.oneMonth:
        return '1M';
      case MarketHistoryRange.threeMonths:
        return '3M';
      case MarketHistoryRange.oneYear:
        return '1Y';
    }
  }

  int get pointCount {
    switch (this) {
      case MarketHistoryRange.oneDay:
        return 78;
      case MarketHistoryRange.fiveDays:
        return 130;
      case MarketHistoryRange.oneMonth:
        return 30;
      case MarketHistoryRange.threeMonths:
        return 90;
      case MarketHistoryRange.oneYear:
        return 252;
    }
  }

  Duration get interval {
    switch (this) {
      case MarketHistoryRange.oneDay:
        return const Duration(minutes: 5);
      case MarketHistoryRange.fiveDays:
        return const Duration(minutes: 30);
      case MarketHistoryRange.oneMonth:
      case MarketHistoryRange.threeMonths:
      case MarketHistoryRange.oneYear:
        return const Duration(days: 1);
    }
  }
}
