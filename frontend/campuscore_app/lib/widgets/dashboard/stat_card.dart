import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final String? trend;
  final bool trendPositive;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool compact;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.iconColor,
    this.backgroundColor,
    this.trend,
    this.trendPositive = true,
    this.onTap,
    this.isLoading = false,
    this.compact = false,
  });

  Widget _iconBox(BuildContext context) {
    final theme = Theme.of(context);
    final color = iconColor ?? theme.colorScheme.primary;

    return Container(
      width: compact ? 46 : 52,
      height: compact ? 46 : 52,
      decoration: BoxDecoration(
        color: backgroundColor ??
            color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        size: compact ? 22 : 25,
        color: color,
      ),
    );
  }

  Widget _loadingContent(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: compact ? 76 : 92,
      child: Row(
        children: [
          _iconBox(context),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: theme
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 130,
                  height: 22,
                  decoration: BoxDecoration(
                    color: theme
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context) {
    final theme = Theme.of(context);
    final color = iconColor ?? theme.colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _iconBox(context),
        SizedBox(width: compact ? 12 : 14),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (trend != null &&
                      trend!.trim().isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: 3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            trendPositive
                                ? Icons
                                    .trending_up_rounded
                                : Icons
                                    .trending_down_rounded,
                            size: 17,
                            color: trendPositive
                                ? Colors.green
                                : theme.colorScheme.error,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            trend!,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(
                              color: trendPositive
                                  ? Colors.green
                                  : theme.colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              if (subtitle != null &&
                  subtitle!.trim().isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onTap != null)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Icon(
              Icons.chevron_right,
              size: 20,
              color: color.withValues(alpha: 0.65),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(
            compact ? 14 : 18,
          ),
          child: isLoading
              ? _loadingContent(context)
              : _content(context),
        ),
      ),
    );
  }
}