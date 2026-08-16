class WatchlistItem {
  const WatchlistItem({
    required this.symbol,
    required this.displayName,
    this.isNotificationsEnabled = false,
  });

  final String symbol;
  final String displayName;
  final bool isNotificationsEnabled;

  WatchlistItem copyWith({
    String? symbol,
    String? displayName,
    bool? isNotificationsEnabled,
  }) {
    return WatchlistItem(
      symbol: symbol ?? this.symbol,
      displayName: displayName ?? this.displayName,
      isNotificationsEnabled:
          isNotificationsEnabled ?? this.isNotificationsEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'displayName': displayName,
      'isNotificationsEnabled': isNotificationsEnabled,
    };
  }

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    return WatchlistItem(
      symbol: json['symbol'] as String,
      displayName: json['displayName'] as String,
      isNotificationsEnabled: json['isNotificationsEnabled'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is WatchlistItem &&
            symbol == other.symbol &&
            displayName == other.displayName &&
            isNotificationsEnabled == other.isNotificationsEnabled;
  }

  @override
  int get hashCode => Object.hash(symbol, displayName, isNotificationsEnabled);
}
