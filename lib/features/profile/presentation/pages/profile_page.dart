import 'package:flutter/material.dart';

import '../../../auth/presentation/pages/auth_page.dart';
import '../../../dashboard/presentation/theme/dashboard_colors.dart';
import '../widgets/preference_section.dart';
import '../widgets/segmented_choice.dart';
import '../widgets/settings_toggle_row.dart';

/// Page Profil / Préférences — fidèle à la maquette
/// "profil_préférences_mode_sombre" (même thème que le Dashboard).
///
/// Note : le projet n'a pas de backend de comptes utilisateurs. Les
/// informations de profil (nom, rôle) sont donc génériques par défaut —
/// pas de statistiques ni de version inventées comme dans la maquette
/// ("1 420 diagnostics", "v2.4.1"...).
class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    this.userName,
    this.userRole,
    this.onLogout,
  });

  final String? userName;
  final String? userRole;
  final VoidCallback? onLogout;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _themeModeIndex = 0; // Sombre / Clair / Système
  int _refreshRateIndex = 0; // 1s / 5s / Manuel
  int _exportFormatIndex = 0; // PDF / JSON / TXT
  bool _highPrecisionGauges = true;
  bool _autoSaveLogs = true;
  bool _celsius = true;

  void _handleLogout() {
    if (widget.onLogout != null) {
      widget.onLogout!.call();
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardColors.background,
      appBar: AppBar(
        backgroundColor: DashboardColors.background,
        elevation: 0,
        title: Text('Profil', style: DashboardText.headlineMd()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildUserCard(),
          const SizedBox(height: 20),
          PreferenceSection(
            icon: Icons.tune,
            title: 'PRÉFÉRENCES DE L\'APPLICATION',
            children: [
              Text('Mode du thème', style: DashboardText.body(
                color: DashboardColors.textPrimary,
              ).copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              SegmentedChoice(
                options: const ['Sombre', 'Clair', 'Système'],
                icons: const [
                  Icons.dark_mode,
                  Icons.light_mode,
                  Icons.settings_suggest,
                ],
                selectedIndex: _themeModeIndex,
                onChanged: (i) => setState(() => _themeModeIndex = i),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fréquence de rafraîchissement',
                    style: DashboardText.body(
                      color: DashboardColors.textPrimary,
                    ).copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    _refreshRateIndex == 0
                        ? 'Actif : 1000ms'
                        : _refreshRateIndex == 1
                        ? 'Actif : 5000ms'
                        : 'Manuel',
                    style: DashboardText.labelDataSm(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Intervalle d'interrogation des capteurs télémétriques",
                style: DashboardText.body(),
              ),
              const SizedBox(height: 6),
              SegmentedChoice(
                options: const ['1s', '5s', 'Manuel'],
                selectedIndex: _refreshRateIndex,
                onChanged: (i) => setState(() => _refreshRateIndex = i),
              ),
              const Divider(height: 28, color: DashboardColors.border),
              SettingsToggleRow(
                title: 'Jauges haute précision',
                subtitle:
                    'Transitions fines et rafraîchissement rapide des anneaux',
                value: _highPrecisionGauges,
                onChanged: (v) => setState(() => _highPrecisionGauges = v),
              ),
              const Divider(height: 28, color: DashboardColors.border),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Unité thermique',
                          style: DashboardText.body(
                            color: DashboardColors.textPrimary,
                          ).copyWith(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Format de température affiché',
                          style: DashboardText.body(),
                        ),
                      ],
                    ),
                  ),
                  SegmentedChoice(
                    options: const ['°C', '°F'],
                    selectedIndex: _celsius ? 0 : 1,
                    onChanged: (i) => setState(() => _celsius = i == 0),
                    compact: true,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          PreferenceSection(
            icon: Icons.dataset_outlined,
            title: 'DONNÉES & EXPORTS',
            children: [
              Text(
                "Format d'export par défaut",
                style: DashboardText.body(
                  color: DashboardColors.textPrimary,
                ).copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              SegmentedChoice(
                options: const ['PDF', 'JSON', 'TXT'],
                selectedIndex: _exportFormatIndex,
                onChanged: (i) => setState(() => _exportFormatIndex = i),
              ),
              const Divider(height: 28, color: DashboardColors.border),
              SettingsToggleRow(
                title: 'Enregistrement auto des logs',
                subtitle: 'Sauvegarde glissante sur le stockage local',
                value: _autoSaveLogs,
                onChanged: (v) => setState(() => _autoSaveLogs = v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PreferenceSection(
            icon: Icons.terminal,
            title: 'SYSTÈME & COMPTE',
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DashboardColors.sparklineBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: DashboardColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Vider le cache de l'application",
                      style: DashboardText.body(
                        color: DashboardColors.textPrimary,
                      ).copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cache purgé.')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: DashboardColors.border),
                      ),
                      child: const Text('Purger'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'DeviceSpecs — Projet Groupe 20',
                style: DashboardText.body(
                  color: DashboardColors.textPrimary,
                ).copyWith(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout, color: Color(0xFFFFB4AB)),
                  label: const Text(
                    'Se déconnecter du profil',
                    style: TextStyle(color: Color(0xFFFFB4AB)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0x8076292A)),
                    backgroundColor: const Color(0x3376292A),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    final name = widget.userName ?? 'Invité';
    final role = widget.userRole ?? 'Rôle non renseigné';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashboardColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: DashboardColors.chipBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DashboardColors.border),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: DashboardText.headlineMd(),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: DashboardText.labelDataSm(),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
