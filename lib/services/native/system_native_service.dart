import 'package:flutter/services.dart';

/// Unique point d'accès à la couche native (Kotlin), sur le channel
/// "com.groupe20.devicespecs/system" déjà utilisé par le reste du projet.
class SystemNativeService {
  static const MethodChannel _channel = MethodChannel(
    'com.groupe20.devicespecs/system',
  );

  /// Un seul appel natif qui renvoie toutes les infos ponctuelles
  /// (appareil, RAM, stockage, batterie, CPU). Map vide si indisponible —
  /// chaque écran gère ses propres valeurs de repli.
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getDeviceInfo',
      );
      if (result == null) return {};
      return Map<String, dynamic>.from(result);
    } on PlatformException {
      return {};
    } on MissingPluginException {
      return {};
    }
  }

  /// Charge CPU instantanée (0-100), -1 si indisponible. Prévu pour être
  /// interrogé toutes les secondes (télémétrie live de la sparkline).
  Future<double> getCpuLoad() async {
    try {
      final result = await _channel.invokeMethod<num>('getCpuLoad');
      return result?.toDouble() ?? -1.0;
    } on PlatformException {
      return -1.0;
    } on MissingPluginException {
      return -1.0;
    }
  }

  /// Infos réseau (Wi-Fi + latence mesurée). Appel séparé car il ouvre un
  /// socket TCP côté natif (traité en arrière-plan côté Kotlin).
  Future<Map<String, dynamic>> getNetworkInfo() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'getNetworkInfo',
      );
      if (result == null) return _unavailableNetworkInfo();
      return Map<String, dynamic>.from(result);
    } on PlatformException {
      return _unavailableNetworkInfo();
    } on MissingPluginException {
      return _unavailableNetworkInfo();
    }
  }

  Map<String, dynamic> _unavailableNetworkInfo() => {
    'ssid': 'Indisponible',
    'isConnected': false,
    'linkSpeedMbps': -1,
    'ipAddress': 'Indisponible',
    'latencyMs': -1,
  };
}
