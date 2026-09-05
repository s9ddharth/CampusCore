import 'package:flutter/material.dart';

class Breadcrumbs extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final bool showHome;
  final VoidCallback? onHomeTap;
  final bool compact;
  final Color? separatorColor;

  const Breadcrumbs({
    super.key,
    required this.items,
    this.showHome = true,
    this.onHomeTap,
    this.compact = false,
    this.separatorColor,
  });

  Widget _separator(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 6,
      ),
      child: Icon(
        Icons.chevron_right,
        size: compact ? 16 : 18,
        color:
            separatorColor ??
            theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _item(
    BuildContext context,
    BreadcrumbItem item, {
    required bool isLast,
  }) {
    final theme = Theme.of(context);

    final color = isLast
        ? theme.colorScheme.onSurface
        : theme.colorScheme.primary;

    final text = Text(
      item.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodySmall?.copyWith(
        color: color,
        fontWeight: isLast
            ? FontWeight.w600
            : FontWeight.w500,
      ),
    );

    if (item.onTap == null || isLast) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.icon != null) ...[
            Icon(
              item.icon,
              size: compact ? 16 : 18,
              color: color,
            ),
            const SizedBox(width: 5),
          ],
          Flexible(child: text),
        ],
      );
    }

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 3,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: compact ? 16 : 18,
                color: color,
              ),
              const SizedBox(width: 5),
            ],
            Flexible(child: text),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = items
        .where(
          (item) => item.label.trim().isNotEmpty,
        )
        .toList();

    if (visibleItems.isEmpty && !showHome) {
      return const SizedBox.shrink();
    }

    final widgets = <Widget>[];

    if (showHome) {
      final theme = Theme.of(context);

      widgets.add(
        Tooltip(
          message: 'Home',
          child: InkWell(
            onTap: onHomeTap,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.home_outlined,
                size: compact ? 17 : 19,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      );

      if (visibleItems.isNotEmpty) {
        widgets.add(_separator(context));
      }
    }

    for (var index = 0;
        index < visibleItems.length;
        index++) {
      final item = visibleItems[index];
      final isLast = index == visibleItems.length - 1;

      widgets.add(
        Flexible(
          child: _item(
            context,
            item,
            isLast: isLast,
          ),
        ),
      );

      if (!isLast) {
        widgets.add(_separator(context));
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: widgets,
      ),
    );
  }
}

class BreadcrumbItem {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const BreadcrumbItem({
    required this.label,
    this.icon,
    this.onTap,
  });
}