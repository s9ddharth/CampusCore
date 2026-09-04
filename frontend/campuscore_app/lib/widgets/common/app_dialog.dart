import 'package:flutter/material.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget content;
  final List<Widget>? actions;
  final Widget? icon;
  final double maxWidth;
  final bool barrierDismissible;
  final EdgeInsetsGeometry contentPadding;
  final VoidCallback? onClose;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.subtitle,
    this.actions,
    this.icon,
    this.maxWidth = 560,
    this.barrierDismissible = true,
    this.contentPadding = const EdgeInsets.fromLTRB(
      24,
      20,
      24,
      8,
    ),
    this.onClose,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    String? subtitle,
    List<Widget>? actions,
    Widget? icon,
    double maxWidth = 560,
    bool barrierDismissible = true,
    EdgeInsetsGeometry contentPadding =
        const EdgeInsets.fromLTRB(24, 20, 24, 8),
    VoidCallback? onClose,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return AppDialog(
          title: title,
          subtitle: subtitle,
          content: content,
          actions: actions,
          icon: icon,
          maxWidth: maxWidth,
          barrierDismissible: barrierDismissible,
          contentPadding: contentPadding,
          onClose: onClose,
        );
      },
    );
  }

  void _close(BuildContext context) {
    onClose?.call();

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                20,
                16,
                12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (icon != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 2,
                        right: 12,
                      ),
                      child: icon,
                    ),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (subtitle != null &&
                            subtitle!.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: barrierDismissible
                        ? () => _close(context)
                        : null,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: contentPadding,
                child: content,
              ),
            ),
            if (actions != null && actions!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  8,
                  24,
                  20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ...actions!.map(
                      (action) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: action,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}