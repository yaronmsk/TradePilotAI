import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/recommendation/models/evidence_definition.dart';

void main() {
  test('stores evidence definition information', () {
    const definition = EvidenceDefinition(
      name: 'Candle Trend',
      description: 'Measures recent price direction.',
      whyItMatters: 'Price trends often indicate market momentum.',
      calculation: 'Percentage change between the first and last candle.',
    );

    expect(definition.name, 'Candle Trend');
    expect(definition.description, 'Measures recent price direction.');
    expect(
      definition.whyItMatters,
      'Price trends often indicate market momentum.',
    );
    expect(
      definition.calculation,
      'Percentage change between the first and last candle.',
    );
  });
}
