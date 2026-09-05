import '../../../core/data/data_provenance.dart';
import '../models/market_candle.dart';

DataProvenance parseGatewayProvenance(Map<String, dynamic> json) {
  final raw = json['provenance'];
  if (raw is! Map<String, dynamic>) {
    throw const FormatException('Gateway response requires provenance.');
  }

  return DataProvenance.fromJson(raw);
}

void requireUsableLiveProvenance(DataProvenance provenance) {
  if (!provenance.isLiveUsable) {
    throw StateError(
      'Live market analysis blocked by ${provenance.state.wireValue} '
      'data from ${provenance.source}.',
    );
  }
}

List<MarketCandle> parseGatewayCandles(
  Object? rawCandles, {
  required DataProvenance provenance,
}) {
  if (rawCandles is! List || rawCandles.isEmpty) {
    throw const FormatException('Gateway response requires market candles.');
  }

  final candles = rawCandles
      .map((raw) {
        if (raw is! Map<String, dynamic>) {
          throw const FormatException('Every market candle must be an object.');
        }

        return MarketCandle(
          timestamp: _dateTime(raw['timestamp'], 'candle.timestamp'),
          open: _number(raw['open'], 'candle.open'),
          high: _number(raw['high'], 'candle.high'),
          low: _number(raw['low'], 'candle.low'),
          close: _number(raw['close'], 'candle.close'),
          volume: _number(raw['volume'], 'candle.volume'),
          provenance: provenance,
        );
      })
      .toList(growable: false);

  final ordered = [...candles]
    ..sort((left, right) => left.timestamp.compareTo(right.timestamp));

  return List<MarketCandle>.unmodifiable(ordered);
}

String requiredString(Object? value, String field) {
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$field is required');
  }
  return value.trim();
}

double requiredNumber(Object? value, String field) => _number(value, field);

DateTime requiredDateTime(Object? value, String field) =>
    _dateTime(value, field);

double _number(Object? value, String field) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) {
      return parsed;
    }
  }
  throw FormatException('$field must be numeric');
}

DateTime _dateTime(Object? value, String field) {
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$field is required');
  }

  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw FormatException('$field must be an ISO-8601 timestamp');
  }

  return parsed.toUtc();
}
