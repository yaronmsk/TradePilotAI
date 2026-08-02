import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/providers/candle_trend_evidence_provider.dart';
import 'package:mobile/features/recommendation/providers/evidence_provider.dart';

void main() {
  test('CandleTrendEvidenceProvider implements EvidenceProvider', () {
    const EvidenceProvider provider = CandleTrendEvidenceProvider();

    expect(provider.name, 'Candle Trend');
  });
}
