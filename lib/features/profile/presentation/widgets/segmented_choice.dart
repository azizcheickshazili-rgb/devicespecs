import 'package:flutter/material.dart';

import '../../../dashboard/presentation/theme/dashboard_colors.dart';

/// Contrôle segmenté (2 à 3 options), style blanc-sur-noir de la maquette
/// Profil. [icons] est optionnel — s'il est fourni, une icône précède le
/// libellé de chaque option.
class SegmentedChoice extends StatelessWidget {
  const SegmentedChoice({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    this.icons,
    this.compact = false,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final List<IconData>? icons;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
      children: List.generate(options.length, (i) {
        final selected = i == selectedIndex;
        final button = GestureDetector(
          onTap: () => onChanged(i),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 8,
              horizontal: compact ? 12 : 4,
            ),
            decoration: BoxDecoration(
              color: selected ? Colors.white : null,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icons != null) ...[
                  Icon(
                    icons![i],
                    size: 14,
                    color: selected ? Colors.black : DashboardColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  options[i],
                  style: DashboardText.labelDataSm(
                    color: selected ? Colors.black : DashboardColors.textMuted,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
        return compact ? button : Expanded(child: button);
      }),
    );

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: DashboardColors.sparklineBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DashboardColors.border),
      ),
      child: content,
    );
  }
}
