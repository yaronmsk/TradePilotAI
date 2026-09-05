import 'dart:convert';

import 'package:http/http.dart' as http;

abstract interface class TradePilotGatewayClient {
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String> queryParameters = const {},
  });
}

class TradePilotGatewayException implements Exception {
  final String message;
  final int? statusCode;
  final Duration? retryAfter;

  const TradePilotGatewayException(
    this.message, {
    this.statusCode,
    this.retryAfter,
  });

  @override
  String toString() => 'TradePilotGatewayException: $message';
}

class HttpTradePilotGatewayClient implements TradePilotGatewayClient {
  final Uri baseUri;
  final http.Client _httpClient;

  HttpTradePilotGatewayClient({required this.baseUri, http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client() {
    if (!baseUri.hasScheme || baseUri.host.isEmpty) {
      throw ArgumentError.value(
        baseUri,
        'baseUri',
        'Gateway base URI must be absolute.',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String> queryParameters = const {},
  }) async {
    final uri = _buildUri(path, queryParameters);

    http.Response response;
    try {
      response = await _httpClient.get(
        uri,
        headers: const {'Accept': 'application/json'},
      );
    } on Exception catch (error) {
      throw TradePilotGatewayException(
        'Unable to reach TradePilot Data Gateway: $error',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TradePilotGatewayException(
        _errorMessage(response),
        statusCode: response.statusCode,
        retryAfter: _retryAfter(response.headers['retry-after']),
      );
    }

    Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException catch (error) {
      throw TradePilotGatewayException(
        'Gateway returned invalid JSON: $error',
        statusCode: response.statusCode,
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw TradePilotGatewayException(
        'Gateway response must be a JSON object.',
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }

  Uri _buildUri(String path, Map<String, String> queryParameters) {
    final normalizedBasePath = baseUri.path.endsWith('/')
        ? baseUri.path.substring(0, baseUri.path.length - 1)
        : baseUri.path;
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    return baseUri.replace(
      path: '$normalizedBasePath$normalizedPath',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
  }

  static String _errorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
    } on FormatException {
      // Fall through to a generic HTTP status message.
    }

    return 'TradePilot Data Gateway returned HTTP ${response.statusCode}.';
  }

  static Duration? _retryAfter(String? value) {
    if (value == null) {
      return null;
    }

    final seconds = int.tryParse(value.trim());
    if (seconds == null || seconds < 0) {
      return null;
    }

    return Duration(seconds: seconds);
  }

  void close() {
    _httpClient.close();
  }
}
