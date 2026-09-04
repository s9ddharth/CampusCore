import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool outlined;
  final bool textButton;
  final bool expand;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.outlined = false,
    this.textButton = false,
    this.expand = false,
    this.width,
    this.height = 46,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 12,
    ),
    this.borderRadius = const BorderRadius.all(
      Radius.circular(10),
    ),
  });

  Widget _loadingIndicator(BuildContext context) {
    final color = foregroundColor ??
        Theme.of(context).colorScheme.onPrimary;

    return SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  ButtonStyle _style(BuildContext context) {
    final theme = Theme.of(context);

    if (outlined) {
      return OutlinedButton.styleFrom(
        minimumSize: Size(0, height),
        padding: padding,
        foregroundColor:
            foregroundColor ?? theme.colorScheme.primary,
        side: BorderSide(
          color:
              borderColor ?? theme.colorScheme.primary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
      );
    }

    if (textButton) {
      return TextButton.styleFrom(
        minimumSize: Size(0, height),
        padding: padding,
        foregroundColor:
            foregroundColor ?? theme.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
      );
    }

    return FilledButton.styleFrom(
      minimumSize: Size(0, height),
      padding: padding,
      backgroundColor:
          backgroundColor ?? theme.colorScheme.primary,
      foregroundColor:
          foregroundColor ?? theme.colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          _loadingIndicator(context)
        else if (icon != null)
          Icon(
            icon,
            size: 20,
          ),
        if ((isLoading || icon != null) &&
            text.isNotEmpty)
          const SizedBox(width: 8),
        if (text.isNotEmpty)
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );

    final style = _style(context);

    if (outlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: child,
      );
    }

    if (textButton) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: child,
      );
    }

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget button = _buildButton(context);

    if (width != null) {
      button = SizedBox(
        width: width,
        height: height,
        child: button,
      );
    } else if (expand) {
      button = SizedBox(
        width: double.infinity,
        height: height,
        child: button,
      );
    }

    return button;
  }
}