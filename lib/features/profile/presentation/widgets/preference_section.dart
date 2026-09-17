import 'package:flutter/material.dart';

import '../../../dashboard/presentation/theme/dashboard_colors.dart';

/// Bloc de section réutilisé par les 3 groupes de préférences de la page
/// Profil : en-tête (icône + titre en majuscules) puis carte contenant
/// [children] séparés verticalement.
class PreferenceSection extends StatelessWidget {
  const PreferenceSection({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: DashboardColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              title,
              style: DashboardText.labelDataSm().copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: DashboardColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DashboardColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}
