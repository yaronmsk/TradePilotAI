import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/data/data_provenance.dart';

void main() {
  group('DataProvenance', () {
    test('parses live gateway metadata', () {
      final provenance = DataProvenance.fromJson({
        'state': 'LIVE',
        'source': 'Twelve Data via TradePilot Gateway',
        'observedAt': '2026-09-04T20:00:00Z',
        'fetchedAt': '2026-09-05T15:40:00Z',
      });

      expect(provenance.state, DataState.live);
      expect(provenance.isLiveUsable, isTrue);
      expect(provenance.blocksLiveAnalysis, isFalse);
      expect(provenance.isSynthetic, isFalse);
    });

    test('partial live remains usable but stale blocks analysis', () {
      final partial = DataProvenance.fromJson({
        'state': 'PARTIAL_LIVE',
        'source': 'TradePilot Gateway',
        'observedAt': null,
        'fetchedAt': '2026-09-05T15:40:00Z',
      });
      final stale = DataProvenance.fromJson({
        'state': 'STALE',
        'source': 'TradePilot Gateway',
        'observedAt': '2026-09-04T20:00:00Z',
        'fetchedAt': '2026-09-05T15:40:00Z',
      });

      expect(partial.isLiveUsable, isTrue);
      expect(stale.blocksLiveAnalysis, isTrue);
    });

    test('synthetic data can never be treated as live', () {
      const provenance = DataProvenance.synthetic();

      expect(provenance.isSynthetic, isTrue);
      expect(provenance.isLiveUsable, isFalse);
      expect(provenance.blocksLiveAnalysis, isTrue);
      expect(provenance.fetchedAt, isNull);
    });
  });
}
