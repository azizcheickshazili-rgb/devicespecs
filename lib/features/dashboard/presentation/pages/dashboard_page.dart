import 'package:flutter/material.dart';

import '../theme/dashboard_colors.dart';
import '../view_models/dashboard_view_model.dart';
import '../widgets/battery_card.dart';
import '../widgets/cpu_card.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/device_summary_card.dart';
import '../widgets/diagnostic_controls.dart';
import '../widgets/memory_card.dart';
import '../widgets/network_card.dart';
import '../widgets/storage_card.dart';

/// Écran principal après authentification : vue synthétique de l'appareil,
/// fidèle à la maquette "tableau_de_bord_santé_système_mode_sombre".
class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    this.profileImageUrl,
    this.onViewSystemInfo,
    this.onOpenProfile,
    this.onQuickScan,
    this.onSensorTest,
  });

  final String? profileImageUrl;
  final VoidCallback? onViewSystemInfo;
  final VoidCallback? onOpenProfile;
  final VoidCallback? onQuickScan;
  final VoidCallback? onSensorTest;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late final DashboardViewModel _viewModel;
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _viewModel.loadDashboard().then((_) {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Animation<double> _staggered(int index, int total) {
    final start = index / total * 0.6;
    final end = start + 0.4;
    return CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  Widget _animatedItem(int index, int total, Widget child) {
    final animation = _staggered(index, total);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  Future<void> _handleRefresh() async {
    _entranceController.reset();
    await _viewModel.refresh();
    if (mounted) _entranceController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _DashboardHeader(profileImageUrl: widget.profileImageUrl),
            Expanded(
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  if (_viewModel.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  if (_viewModel.errorMessage != null) {
                    return _ErrorState(
                      message: _viewModel.errorMessage!,
                      onRetry: _handleRefresh,
                    );
                  }

                  const totalItems = 6;
                  return RefreshIndicator(
                    color: Colors.black,
                    backgroundColor: Colors.white,
                    onRefresh: _handleRefresh,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      children: [
                        _animatedItem(
                          0,
                          totalItems,
                          DeviceSummaryCard(
                            deviceInfo: _viewModel.deviceInfo,
                            statusLabel: _viewModel.batteryStatusLabel,
                            batteryLevel:
                                _viewModel.batteryInfo['level'] as int? ?? -1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _animatedItem(
                          1,
                          totalItems,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: BatteryCard(
                                  batteryInfo: _viewModel.batteryInfo,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: MemoryCard(
                                  memoryInfo: _viewModel.memoryInfo,
                                  usageRatio: _viewModel.memoryUsageRatio,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _animatedItem(
                          2,
                          totalItems,
                          StorageCard(
                            storageInfo: _viewModel.storageInfo,
                            usageRatio: _viewModel.storageUsageRatio,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _animatedItem(
                          3,
                          totalItems,
                          CpuCard(
                            cpuInfo: _viewModel.cpuInfo,
                            loadHistory: _viewModel.cpuLoadHistory,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _animatedItem(
                          4,
                          totalItems,
                          NetworkCard(networkInfo: _viewModel.networkInfo),
                        ),
                        const SizedBox(height: 20),
                        _animatedItem(
                          5,
                          totalItems,
                          DiagnosticControls(
                            onQuickScan: widget.onQuickScan ?? _handleRefresh,
                            onSensorTest: widget.onSensorTest ?? () {},
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            DashboardBottomNav(
              onSpecsTap: widget.onViewSystemInfo,
              onProfileTap: widget.onOpenProfile,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({this.profileImageUrl});

  final String? profileImageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: DashboardColors.background.withOpacity(0.9),
        border: const Border(
          bottom: BorderSide(color: DashboardColors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.smartphone, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DeviceSpecs',
                    style: DashboardText.headlineMd().copyWith(fontSize: 16),
                  ),
                  Text('TABLEAU DE BORD', style: DashboardText.labelDataSm()),
                ],
              ),
            ],
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: DashboardColors.border),
            ),
            child: ClipOval(
              child: profileImageUrl != null
                  ? Image.network(profileImageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: DashboardColors.chipBackground,
                      child: const Icon(
                        Icons.person,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
