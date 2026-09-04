import 'package:flutter/material.dart';

class QuickAction extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool compact;
  final bool enabled;

  const QuickAction({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.compact = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final resolvedIconColor =
        iconColor ?? theme.colorScheme.primary;

    final resolvedBackgroundColor =
        backgroundColor ??
        theme.colorScheme.primaryContainer.withValues(
          alpha: 0.45,
        );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 72,
          ),
          padding: EdgeInsets.all(
            compact ? 12 : 14,
          ),
          decoration: BoxDecoration(
            color: enabled
                ? theme.colorScheme.surface
                : theme.colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: compact ? 42 : 48,
                height: compact ? 42 : 48,
                decoration: BoxDecoration(
                  color: enabled
                      ? resolvedBackgroundColor
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: compact ? 21 : 24,
                  color: enabled
                      ? resolvedIconColor
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(
                width: compact ? 10 : 12,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: enabled
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme
                                .onSurfaceVariant,
                      ),
                    ),
                    if (subtitle != null &&
                        subtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: enabled
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuickActionGrid extends StatelessWidget {
  final List<QuickActionItem> actions;
  final int crossAxisCount;
  final double spacing;
  final bool compact;

  const QuickActionGrid({
    super.key,
    required this.actions,
    this.crossAxisCount = 2,
    this.spacing = 12,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final columns = width < 550
            ? 1
            : width < 850
                ? 2
                : crossAxisCount;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: columns == 1 ? 4.2 : 2.7,
          ),
          itemBuilder: (context, index) {
            final action = actions[index];

            return QuickAction(
              title: action.title,
              subtitle: action.subtitle,
              icon: action.icon,
              onTap: action.onTap,
              iconColor: action.iconColor,
              backgroundColor: action.backgroundColor,
              compact: compact,
              enabled: action.enabled,
            );
          },
        );
      },
    );
  }
}

class QuickActionItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool enabled;

  const QuickActionItem({
    required this.title,
    required this.icon,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.enabled = true,
  });
}