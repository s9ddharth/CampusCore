import 'package:flutter/material.dart';

class StudentSummary extends StatelessWidget {
  final String studentName;
  final String rollNo;
  final String? department;
  final String? section;
  final int? semester;
  final double? cgpa;
  final double? attendancePercentage;
  final double? totalFees;
  final double? dueFees;
  final String currency;
  final VoidCallback? onProfileTap;
  final VoidCallback? onResultsTap;
  final VoidCallback? onAttendanceTap;
  final VoidCallback? onFeesTap;
  final bool compact;

  const StudentSummary({
    super.key,
    required this.studentName,
    required this.rollNo,
    this.department,
    this.section,
    this.semester,
    this.cgpa,
    this.attendancePercentage,
    this.totalFees,
    this.dueFees,
    this.currency = '₹',
    this.onProfileTap,
    this.onResultsTap,
    this.onAttendanceTap,
    this.onFeesTap,
    this.compact = false,
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

  String _formatAmount(double? value) {
    if (value == null) {
      return '-';
    }

    return '$currency${value.toStringAsFixed(2)}';
  }

  Color _attendanceColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (attendancePercentage == null) {
      return scheme.onSurfaceVariant;
    }

    if (attendancePercentage! < 75) {
      return scheme.error;
    }

    if (attendancePercentage! < 80) {
      return Colors.orange;
    }

    return Colors.green;
  }

  Color _feeColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (dueFees == null) {
      return scheme.onSurfaceVariant;
    }

    if (dueFees! > 0) {
      return Colors.orange;
    }

    return Colors.green;
  }

  Widget _profileHeader(BuildContext context) {
    final theme = Theme.of(context);

    final initials = studentName.trim().isEmpty
        ? '?'
        : studentName
              .trim()
              .split(RegExp(r'\s+'))
              .where((part) => part.isNotEmpty)
              .take(2)
              .map((part) => part.substring(0, 1))
              .join()
              .toUpperCase();

    return InkWell(
      onTap: onProfileTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.all(compact ? 10 : 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: compact ? 24 : 30,
              backgroundColor:
                  theme.colorScheme.primaryContainer,
              foregroundColor:
                  theme.colorScheme.primary,
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: compact ? 16 : 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: compact ? 10 : 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentName.trim().isEmpty
                        ? 'Unnamed Student'
                        : studentName,
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
                        : 'Roll No. $rollNo',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (onProfileTap != null)
              Icon(
                Icons.chevron_right,
                color:
                    theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
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
        horizontal: 9,
        vertical: 6,
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
            size: 15,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 5),
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

  Widget _summaryMetric(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    final content = Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 38 : 44,
            height: compact ? 38 : 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: compact ? 19 : 22,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right,
              size: 20,
              color:
                  theme.colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(compact ? 14 : 18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _profileHeader(context),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (department != null &&
                    department!.trim().isNotEmpty)
                  _infoChip(
                    context,
                    icon: Icons.account_tree_outlined,
                    text: department!,
                  ),
                if (section != null &&
                    section!.trim().isNotEmpty)
                  _infoChip(
                    context,
                    icon: Icons.groups_outlined,
                    text: 'Section $section',
                  ),
                if (semester != null)
                  _infoChip(
                    context,
                    icon: Icons.school_outlined,
                    text: 'Semester $semester',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns =
                    constraints.maxWidth < 650 ? 1 : 2;

                final metrics = <Widget>[
                  if (cgpa != null)
                    _summaryMetric(
                      context,
                      title: 'CGPA',
                      value:
                          '${_formatNumber(cgpa)} / 10',
                      icon: Icons.school_outlined,
                      color:
                          theme.colorScheme.primary,
                      onTap: onResultsTap,
                    ),
                  if (attendancePercentage != null)
                    _summaryMetric(
                      context,
                      title: 'Attendance',
                      value: '${_formatNumber(attendancePercentage)}%',
                      icon: Icons.fact_check_outlined,
                      color: _attendanceColor(context),
                      onTap: onAttendanceTap,
                    ),
                  if (totalFees != null)
                    _summaryMetric(
                      context,
                      title: 'Total Fees',
                      value: _formatAmount(totalFees),
                      icon:
                          Icons.account_balance_wallet_outlined,
                      color:
                          theme.colorScheme.primary,
                      onTap: onFeesTap,
                    ),
                  if (dueFees != null)
                    _summaryMetric(
                      context,
                      title: 'Fees Due',
                      value: _formatAmount(dueFees),
                      icon: Icons.payments_outlined,
                      color: _feeColor(context),
                      onTap: onFeesTap,
                    ),
                ];

                if (metrics.isEmpty) {
                  return Text(
                    'No academic or financial summary available.',
                    style:
                        theme.textTheme.bodyMedium?.copyWith(
                      color: theme
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  );
                }

                if (columns == 1) {
                  return Column(
                    children: metrics
                        .map(
                          (metric) => Padding(
                            padding:
                                const EdgeInsets.only(
                              bottom: 10,
                            ),
                            child: metric,
                          ),
                        )
                        .toList(),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: metrics.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 76,
                  ),
                  itemBuilder: (context, index) {
                    return metrics[index];
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}