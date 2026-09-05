import 'package:flutter/material.dart';

class ActivityList extends StatelessWidget {
  final List<ActivityItem> activities;
  final String title;
  final String emptyMessage;
  final bool showViewAll;
  final String viewAllLabel;
  final VoidCallback? onViewAll;
  final void Function(ActivityItem activity)? onTap;
  final int? maxItems;
  final bool isLoading;
  final bool compact;

  const ActivityList({
    super.key,
    required this.activities,
    this.title = 'Recent Activity',
    this.emptyMessage = 'No recent activity.',
    this.showViewAll = false,
    this.viewAllLabel = 'View All',
    this.onViewAll,
    this.onTap,
    this.maxItems,
    this.isLoading = false,
    this.compact = false,
  });

  Color _typeColor(
    BuildContext context,
    ActivityType type,
  ) {
    final scheme = Theme.of(context).colorScheme;

    switch (type) {
      case ActivityType.success:
        return Colors.green;
      case ActivityType.warning:
        return Colors.orange;
      case ActivityType.error:
        return scheme.error;
      case ActivityType.info:
        return scheme.primary;
      case ActivityType.attendance:
        return Colors.blue;
      case ActivityType.fees:
        return Colors.teal;
      case ActivityType.results:
        return Colors.purple;
      case ActivityType.general:
        return scheme.onSurfaceVariant;
    }
  }

  IconData _typeIcon(ActivityType type) {
    switch (type) {
      case ActivityType.success:
        return Icons.check_circle_outline;
      case ActivityType.warning:
        return Icons.warning_amber_rounded;
      case ActivityType.error:
        return Icons.error_outline;
      case ActivityType.info:
        return Icons.info_outline;
      case ActivityType.attendance:
        return Icons.fact_check_outlined;
      case ActivityType.fees:
        return Icons.account_balance_wallet_outlined;
      case ActivityType.results:
        return Icons.assessment_outlined;
      case ActivityType.general:
        return Icons.notifications_none_outlined;
    }
  }

  String _timeLabel(ActivityItem item) {
    if (item.timeLabel != null &&
        item.timeLabel!.trim().isNotEmpty) {
      return item.timeLabel!;
    }

    if (item.timestamp == null) {
      return '';
    }

    final now = DateTime.now();
    final difference = now.difference(item.timestamp!);

    if (difference.isNegative) {
      return _formatDateTime(item.timestamp!);
    }

    if (difference.inSeconds < 60) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    }

    if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }

    if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    }

    return _formatDateTime(item.timestamp!);
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();

    return '$day/$month/$year';
  }

  Widget _activityItem(
    BuildContext context,
    ActivityItem item,
  ) {
    final theme = Theme.of(context);
    final color = _typeColor(context, item.type);

    return InkWell(
      onTap: onTap == null || isLoading
          ? null
          : () => onTap!(item),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 4 : 8,
          vertical: compact ? 8 : 10,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: compact ? 38 : 44,
              height: compact ? 38 : 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon ?? _typeIcon(item.type),
                size: compact ? 19 : 21,
                color: color,
              ),
            ),
            SizedBox(width: compact ? 10 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.description != null &&
                      item.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      item.description!,
                      maxLines: compact ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _timeLabel(item),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (item.trailing != null) ...[
              const SizedBox(width: 10),
              item.trailing!,
            ],
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final visibleActivities = maxItems == null
        ? activities
        : activities.take(maxItems!).toList();

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(compact ? 14 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (showViewAll)
                  TextButton(
                    onPressed: isLoading ? null : onViewAll,
                    child: Text(viewAllLabel),
                  ),
              ],
            ),
            SizedBox(height: compact ? 6 : 10),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (visibleActivities.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.history_outlined,
                        size: 38,
                        color:
                            theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        emptyMessage,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...List.generate(
                visibleActivities.length,
                (index) {
                  final item = visibleActivities[index];

                  return Column(
                    children: [
                      _activityItem(
                        context,
                        item,
                      ),
                      if (index <
                          visibleActivities.length - 1)
                        Divider(
                          height: 1,
                          color: theme
                              .colorScheme
                              .outlineVariant,
                        ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

enum ActivityType {
  general,
  info,
  success,
  warning,
  error,
  attendance,
  fees,
  results,
}

class ActivityItem {
  final String id;
  final String title;
  final String? description;
  final DateTime? timestamp;
  final String? timeLabel;
  final ActivityType type;
  final IconData? icon;
  final Widget? trailing;

  const ActivityItem({
    required this.id,
    required this.title,
    this.description,
    this.timestamp,
    this.timeLabel,
    this.type = ActivityType.general,
    this.icon,
    this.trailing,
  });
}