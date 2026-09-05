import 'package:flutter/material.dart';

class AppError extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;
  final bool compact;

  const AppError({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.retryLabel = 'Retry',
    this.icon = Icons.error_outline,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.error;

    if (compact) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 21,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: onRetry,
                child: Text(retryLabel),
              ),
            ],
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 480,
          ),
          child: Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title ?? 'Something went wrong',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(
                        Icons.refresh,
                      ),
                      label: Text(retryLabel),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}