enum TradePilotRuntimeMode { synthetic, live }

class TradePilotRuntimeConfig {
  final TradePilotRuntimeMode mode;
  final Uri? gatewayBaseUri;

  const TradePilotRuntimeConfig({
    required this.mode,
    required this.gatewayBaseUri,
  });

  static TradePilotRuntimeConfig fromEnvironment() {
    const modeValue = String.fromEnvironment(
      'TRADEPILOT_DATA_MODE',
      defaultValue: 'synthetic',
    );
    const gatewayValue = String.fromEnvironment('TRADEPILOT_GATEWAY_URL');

    final mode = switch (modeValue.trim().toLowerCase()) {
      'synthetic' => TradePilotRuntimeMode.synthetic,
      'live' => TradePilotRuntimeMode.live,
      _ => throw StateError(
        'TRADEPILOT_DATA_MODE must be either synthetic or live.',
      ),
    };

    final gatewayBaseUri = gatewayValue.trim().isEmpty
        ? null
        : Uri.tryParse(gatewayValue.trim());

    if (gatewayBaseUri != null &&
        (!gatewayBaseUri.hasScheme || gatewayBaseUri.host.isEmpty)) {
      throw StateError('TRADEPILOT_GATEWAY_URL must be an absolute URL.');
    }

    if (mode == TradePilotRuntimeMode.live && gatewayBaseUri == null) {
      throw StateError(
        'Live mode requires TRADEPILOT_GATEWAY_URL. '
        'Provider secrets must not be embedded in the app.',
      );
    }

    return TradePilotRuntimeConfig(mode: mode, gatewayBaseUri: gatewayBaseUri);
  }
}
