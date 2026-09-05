import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? fontSize;
  final VoidCallback? onTap;
  final Widget? fallbackIcon;

  const AppAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.radius = 20,
    this.backgroundColor,
    this.foregroundColor,
    this.fontSize,
    this.onTap,
    this.fallbackIcon,
  });

  String _initials() {
    final value = name?.trim() ?? '';

    if (value.isEmpty) {
      return '?';
    }

    final parts = value
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor:
          backgroundColor ?? theme.colorScheme.primaryContainer,
      foregroundColor:
          foregroundColor ?? theme.colorScheme.primary,
      backgroundImage: imageUrl != null &&
              imageUrl!.trim().isNotEmpty
          ? NetworkImage(imageUrl!)
          : null,
      onBackgroundImageError:
          imageUrl != null && imageUrl!.trim().isNotEmpty
              ? (_, __) {}
              : null,
      child: imageUrl == null || imageUrl!.trim().isEmpty
          ? (fallbackIcon ??
              Text(
                _initials(),
                style: TextStyle(
                  fontSize:
                      fontSize ?? radius * 0.75,
                  fontWeight: FontWeight.w600,
                ),
              ))
          : null,
    );

    if (onTap == null) {
      return avatar;
    }

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: avatar,
    );
  }
}