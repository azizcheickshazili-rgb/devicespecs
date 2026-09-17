import 'package:flutter/material.dart';

import '../../../dashboard/presentation/theme/dashboard_colors.dart';
import 'spec_row.dart';

/// Carte accordéon d'une catégorie (ex. "Appareil", "Écran") : en-tête
/// dépliable avec icône + sous-titre, puis liste de [SpecRow].
class SpecCategoryCard extends StatefulWidget {
  const SpecCategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.rows,
    this.initiallyExpanded = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<MapEntry<String, String>> rows;
  final bool initiallyExpanded;

  @override
  State<SpecCategoryCard> createState() => _SpecCategoryCardState();
}

class _SpecCategoryCardState extends State<SpecCategoryCard> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DashboardColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DashboardColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: DashboardColors.border),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: DashboardColors.chipBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: DashboardColors.border),
                    ),
                    child: Icon(widget.icon, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: DashboardText.headlineMd()),
                        Text(
                          widget.subtitle,
                          style: DashboardText.labelDataSm(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.expand_more,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: List.generate(widget.rows.length, (i) {
                  final entry = widget.rows[i];
                  return SpecRow(
                    label: entry.key,
                    value: entry.value,
                    shaded: i.isEven,
                  );
                }),
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
