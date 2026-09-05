enum DataState {
  live,
  partialLive,
  stale,
  dataError,
  synthetic;

  static DataState fromWireValue(String value) {
    switch (value.trim().toLowerCase()) {
      case 'live':
        return DataState.live;
      case 'partial_live':
      case 'partial-live':
      case 'partiallive':
        return DataState.partialLive;
      case 'stale':
        return DataState.stale;
      case 'data_error':
      case 'data-error':
      case 'dataerror':
        return DataState.dataError;
      case 'synthetic':
        return DataState.synthetic;
      default:
        throw FormatException('Unsupported data state: $value');
    }
  }

  String get wireValue {
    switch (this) {
      case DataState.live:
        return 'LIVE';
      case DataState.partialLive:
        return 'PARTIAL_LIVE';
      case DataState.stale:
        return 'STALE';
      case DataState.dataError:
        return 'DATA_ERROR';
      case DataState.synthetic:
        return 'SYNTHETIC';
    }
  }
}

class DataProvenance {
  final DataState state;
  final String source;
  final DateTime? observedAt;
  final DateTime? fetchedAt;
  final String? detail;

  const DataProvenance({
    required this.state,
    required this.source,
    required this.observedAt,
    required this.fetchedAt,
    this.detail,
  });

  const DataProvenance.synthetic()
    : state = DataState.synthetic,
      source = 'TradePilot deterministic development data',
      observedAt = null,
      fetchedAt = null,
      detail = null;

  bool get isLiveUsable =>
      state == DataState.live || state == DataState.partialLive;

  bool get isSynthetic => state == DataState.synthetic;

  bool get blocksLiveAnalysis =>
      state == DataState.stale ||
      state == DataState.dataError ||
      state == DataState.synthetic;

  factory DataProvenance.fromJson(Map<String, dynamic> json) {
    final stateValue = json['state'];
    final sourceValue = json['source'];
    final fetchedAtValue = json['fetchedAt'];

    if (stateValue is! String || stateValue.trim().isEmpty) {
      throw const FormatException('provenance.state is required');
    }
    if (sourceValue is! String || sourceValue.trim().isEmpty) {
      throw const FormatException('provenance.source is required');
    }
    if (fetchedAtValue is! String || fetchedAtValue.trim().isEmpty) {
      throw const FormatException('provenance.fetchedAt is required');
    }

    return DataProvenance(
      state: DataState.fromWireValue(stateValue),
      source: sourceValue.trim(),
      observedAt: _optionalDateTime(
        json['observedAt'],
        'provenance.observedAt',
      ),
      fetchedAt: _requiredDateTime(fetchedAtValue, 'provenance.fetchedAt'),
      detail: switch (json['detail']) {
        final String value when value.trim().isNotEmpty => value.trim(),
        _ => null,
      },
    );
  }

  static DateTime _requiredDateTime(Object? value, String field) {
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$field is required');
    }

    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw FormatException('$field is not a valid ISO-8601 timestamp');
    }

    return parsed.toUtc();
  }

  static DateTime? _optionalDateTime(Object? value, String field) {
    if (value == null) {
      return null;
    }
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$field must be null or an ISO-8601 timestamp');
    }

    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw FormatException('$field is not a valid ISO-8601 timestamp');
    }

    return parsed.toUtc();
  }
}
