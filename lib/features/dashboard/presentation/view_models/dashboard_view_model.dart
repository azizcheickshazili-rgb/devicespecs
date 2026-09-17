import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../services/native/battery_platform_service.dart';
import '../../../../services/native/device_platform_service.dart';
import '../../../../services/native/storage_platform_service.dart';
import '../../../../services/native/system_platform_service.dart';

/// État exposé par le Dashboard à la vue.
///
/// Basé sur [ChangeNotifier] (pas de dépendance externe de state
/// management) : la page l'écoute via [ListenableBuilder].
class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel({
    DevicePlatformService? deviceService,
    BatteryPlatformService? batteryService,
    StoragePlatformService? storageService,
    SystemPlatformService? systemService,
  }) : _deviceService = deviceService ?? DevicePlatformService(),
       _batteryService = batteryService ?? BatteryPlatformService(),
       _storageService = storageService ?? StoragePlatformService(),
       _systemService = systemService ?? SystemPlatformService();

  final DevicePlatformService _deviceService;
  final BatteryPlatformService _batteryService;
  final StoragePlatformService _storageService;
  final SystemPlatformService _systemService;

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
        _deviceService.getDeviceInfo(),
        _batteryService.getBatteryInfo(),
        _systemService.getMemoryInfo(),
        _storageService.getStorageInfo(),
        _systemService.getCpuInfo(),
        _systemService.getNetworkInfo(),
      ]);

      deviceInfo = results[0];
      batteryInfo = results[1];
      memoryInfo = results[2];
      storageInfo = results[3];
      cpuInfo = results[4];
      networkInfo = results[5];

      _pushCpuSample(cpuInfo['loadPercent'] as double? ?? -1);
      _startTelemetry();
    } catch (e) {
      errorMessage = 'Impossible de récupérer les informations système.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Rafraîchit périodiquement uniquement la charge CPU pour alimenter la
  /// sparkline "TÉLÉMÉTRIE EN DIRECT (1s)", sans recharger toute la page.
  void _startTelemetry() {
    _telemetryTimer?.cancel();
    _telemetryTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final latest = await _systemService.getCpuInfo();
      cpuInfo = latest;
      _pushCpuSample(latest['loadPercent'] as double? ?? -1);
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
