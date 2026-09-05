import 'package:flutter/material.dart';

class StudentProfileHeader extends StatelessWidget {
  final String name;
  final String rollNo;
  final String? email;
  final String? phone;
  final String? department;
  final String? section;
  final int? semester;
  final String? status;
  final String? imageUrl;
  final VoidCallback? onEdit;
  final VoidCallback? onBack;
  final bool showBackButton;
  final bool compact;

  const StudentProfileHeader({
    super.key,
    required this.name,
    required this.rollNo,
    this.email,
    this.phone,
    this.department,
    this.section,
    this.semester,
    this.status,
    this.imageUrl,
    this.onEdit,
    this.onBack,
    this.showBackButton = false,
    this.compact = false,
  });

  String _initials() {
    final value = name.trim();

    if (value.isEmpty) {
      return '?';
    }

    final parts = value
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
        '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  Color _statusColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final normalized = status?.trim().toLowerCase() ?? '';

    switch (normalized) {
      case 'active':
        return Colors.green;

      case 'inactive':
      case 'suspended':
        return Colors.orange;

      case 'graduated':
      case 'completed':
        return scheme.primary;

      case 'dropped':
      case 'cancelled':
      case 'canceled':
        return scheme.error;

      default:
        return scheme.onSurfaceVariant;
    }
  }

  Widget _statusBadge(BuildContext context) {
    if (status == null || status!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final color = _statusColor(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        status!,
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _avatar(BuildContext context) {
    final theme = Theme.of(context);

    return CircleAvatar(
      radius: compact ? 34 : 44,
      backgroundColor: theme.colorScheme.primaryContainer,
      foregroundColor: theme.colorScheme.primary,
      backgroundImage: imageUrl != null &&
              imageUrl!.trim().isNotEmpty
          ? NetworkImage(imageUrl!)
          : null,
      child: imageUrl == null || imageUrl!.trim().isEmpty
          ? Text(
              _initials(),
              style: TextStyle(
                fontSize: compact ? 21 : 27,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  Widget _infoChip(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(
          compact ? 16 : 22,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showBackButton) ...[
                  IconButton(
                    tooltip: 'Back',
                    onPressed: onBack,
                    icon: const Icon(
                      Icons.arrow_back,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                _avatar(context),
                SizedBox(
                  width: compact ? 12 : 16,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              name.trim().isEmpty
                                  ? 'Unnamed Student'
                                  : name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: (compact
                                      ? theme.textTheme.titleLarge
                                      : theme.textTheme.headlineSmall)
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _statusBadge(context),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rollNo.isEmpty
                            ? 'No roll number'
                            : 'Roll No. $rollNo',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (department != null &&
                          department!.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            department!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    tooltip: 'Edit Student',
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (semester != null)
                  _infoChip(
                    context,
                    icon: Icons.school_outlined,
                    text: 'Semester $semester',
                  ),
                if (section != null &&
                    section!.trim().isNotEmpty)
                  _infoChip(
                    context,
                    icon: Icons.groups_outlined,
                    text: 'Section $section',
                  ),
                if (email != null &&
                    email!.trim().isNotEmpty)
                  _infoChip(
                    context,
                    icon: Icons.email_outlined,
                    text: email!,
                  ),
                if (phone != null &&
                    phone!.trim().isNotEmpty)
                  _infoChip(
                    context,
                    icon: Icons.phone_outlined,
                    text: phone!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}