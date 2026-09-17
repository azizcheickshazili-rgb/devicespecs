import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'features/auth/presentation/pages/auth_page.dart';

void main() {
  runApp(const DeviceSpecsApp());
}

class DeviceSpecsApp extends StatelessWidget {
  const DeviceSpecsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeviceSpecs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFF121212),
        fontFamily: 'Roboto',
      ),
      home: const AuthPage(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // Le MethodChannel : le "pont" entre Dart et le code natif Kotlin.
  // Le nom du channel doit être IDENTIQUE des deux côtés (Dart et Kotlin).
  static const platform = MethodChannel('com.groupe20.devicespecs/system');

  Map<String, dynamic>? _deviceData;
  String? _error;
  bool _loading = true;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _fetchDeviceInfo();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchDeviceInfo() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Appel de la méthode native "getDeviceInfo" définie côté Kotlin
      final result = await platform.invokeMethod('getDeviceInfo');
      setState(() {
        _deviceData = Map<String, dynamic>.from(result as Map);
        _loading = false;
      });
      _controller.forward(from: 0);
    } on PlatformException catch (e) {
      setState(() {
        _error = "Erreur native : ${e.message}";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DeviceSpecs'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDeviceInfo,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
        ),
      );
    }

    final data = _deviceData ?? {};

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoCard(
            icon: Icons.smartphone,
            title: 'Appareil',
            rows: {
              'Marque': data['brand'] ?? '—',
              'Modèle': data['model'] ?? '—',
              'Fabricant': data['manufacturer'] ?? '—',
            },
          ),
          _InfoCard(
            icon: Icons.android,
            title: 'Système',
            rows: {
              'Version Android': data['androidVersion'] ?? '—',
              'SDK': data['sdkInt']?.toString() ?? '—',
            },
          ),
          _UsageCard(
            icon: Icons.memory,
            title: 'Mémoire (RAM)',
            used: (data['totalRam'] ?? 0) - (data['availableRam'] ?? 0),
            total: data['totalRam'] ?? 1,
            unit: 'MB',
          ),
          _UsageCard(
            icon: Icons.storage,
            title: 'Stockage',
            used: (data['totalStorage'] ?? 0) - (data['availableStorage'] ?? 0),
            total: data['totalStorage'] ?? 1,
            unit: 'MB',
          ),
          _UsageCard(
            icon: Icons.battery_full,
            title: 'Batterie',
            used: (data['batteryLevel'] ?? 0).toDouble(),
            total: 100,
            unit: '%',
            isPercentDirect: true,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Map<String, dynamic> rows;

  const _InfoCard({required this.icon, required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.indigoAccent),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 20),
            ...rows.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: const TextStyle(color: Colors.white70)),
                    Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final num used;
  final num total;
  final String unit;
  final bool isPercentDirect;

  const _UsageCard({
    required this.icon,
    required this.title,
    required this.used,
    required this.total,
    required this.unit,
    this.isPercentDirect = false,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio = isPercentDirect
        ? (used / 100).clamp(0.0, 1.0)
        : (total == 0 ? 0.0 : (used / total).clamp(0.0, 1.0));

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.indigoAccent),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(
                  isPercentDirect
                      ? '${used.toStringAsFixed(0)} $unit'
                      : '${used.toStringAsFixed(0)} / ${total.toStringAsFixed(0)} $unit',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    value > 0.85 ? Colors.redAccent : Colors.indigoAccent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
