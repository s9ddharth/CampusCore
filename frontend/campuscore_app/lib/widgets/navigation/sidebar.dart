import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final List<SidebarItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;
  final String? title;
  final String? subtitle;
  final Widget? header;
  final Widget? footer;
  final bool collapsed;
  final VoidCallback? onToggle;
  final double expandedWidth;
  final double collapsedWidth;

  const Sidebar({
    super.key,
    required this.items,
    this.selectedIndex = 0,
    this.onSelected,
    this.title,
    this.subtitle,
    this.header,
    this.footer,
    this.collapsed = false,
    this.onToggle,
    this.expandedWidth = 260,
    this.collapsedWidth = 76,
  });

  double get _width =>
      collapsed ? collapsedWidth : expandedWidth;

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    if (header != null) {
      return header!;
    }

    return Padding(
      padding: EdgeInsets.all(
        collapsed ? 12 : 18,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.school_outlined,
              color: theme.colorScheme.primary,
            ),
          ),
          if (!collapsed) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? 'CampusCore',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null &&
                      subtitle!.trim().isNotEmpty)
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    SidebarItem item,
    int index,
  ) {
    final theme = Theme.of(context);

    final selected = index == selectedIndex;
    final activeColor =
        item.activeColor ?? theme.colorScheme.primary;
    final inactiveColor =
        item.inactiveColor ??
        theme.colorScheme.onSurfaceVariant;

    final color = item.enabled
        ? selected
            ? activeColor
            : inactiveColor
        : inactiveColor.withValues(alpha: 0.4);

    final tile = Container(
      margin: EdgeInsets.symmetric(
        horizontal: collapsed ? 8 : 10,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: selected
            ? activeColor.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: item.enabled && onSelected != null
            ? () => onSelected!(index)
            : null,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 10 : 12,
            vertical: 11,
          ),
          child: Row(
            mainAxisAlignment: collapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    selected
                        ? item.selectedIcon ?? item.icon
                        : item.icon,
                    size: 21,
                    color: color,
                  ),
                  if (item.badge != null &&
                      item.badge! > 0)
                    Positioned(
                      right: -8,
                      top: -7,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 3,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Text(
                          item.badge! > 99
                              ? '99+'
                              : '${item.badge}',
                          style: theme.textTheme.labelSmall
                              ?.copyWith(
                            color:
                                theme.colorScheme.onError,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (!collapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            theme.textTheme.bodyMedium?.copyWith(
                          color: color,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                      if (item.subtitle != null &&
                          item.subtitle!.trim().isNotEmpty)
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 2),
                          child: Text(
                            item.subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                theme.textTheme.bodySmall?.copyWith(
                              color: inactiveColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (item.trailing != null)
                  item.trailing!,
              ],
            ],
          ),
        ),
      ),
    );

    if (collapsed) {
      return Tooltip(
        message: item.label,
        child: tile,
      );
    }

    return tile;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final safeSelectedIndex =
        items.isEmpty ? 0 : selectedIndex.clamp(
          0,
          items.length - 1,
        );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: _width,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          if (onToggle != null)
            Align(
              alignment: collapsed
                  ? Alignment.center
                  : Alignment.centerRight,
              child: IconButton(
                tooltip: collapsed
                    ? 'Expand sidebar'
                    : 'Collapse sidebar',
                onPressed: onToggle,
                icon: Icon(
                  collapsed
                      ? Icons.chevron_right
                      : Icons.chevron_left,
                ),
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Icon(
                      Icons.menu_open,
                      color: theme
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _buildItem(
                        context,
                        items[index],
                        index,
                      );
                    },
                  ),
          ),
          if (footer != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(10),
              child: footer!,
            ),
          ],
        ],
      ),
    );
  }
}

class SidebarItem {
  final String label;
  final String? subtitle;
  final IconData icon;
  final IconData? selectedIcon;
  final Widget? trailing;
  final int? badge;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool enabled;

  const SidebarItem({
    required this.label,
    required this.icon,
    this.subtitle,
    this.selectedIcon,
    this.trailing,
    this.badge,
    this.activeColor,
    this.inactiveColor,
    this.enabled = true,
  });
}