import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../services/native/system_native_service.dart';

/// État exposé par le Dashboard à la vue.
///
/// Basé sur [ChangeNotifier] (pas de dépendance externe de state
/// management) : la page l'écoute via [ListenableBuilder]. Toutes les
/// données proviennent d'un seul appel natif getDeviceInfo() (+ un appel
/// séparé pour le réseau, et un polling léger pour la charge CPU).
class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel({SystemNativeService? nativeService})
    : _nativeService = nativeService ?? SystemNativeService();

  final SystemNativeService _nativeService;

  static const int _maxCpuSamples = 14;

  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic> deviceInfo = const {};
  Map<String, dynamic> batteryInfo = const {};
  Map<String, dynamic> memoryInfo = const {};
  Map<String, dynamic> storageInfo = const {};
  Map<String, dynamic> cpuInfo = const {};
  Map<String, dynamic> networkInfo = const {};

  final List<double> cpuLoadHistory = [];

  Timer? _telemetryTimer;

  Future<void> loadDashboard() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _nativeService.getDeviceInfo(),
        _nativeService.getNetworkInfo(),
      ]);

      _applyDeviceInfo(results[0]);
      networkInfo = results[1];

      _startTelemetry();
    } catch (e) {
      errorMessage = 'Impossible de récupérer les informations système.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Répartit le Map plat renvoyé par le natif dans des sous-Maps par
  /// domaine (repris tels quels par les cartes existantes du Dashboard).
  void _applyDeviceInfo(Map<String, dynamic> raw) {
    deviceInfo = {
      'manufacturer': raw['manufacturer'] ?? 'Indisponible',
      'model': raw['model'] ?? 'Indisponible',
      'deviceCodeName': raw['deviceCodeName'] ?? 'Indisponible',
      'osVersion': raw['androidVersion'] ?? 'Indisponible',
      'buildId': raw['buildId'] ?? 'Indisponible',
    };

    batteryInfo = {
      'level': (raw['batteryPercent'] as num?)?.toInt() ?? -1,
      'isCharging': raw['isCharging'] ?? false,
      'chargeState': raw['chargeState'] ?? 'Indisponible',
      'cellHealth': raw['cellHealth'] ?? 'Indisponible',
      'temperatureCelsius':
          (raw['temperatureCelsius'] as num?)?.toDouble() ?? -1.0,
    };

    const mb = 1024 * 1024;
    final totalRamMb = (raw['totalRam'] as num?)?.toInt() ?? 0;
    final usedRamMb = (raw['usedRam'] as num?)?.toInt() ?? 0;
    final availableRamMb = (raw['availableRam'] as num?)?.toInt() ?? 0;
    final swapTotalMb = (raw['swapTotal'] as num?)?.toInt() ?? -1;
    final swapUsedMb = (raw['swapUsed'] as num?)?.toInt() ?? -1;
    memoryInfo = {
      'totalRamBytes': totalRamMb * mb,
      'usedRamBytes': usedRamMb * mb,
      'availableRamBytes': availableRamMb * mb,
      'swapTotalBytes': swapTotalMb >= 0 ? swapTotalMb * mb : -1,
      'swapUsedBytes': swapUsedMb >= 0 ? swapUsedMb * mb : -1,
    };

    final totalStorageMb = (raw['totalStorage'] as num?)?.toInt() ?? 0;
    final availableStorageMb = (raw['availableStorage'] as num?)?.toInt() ?? 0;
    storageInfo = {
      'totalBytes': totalStorageMb * mb,
      'freeBytes': availableStorageMb * mb,
      'usedBytes': (totalStorageMb - availableStorageMb) * mb,
    };

    cpuInfo = {
      'cores': (raw['cpuCores'] as num?)?.toInt() ?? 0,
      'architecture': raw['cpuArchitecture'] ?? 'Indisponible',
      'loadPercent': cpuInfo['loadPercent'] ?? -1.0,
      'clusterFrequenciesGHz':
          (raw['cpuFrequenciesGHz'] as List?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          <double>[],
    };
  }

  /// Rafraîchit périodiquement uniquement la charge CPU pour alimenter la
  /// sparkline "TÉLÉMÉTRIE EN DIRECT (1s)", sans recharger toute la page.
  void _startTelemetry() {
    _telemetryTimer?.cancel();
    _telemetryTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final load = await _nativeService.getCpuLoad();
      cpuInfo = {...cpuInfo, 'loadPercent': load};
      _pushCpuSample(load);
      notifyListeners();
    });
  }

  void _pushCpuSample(double value) {
    if (value < 0) return;
    cpuLoadHistory.add(value);
    if (cpuLoadHistory.length > _maxCpuSamples) {
      cpuLoadHistory.removeAt(0);
    }
  }

  Future<void> refresh() => loadDashboard();

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    super.dispose();
  }

  /// Pourcentage RAM utilisée (0.0 - 1.0), 0 si indisponible.
  double get memoryUsageRatio {
    final total = memoryInfo['totalRamBytes'] as int? ?? 0;
    final used = memoryInfo['usedRamBytes'] as int? ?? 0;
    if (total <= 0) return 0;
    return (used / total).clamp(0.0, 1.0);
  }

  /// Pourcentage stockage utilisé (0.0 - 1.0), 0 si indisponible.
  double get storageUsageRatio {
    final total = storageInfo['totalBytes'] as int? ?? 0;
    final used = storageInfo['usedBytes'] as int? ?? 0;
    if (total <= 0) return 0;
    return (used / total).clamp(0.0, 1.0);
  }

  /// Statut dérivé du niveau de batterie réel (pas de valeur inventée,
  /// simple classification d'un pourcentage mesuré).
  String get batteryStatusLabel {
    final level = batteryInfo['level'] as int? ?? -1;
    if (level < 0) return 'INDISPONIBLE';
    if (level >= 80) return 'OPTIMAL';
    if (level >= 40) return 'CORRECT';
    return 'FAIBLE';
  }
}
