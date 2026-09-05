import 'package:flutter/material.dart';

class TopSStudents extends StatelessWidget {
  final List<TopSStudent> students;
  final String title;
  final String subtitle;
  final bool isLoading;
  final int maxStudents;
  final void Function(TopSStudent student)? onTap;

  const TopSStudents({
    super.key,
    required this.students,
    this.title = 'Top S Students',
    this.subtitle = 'Highest-ranked eligible students',
    this.isLoading = false,
    this.maxStudents = 5,
    this.onTap,
  });

  String _formatScore(double? value) {
    if (value == null) {
      return '-';
    }

    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  Widget _rankCircle(
    BuildContext context,
    int rank,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primaryContainer,
      ),
      child: Text(
        '$rank',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _studentRow(
    BuildContext context,
    TopSStudent student,
    int index,
  ) {
    final theme = Theme.of(context);

    final rank = student.rank > 0
        ? student.rank
        : index + 1;

    return InkWell(
      onTap: onTap == null || isLoading
          ? null
          : () => onTap!(student),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 10,
        ),
        child: Row(
          children: [
            _rankCircle(
              context,
              rank,
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              child: Text(
                student.name.isEmpty
                    ? '?'
                    : student.name[0].toUpperCase(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name.isEmpty
                        ? 'Unknown Student'
                        : student.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (student.rollNo.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        student.rollNo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    'S',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                if (student.normalizedScore != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatScore(student.normalizedScore),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
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

    final visibleStudents = students
        .take(maxStudents)
        .toList();

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.emoji_events_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: theme.colorScheme.primaryContainer,
                  ),
                  child: Text(
                    'Top $maxStudents',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (visibleStudents.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 38,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No S-grade students available.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(
                visibleStudents.length,
                (index) => Column(
                  children: [
                    _studentRow(
                      context,
                      visibleStudents[index],
                      index,
                    ),
                    if (index < visibleStudents.length - 1)
                      Divider(
                        height: 1,
                        indent: 54,
                        color: theme.colorScheme.outlineVariant,
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

class TopSStudent {
  final int studentId;
  final int rank;
  final String name;
  final String rollNo;
  final double? normalizedScore;
  final double? rawTotal;
  final double? tee;

  const TopSStudent({
    required this.studentId,
    this.rank = 0,
    required this.name,
    required this.rollNo,
    this.normalizedScore,
    this.rawTotal,
    this.tee,
  });
}