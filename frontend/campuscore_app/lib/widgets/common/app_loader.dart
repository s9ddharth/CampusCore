import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  final String? message;
  final double size;
  final double strokeWidth;
  final bool showMessage;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const AppLoader({
    super.key,
    this.message,
    this.size = 32,
    this.strokeWidth = 3,
    this.showMessage = true,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              color: theme.colorScheme.primary,
            ),
          ),
          if (showMessage &&
              message != null &&
              message!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AppLoadingOverlay extends StatelessWidget {
  final bool visible;
  final String? message;
  final Widget child;
  final Color? overlayColor;

  const AppLoadingOverlay({
    super.key,
    required this.visible,
    required this.child,
    this.message,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return child;
    }

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: ColoredBox(
            color: overlayColor ??
                Theme.of(context)
                    .colorScheme
                    .scrim
                    .withValues(alpha: 0.25),
            child: const AppLoader(
              message: null,
            ),
          ),
        ),
        if (message != null &&
            message!.trim().isNotEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 18,
                        spreadRadius: 1,
                        color: Colors.black.withValues(
                          alpha: 0.12,
                        ),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          message!,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}