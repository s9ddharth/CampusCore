import 'package:flutter/material.dart';

class StudentDetailsPage extends StatelessWidget {
  final StudentDetailsData student;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onBack;
  final VoidCallback? onViewAttendance;
  final VoidCallback? onViewResults;
  final VoidCallback? onViewFees;

  const StudentDetailsPage({
    super.key,
    required this.student,
    this.onEdit,
    this.onDelete,
    this.onBack,
    this.onViewAttendance,
    this.onViewResults,
    this.onViewFees,
  });

  String _value(
    String? value, {
    String fallback = 'Not provided',
  }) {
    if (value == null || value.trim().isEmpty) {
      return fallback;
    }

    return value.trim();
  }

  String _dateValue(DateTime? date) {
    if (date == null) {
      return 'Not provided';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Widget _buildStatusBadge(
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final normalized = student.status.toUpperCase();
    final isActive = normalized == 'ACTIVE';

    final foreground = isActive
        ? Colors.green.shade700
        : theme.colorScheme.onSurfaceVariant;

    final background = isActive
        ? Colors.green.withValues(alpha: 0.10)
        : theme.colorScheme.surfaceContainerHighest;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            student.status,
            style: theme.textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.dividerColor,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    final initials = student.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map(
          (part) => part[0].toUpperCase(),
        )
        .join();

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final compact = constraints.maxWidth < 600;

            final avatar = CircleAvatar(
              radius: 36,
              backgroundColor:
                  theme.colorScheme.primaryContainer,
              child: Text(
                initials.isEmpty ? '?' : initials,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );

            final details = Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _value(student.rollNo),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _value(student.email),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );

            final status = _buildStatusBadge(context);

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      avatar,
                      const SizedBox(width: 14),
                      details,
                    ],
                  ),
                  const SizedBox(height: 14),
                  status,
                ],
              );
            }

            return Row(
              children: [
                avatar,
                const SizedBox(width: 16),
                details,
                const SizedBox(width: 12),
                status,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onPressed,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
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
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
  ) async {
    if (onDelete == null) {
      return;
    }

    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Student?',
          ),
          content: Text(
            'Delete the student record for ${student.name}? '
            'This is a destructive administrative action.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      onDelete!();
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Details',
        ),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: onBack ??
              () {
                Navigator.of(context).maybePop();
              },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
        actions: [
          if (onEdit != null)
            IconButton(
              tooltip: 'Edit student',
              onPressed: onEdit,
              icon: const Icon(
                Icons.edit_outlined,
              ),
            ),
          if (onDelete != null)
            IconButton(
              tooltip: 'Delete student',
              onPressed: () {
                _confirmDelete(context);
              },
              icon: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1050,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Student Profile',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'View student information and academic management shortcuts.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildProfileHeader(context),
                  const SizedBox(height: 18),
                  Text(
                    'Personal & Enrollment Information',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (
                      context,
                      constraints,
                    ) {
                      final twoColumns = constraints.maxWidth >= 700;

                      final tiles = [
                        _buildInfoCard(
                          context,
                          icon: Icons.badge_outlined,
                          label: 'Roll Number',
                          value: _value(student.rollNo),
                        ),
                        _buildInfoCard(
                          context,
                          icon: Icons.person_outline,
                          label: 'Full Name',
                          value: _value(student.name),
                        ),
                        _buildInfoCard(
                          context,
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: _value(student.email),
                        ),
                        _buildInfoCard(
                          context,
                          icon: Icons.phone_outlined,
                          label: 'Phone',
                          value: _value(student.phone),
                        ),
                        _buildInfoCard(
                          context,
                          icon: Icons.calendar_today_outlined,
                          label: 'Date of Birth',
                          value: _dateValue(student.dob),
                        ),
                        _buildInfoCard(
                          context,
                          icon: Icons.account_tree_outlined,
                          label: 'Department',
                          value: _value(student.departmentName),
                        ),
                        _buildInfoCard(
                          context,
                          icon: Icons.groups_outlined,
                          label: 'Section',
                          value: _value(student.sectionName),
                        ),
                        _buildInfoCard(
                          context,
                          icon: Icons.school_outlined,
                          label: 'Semester',
                          value: student.semester == null
                              ? 'Not provided'
                              : 'Semester ${student.semester}',
                        ),
                        _buildInfoCard(
                          context,
                          icon: Icons.toggle_on_outlined,
                          label: 'Enrollment Status',
                          value: _value(student.status),
                        ),
                        _buildInfoCard(
                          context,
                          icon: Icons.fingerprint_outlined,
                          label: 'Student ID',
                          value: student.id.toString(),
                        ),
                      ];

                      if (!twoColumns) {
                        return Column(
                          children: [
                            for (var i = 0; i < tiles.length; i++) ...[
                              tiles[i],
                              if (i < tiles.length - 1)
                                const SizedBox(
                                  height: 12,
                                ),
                            ],
                          ],
                        );
                      }

                      return Column(
                        children: [
                          for (var i = 0; i < tiles.length; i += 2) ...[
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: tiles[i],
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  child: i + 1 < tiles.length
                                      ? tiles[i + 1]
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                            if (i + 2 < tiles.length)
                              const SizedBox(
                                height: 12,
                              ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Student Modules',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (
                      context,
                      constraints,
                    ) {
                      final twoColumns = constraints.maxWidth >= 700;

                      final actions = [
                        _buildQuickAction(
                          context,
                          icon: Icons.fact_check_outlined,
                          title: 'Attendance',
                          subtitle:
                              'View attendance records and history.',
                          onPressed: onViewAttendance,
                        ),
                        _buildQuickAction(
                          context,
                          icon: Icons.assessment_outlined,
                          title: 'Results',
                          subtitle:
                              'View academic results and performance.',
                          onPressed: onViewResults,
                        ),
                        _buildQuickAction(
                          context,
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Fees',
                          subtitle:
                              'View fee status and payment information.',
                          onPressed: onViewFees,
                        ),
                        _buildQuickAction(
                          context,
                          icon: Icons.edit_outlined,
                          title: 'Edit Profile',
                          subtitle:
                              'Update student master information.',
                          onPressed: onEdit,
                        ),
                      ];

                      if (!twoColumns) {
                        return Column(
                          children: [
                            for (var i = 0; i < actions.length; i++) ...[
                              actions[i],
                              if (i < actions.length - 1)
                                const SizedBox(
                                  height: 12,
                                ),
                            ],
                          ],
                        );
                      }

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: actions[0],
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                child: actions[1],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: actions[2],
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                child: actions[3],
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Student information is displayed from the central student record. '
                              'Attendance, fees and academic results remain separate modules.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StudentDetailsData {
  final int id;
  final int? userId;
  final String rollNo;
  final String name;
  final DateTime? dob;
  final String? phone;
  final String email;
  final int? semester;
  final int? departmentId;
  final String? departmentName;
  final int? sectionId;
  final String? sectionName;
  final String status;

  const StudentDetailsData({
    required this.id,
    this.userId,
    required this.rollNo,
    required this.name,
    this.dob,
    this.phone,
    required this.email,
    this.semester,
    this.departmentId,
    this.departmentName,
    this.sectionId,
    this.sectionName,
    this.status = 'ACTIVE',
  });

  factory StudentDetailsData.fromJson(
    Map<String, dynamic> json,
  ) {
    final department = json['department'];
    final section = json['section'];

    return StudentDetailsData(
      id: _toInt(json['id']) ?? 0,
      userId: _toInt(json['user_id']),
      rollNo: json['roll_no']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      dob: _toDate(json['dob']),
      phone: json['phone']?.toString(),
      email: json['email']?.toString() ?? '',
      semester: _toInt(json['semester']),
      departmentId: _toInt(
        json['department_id'],
      ),
      departmentName: department is Map
          ? department['name']?.toString()
          : json['department_name']?.toString(),
      sectionId: _toInt(
        json['section_id'],
      ),
      sectionName: section is Map
          ? section['name']?.toString()
          : json['section_name']?.toString(),
      status: json['status']?.toString() ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'roll_no': rollNo,
      'name': name,
      'dob': dob?.toIso8601String(),
      'phone': phone,
      'email': email,
      'semester': semester,
      'department_id': departmentId,
      'department_name': departmentName,
      'section_id': sectionId,
      'section_name': sectionName,
      'status': status,
    };
  }

  static int? _toInt(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(
      value.toString(),
    );
  }

  static DateTime? _toDate(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }
}