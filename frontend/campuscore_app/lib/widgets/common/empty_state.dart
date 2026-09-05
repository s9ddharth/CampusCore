import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final bool compact;

  const EmptyState({
    super.key,
    this.title = 'No data available',
    this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    this.iconSize = 48,
    this.padding = const EdgeInsets.all(28),
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: compact
            ? const EdgeInsets.all(16)
            : padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 56 : 72,
              height: compact ? 56 : 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: compact
                    ? iconSize * 0.7
                    : iconSize,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (message != null &&
                message!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 440,
                ),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 18),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}