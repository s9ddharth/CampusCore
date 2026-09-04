import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final Clip clipBehavior;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.elevation = 1,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 12,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
  });

  ShapeBorder _shape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: borderColor != null
          ? BorderSide(color: borderColor!)
          : BorderSide.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    final shape = _shape();

    if (onTap == null) {
      return Card(
        margin: margin ?? EdgeInsets.zero,
        elevation: elevation,
        color: backgroundColor,
        clipBehavior: clipBehavior,
        shape: shape,
        child: Padding(
          padding: padding,
          child: child,
        ),
      );
    }

    return Card(
      margin: margin ?? EdgeInsets.zero,
      elevation: elevation,
      color: backgroundColor,
      clipBehavior: clipBehavior,
      shape: shape,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}