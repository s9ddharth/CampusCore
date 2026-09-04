import 'package:flutter/material.dart';

class MobileNavigation extends StatelessWidget {
  final int currentIndex;
  final List<MobileNavigationItem> items;
  final ValueChanged<int>? onChanged;
  final bool showLabels;
  final bool compact;

  const MobileNavigation({
    super.key,
    required this.currentIndex,
    required this.items,
    this.onChanged,
    this.showLabels = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final safeIndex =
        currentIndex.clamp(0, items.length - 1);

    return Material(
      elevation: 8,
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: compact ? 60 : 68,
          child: Row(
            children: List.generate(
              items.length,
              (index) {
                final item = items[index];
                final selected = index == safeIndex;

                return Expanded(
                  child: _NavigationItem(
                    item: item,
                    selected: selected,
                    showLabel: showLabels,
                    compact: compact,
                    onTap: onChanged == null
                        ? null
                        : () => onChanged!(index),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final MobileNavigationItem item;
  final bool selected;
  final bool showLabel;
  final bool compact;
  final VoidCallback? onTap;

  const _NavigationItem({
    required this.item,
    required this.selected,
    required this.showLabel,
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final selectedColor =
        item.activeColor ?? theme.colorScheme.primary;

    final unselectedColor =
        item.inactiveColor ??
        theme.colorScheme.onSurfaceVariant;

    final color =
        selected ? selectedColor : unselectedColor;

    return InkWell(
      onTap: item.enabled ? onTap : null,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 4 : 6,
          vertical: compact ? 6 : 8,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 9 : 11,
                    vertical: compact ? 4 : 5,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? selectedColor.withValues(
                            alpha: 0.10,
                          )
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    selected
                        ? item.selectedIcon ?? item.icon
                        : item.icon,
                    size: compact ? 22 : 24,
                    color: item.enabled
                        ? color
                        : unselectedColor.withValues(
                            alpha: 0.40,
                          ),
                  ),
                ),
                if (item.badge != null &&
                    item.badge! > 0)
                  Positioned(
                    right: -3,
                    top: -5,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 17,
                        minHeight: 17,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        item.badge! > 99
                            ? '99+'
                            : '${item.badge}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onError,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (showLabel) ...[
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: item.enabled
                      ? color
                      : unselectedColor.withValues(
                          alpha: 0.40,
                        ),
                  fontWeight: selected
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MobileNavigationItem {
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final int? badge;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool enabled;

  const MobileNavigationItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badge,
    this.activeColor,
    this.inactiveColor,
    this.enabled = true,
  });
}