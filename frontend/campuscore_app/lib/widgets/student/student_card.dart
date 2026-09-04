import 'package:flutter/material.dart';

class StudentCard extends StatelessWidget {
  final int? studentId;
  final String name;
  final String rollNo;
  final String? email;
  final String? phone;
  final String? department;
  final String? section;
  final int? semester;
  final String? status;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onView;
  final bool showActions;
  final bool compact;

  const StudentCard({
    super.key,
    this.studentId,
    required this.name,
    required this.rollNo,
    this.email,
    this.phone,
    this.department,
    this.section,
    this.semester,
    this.status,
    this.imageUrl,
    this.onTap,
    this.onEdit,
    this.onView,
    this.showActions = false,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
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
      radius: compact ? 25 : 30,
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
                fontSize: compact ? 16 : 19,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 20,
      ),
      visualDensity: VisualDensity.compact,
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
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(
            compact ? 14 : 18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _avatar(context),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.trim().isEmpty
                              ? 'Unnamed Student'
                              : name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          rollNo.isEmpty
                              ? 'No roll number'
                              : rollNo,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusBadge(context),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 9),
              if (department != null &&
                  department!.trim().isNotEmpty)
                _infoRow(
                  context,
                  icon: Icons.account_tree_outlined,
                  value: department!,
                ),
              if (section != null &&
                  section!.trim().isNotEmpty)
                _infoRow(
                  context,
                  icon: Icons.groups_outlined,
                  value: 'Section: $section',
                ),
              if (semester != null)
                _infoRow(
                  context,
                  icon: Icons.school_outlined,
                  value: 'Semester $semester',
                ),
              if (email != null &&
                  email!.trim().isNotEmpty)
                _infoRow(
                  context,
                  icon: Icons.email_outlined,
                  value: email!,
                ),
              if (phone != null &&
                  phone!.trim().isNotEmpty)
                _infoRow(
                  context,
                  icon: Icons.phone_outlined,
                  value: phone!,
                ),
              if (showActions &&
                  (onView != null || onEdit != null)) ...[
                const SizedBox(height: 10),
                const Divider(height: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onView != null)
                      _actionButton(
                        context,
                        icon: Icons.visibility_outlined,
                        tooltip: 'View',
                        onPressed: onView,
                      ),
                    if (onEdit != null)
                      _actionButton(
                        context,
                        icon: Icons.edit_outlined,
                        tooltip: 'Edit',
                        onPressed: onEdit,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}