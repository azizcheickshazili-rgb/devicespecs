import 'package:flutter/material.dart';

import '../../../../services/native/system_native_service.dart';
import '../../../dashboard/presentation/theme/dashboard_colors.dart';
import '../widgets/spec_category_card.dart';

/// Page "Specs" — annuaire de spécifications système en accordéon,
/// fidèle à la maquette "spécifications_du_système_mode_sombre".
///
/// Contrairement à la maquette (qui affichait des valeurs d'exemple
/// fictives comme "Mali-G715 Immortalis" ou "HDR10+"), chaque valeur ici
/// vient soit du même appel natif que le Dashboard, soit de vraies
/// métriques Flutter (MediaQuery pour l'écran), soit de la liste réelle
/// des capteurs matériels (SensorManager). Rien n'est inventé.
class SpecsPage extends StatefulWidget {
  const SpecsPage({super.key});

  @override
  State<SpecsPage> createState() => _SpecsPageState();
}

class _CategoryData {
  _CategoryData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.rows,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<MapEntry<String, String>> rows;
}

class _SpecsPageState extends State<SpecsPage> {
  final _nativeService = SystemNativeService();
  final _searchController = TextEditingController();

  bool _isLoading = true;
  Map<String, dynamic> _deviceInfo = {};
  Map<String, dynamic> _networkInfo = {};
  List<String> _sensors = [];

  String _activeFilter = 'all';
  String _query = '';

  static const _filters = [
    ['all', 'TOUS'],
    ['hardware', 'MATÉRIEL'],
    ['os', 'OS & NOYAU'],
    ['display', 'ÉCRAN'],
    ['sensors', 'CAPTEURS'],
    ['network', 'RÉSEAU'],
    ['battery', 'BATTERIE'],
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      _nativeService.getDeviceInfo(),
      _nativeService.getNetworkInfo(),
      _nativeService.getSensorsList(),
    ]);
    setState(() {
      _deviceInfo = results[0] as Map<String, dynamic>;
      _networkInfo = results[1] as Map<String, dynamic>;
      _sensors = results[2] as List<String>;
      _isLoading = false;
    });
  }

  String _fmtMb(num? mb) => (mb == null || mb < 0) ? 'Indisponible' : '$mb Mo';

  List<_CategoryData> _buildCategories(BuildContext context) {
    final d = _deviceInfo;
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final widthPx = (size.width * mq.devicePixelRatio).round();
    final heightPx = (size.height * mq.devicePixelRatio).round();

    return [
      _CategoryData(
        id: 'hardware',
        title: 'Appareil & CPU',
        subtitle: '${d['manufacturer'] ?? '—'} ${d['model'] ?? ''}',
        icon: Icons.developer_board,
        rows: [
          MapEntry('Fabricant', '${d['manufacturer'] ?? 'Indisponible'}'),
          MapEntry('Modèle', '${d['model'] ?? 'Indisponible'}'),
          MapEntry('Marque', '${d['brand'] ?? 'Indisponible'}'),
          MapEntry(
            'Nom de code appareil',
            '${d['deviceCodeName'] ?? 'Indisponible'}',
          ),
          MapEntry(
            'Architecture CPU',
            '${d['cpuArchitecture'] ?? 'Indisponible'}',
          ),
          MapEntry('Cœurs CPU', '${d['cpuCores'] ?? 'Indisponible'}'),
          MapEntry('RAM totale', _fmtMb(d['totalRam'] as num?)),
          MapEntry('Stockage total', _fmtMb(d['totalStorage'] as num?)),
        ],
      ),
      _CategoryData(
        id: 'os',
        title: 'Système & Noyau',
        subtitle: 'Android ${d['androidVersion'] ?? '—'}',
        icon: Icons.android,
        rows: [
          MapEntry('Version Android', '${d['androidVersion'] ?? 'Indisponible'}'),
          MapEntry('Niveau SDK', '${d['sdkInt'] ?? 'Indisponible'}'),
          MapEntry('Build', '${d['buildId'] ?? 'Indisponible'}'),
        ],
      ),
      _CategoryData(
        id: 'display',
        title: 'Écran',
        subtitle: '$widthPx × $heightPx px',
        icon: Icons.smartphone,
        rows: [
          MapEntry('Résolution', '$widthPx × $heightPx px'),
          MapEntry(
            'Taille logique',
            '${size.width.toStringAsFixed(0)} × ${size.height.toStringAsFixed(0)} dp',
          ),
          MapEntry(
            'Ratio de pixels (DPR)',
            mq.devicePixelRatio.toStringAsFixed(2),
          ),
          MapEntry(
            'Orientation',
            size.width < size.height ? 'Portrait' : 'Paysage',
          ),
        ],
      ),
      _CategoryData(
        id: 'sensors',
        title: 'Capteurs',
        subtitle: _sensors.isEmpty
            ? 'Aucun capteur détecté'
            : '${_sensors.length} capteurs détectés',
        icon: Icons.sensors,
        rows: _sensors.isEmpty
            ? [const MapEntry('Capteurs', 'Indisponible')]
            : _sensors
                  .asMap()
                  .entries
                  .map((e) => MapEntry('Capteur ${e.key + 1}', e.value))
                  .toList(),
      ),
      _CategoryData(
        id: 'network',
        title: 'Réseau',
        subtitle: (_networkInfo['isConnected'] as bool? ?? false)
            ? 'Connecté'
            : 'Déconnecté',
        icon: Icons.wifi,
        rows: [
          MapEntry(
            'État',
            (_networkInfo['isConnected'] as bool? ?? false)
                ? 'Connecté'
                : 'Déconnecté',
          ),
          MapEntry('SSID', '${_networkInfo['ssid'] ?? 'Indisponible'}'),
          MapEntry(
            'Débit de liaison',
            (_networkInfo['linkSpeedMbps'] as int? ?? -1) >= 0
                ? '${_networkInfo['linkSpeedMbps']} Mbps'
                : 'Indisponible',
          ),
          MapEntry(
            'Adresse IP',
            '${_networkInfo['ipAddress'] ?? 'Indisponible'}',
          ),
          MapEntry(
            'Latence passerelle',
            (_networkInfo['latencyMs'] as int? ?? -1) >= 0
                ? '${_networkInfo['latencyMs']} ms'
                : 'Indisponible',
          ),
        ],
      ),
      _CategoryData(
        id: 'battery',
        title: 'Batterie',
        subtitle: '${d['batteryPercent'] ?? '--'}%',
        icon: Icons.battery_full,
        rows: [
          MapEntry('Niveau', '${d['batteryPercent'] ?? 'Indisponible'}%'),
          MapEntry('État de charge', '${d['chargeState'] ?? 'Indisponible'}'),
          MapEntry('Santé cellule', '${d['cellHealth'] ?? 'Indisponible'}'),
          MapEntry(
            'Température',
            (d['temperatureCelsius'] as num? ?? -1) >= 0
                ? '${(d['temperatureCelsius'] as num).toStringAsFixed(0)}°C'
                : 'Indisponible',
          ),
        ],
      ),
    ];
  }

  List<_CategoryData> _applyFilters(List<_CategoryData> categories) {
    return categories
        .where((c) => _activeFilter == 'all' || c.id == _activeFilter)
        .map((c) {
          if (_query.isEmpty) return c;
          final q = _query.toLowerCase();
          final filteredRows = c.rows
              .where(
                (r) =>
                    r.key.toLowerCase().contains(q) ||
                    r.value.toLowerCase().contains(q),
              )
              .toList();
          return _CategoryData(
            id: c.id,
            title: c.title,
            subtitle: c.subtitle,
            icon: c.icon,
            rows: filteredRows,
          );
        })
        .where((c) => _query.isEmpty || c.rows.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.background,
      appBar: AppBar(
        backgroundColor: DashboardColors.background,
        elevation: 0,
        title: Text('Specs', style: DashboardText.headlineMd()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _load,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : Builder(
              builder: (context) {
                final categories = _applyFilters(_buildCategories(context));
                final totalParams = _buildCategories(
                  context,
                ).fold<int>(0, (sum, c) => sum + c.rows.length);

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      style: DashboardText.body(
                        color: DashboardColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Rechercher des spécifications (ex. RAM, Wi-Fi, écran)…',
                        hintStyle: DashboardText.body(),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: DashboardColors.textMuted,
                        ),
                        filled: true,
                        fillColor: DashboardColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: DashboardColors.border,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: DashboardColors.border,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final id = _filters[i][0];
                          final label = _filters[i][1];
                          final selected = _activeFilter == id;
                          return GestureDetector(
                            onTap: () => setState(() => _activeFilter = id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.white
                                    : DashboardColors.surface,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: DashboardColors.border,
                                ),
                              ),
                              child: Text(
                                label,
                                style: DashboardText.labelDataSm(
                                  color: selected
                                      ? Colors.black
                                      : DashboardColors.textMuted,
                                ).copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: DashboardColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: DashboardColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$totalParams paramètres indexés',
                                    style: DashboardText.labelDataMd(),
                                  ),
                                  Text(
                                    'DONNÉES NATIVES ACTIVES',
                                    style: DashboardText.labelDataSm(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...categories.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SpecCategoryCard(
                          icon: c.icon,
                          title: c.title,
                          subtitle: c.subtitle,
                          rows: c.rows,
                          initiallyExpanded: categories.length <= 2,
                        ),
                      ),
                    ),
                    if (categories.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Center(
                          child: Text(
                            'Aucun résultat pour cette recherche.',
                            style: DashboardText.body(),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}
