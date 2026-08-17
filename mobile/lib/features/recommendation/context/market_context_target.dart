class MarketContextTarget {
  const MarketContextTarget({
    required this.marketSymbol,
    required this.sectorSymbol,
    required this.sectorName,
    required this.hasSectorBenchmark,
  });

  final String marketSymbol;
  final String sectorSymbol;
  final String sectorName;
  final bool hasSectorBenchmark;
}
