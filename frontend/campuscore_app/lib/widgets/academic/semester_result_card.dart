import 'package:flutter/material.dart';

class SemesterResultCard extends StatelessWidget {
  final int semester;
  final String? academicYear;
  final double? gpa;
  final double? totalCredits;
  final double? earnedCredits;
  final int? totalSubjects;
  final int? passedSubjects;
  final bool? isPassed;
  final VoidCallback? onTap;

  const SemesterResultCard({
    super.key,
    required this.semester,
    this.academicYear,
    this.gpa,
    this.totalCredits,
    this.earnedCredits,
    this.totalSubjects,
    this.passedSubjects,
    this.isPassed,
    this.onTap,
  });

  String _formatNumber(double? value) {
    if (value == null) {
      return '-';
    }

    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  Color _statusColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (isPassed == null) {
      return scheme.onSurfaceVariant;
    }

    return isPassed! ? Colors.green : scheme.error;
  }

  String _statusText() {
    if (isPassed == null) {
      return 'Pending';
    }

    return isPassed! ? 'Passed' : 'Failed';
  }

  Widget _metric(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        _statusText(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$semester',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Semester $semester',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (academicYear != null &&
                            academicYear!.trim().isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            academicYear!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _statusBadge(context),
                  if (onTap != null) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 430) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            if (gpa != null)
                              _metric(
                                context,
                                label: 'GPA',
                                value: _formatNumber(gpa),
                              ),
                            if (gpa != null &&
                                totalCredits != null)
                              const SizedBox(width: 10),
                            if (totalCredits != null)
                              _metric(
                                context,
                                label: 'Total Credits',
                                value: _formatNumber(
                                  totalCredits,
                                ),
                              ),
                          ],
                        ),
                        if (earnedCredits != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _metric(
                                context,
                                label: 'Earned Credits',
                                value: _formatNumber(
                                  earnedCredits,
                                ),
                              ),
                              if (totalSubjects != null)
                                const SizedBox(width: 10),
                              if (totalSubjects != null)
                                _metric(
                                  context,
                                  label: 'Subjects',
                                  value: '$totalSubjects',
                                ),
                            ],
                          ),
                        ],
                        if (passedSubjects != null) ...[
                          const SizedBox(height: 10),
                          _metric(
                            context,
                            label: 'Passed Subjects',
                            value: '$passedSubjects'
                                '${totalSubjects != null ? ' / $totalSubjects' : ''}',
                          ),
                        ],
                      ],
                    );
                  }

                  return Row(
                    children: [
                      if (gpa != null)
                        _metric(
                          context,
                          label: 'GPA',
                          value: _formatNumber(gpa),
                        ),
                      if (gpa != null && totalCredits != null)
                        const SizedBox(width: 10),
                      if (totalCredits != null)
                        _metric(
                          context,
                          label: 'Total Credits',
                          value: _formatNumber(
                            totalCredits,
                          ),
                        ),
                      if (earnedCredits != null)
                        const SizedBox(width: 10),
                      if (earnedCredits != null)
                        _metric(
                          context,
                          label: 'Earned Credits',
                          value: _formatNumber(
                            earnedCredits,
                          ),
                        ),
                      if (totalSubjects != null)
                        const SizedBox(width: 10),
                      if (totalSubjects != null)
                        _metric(
                          context,
                          label: 'Subjects',
                          value: '$totalSubjects',
                        ),
                      if (passedSubjects != null)
                        const SizedBox(width: 10),
                      if (passedSubjects != null)
                        _metric(
                          context,
                          label: 'Passed',
                          value: '$passedSubjects'
                              '${totalSubjects != null ? ' / $totalSubjects' : ''}',
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}