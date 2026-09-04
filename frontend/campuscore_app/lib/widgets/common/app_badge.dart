import 'package:flutter/material.dart';

class AppBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? backgroundColor;
  final IconData? icon;
  final bool outlined;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const AppBadge({
    super.key,
    required this.text,
    this.color,
    this.backgroundColor,
    this.icon,
    this.outlined = false,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 5,
    ),
    this.borderRadius = 20,
  });

  Color _resolveForeground(BuildContext context) {
    return color ?? Theme.of(context).colorScheme.primary;
  }

  Color _resolveBackground(BuildContext context) {
    return backgroundColor ??
        _resolveForeground(context).withValues(alpha: 0.12);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = _resolveForeground(context);
    final background = _resolveBackground(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : background,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: outlined
              ? foreground.withValues(alpha: 0.45)
              : foreground.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 15,
              color: foreground,
            ),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}