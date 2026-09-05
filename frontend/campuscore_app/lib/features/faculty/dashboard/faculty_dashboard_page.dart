import 'package:flutter/material.dart';

class FacultyDashboardPage extends StatelessWidget {
  final FacultyDashboardData dashboard;
  final bool isLoading;
  final String? errorMessage;

  final Future<void> Function()? onRefresh;

  final VoidCallback? onMySubjects;
  final VoidCallback? onMarkAttendance;
  final VoidCallback? onAttendanceHistory;
  final VoidCallback? onMarksEntry;
  final VoidCallback? onMarksHistory;
  final VoidCallback? onClassResults;

  const FacultyDashboardPage({
    super.key,
    this.dashboard = const FacultyDashboardData(),
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
    this.onMySubjects,
    this.onMarkAttendance,
    this.onAttendanceHistory,
    this.onMarksEntry,
    this.onMarksHistory,
    this.onClassResults,
  });

  Future<void> _refresh() async {
    if (isLoading || onRefresh == null) {
      return;
    }

    await onRefresh!();
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
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
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
        onTap: isLoading ? null : onPressed,
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildTodaySchedule(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    if (dashboard.todayClasses.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 34,
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.event_available_outlined,
                  size: 46,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 10),
                Text(
                  'No classes scheduled today',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your assigned classes will appear here.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Classes',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            ...dashboard.todayClasses.map(
              (item) => _buildClassTile(
                context,
                item,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassTile(
    BuildContext context,
    FacultyDashboardClassItem item,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.dividerColor,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              Icons.menu_book_outlined,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.subjectCode} - ${item.subjectName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.sectionName} • ${item.time}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (item.room != null &&
                    item.room!.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Room ${item.room}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (item.isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Now',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPendingMarks(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    if (dashboard.pendingMarks.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 34,
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.task_alt_outlined,
                  size: 44,
                  color: Colors.green.shade700,
                ),
                const SizedBox(height: 10),
                Text(
                  'No pending marks entries',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You are up to date with marks entry.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Pending Marks',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  dashboard.pendingMarks.length.toString(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...dashboard.pendingMarks.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor:
                      theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.edit_note_outlined,
                    color: theme.colorScheme.primary,
                  ),
                ),
                title: Text(
                  '${item.subjectCode} - ${item.subjectName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${item.sectionName} • ${item.assessmentName}',
                ),
                trailing: IconButton(
                  tooltip: 'Enter marks',
                  onPressed:
                      isLoading ? null : onMarksEntry,
                  icon: const Icon(
                    Icons.chevron_right,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceOverview(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Overview',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildAttendanceMetric(
                    context,
                    title: 'Classes Marked',
                    value:
                        dashboard.attendanceClassesMarked
                            .toString(),
                    icon: Icons.fact_check_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildAttendanceMetric(
                    context,
                    title: 'Average Attendance',
                    value:
                        '${dashboard.averageAttendance.toStringAsFixed(1)}%',
                    icon: Icons.percent_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (dashboard.lowAttendanceStudents > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.errorContainer.withValues(
                    alpha: 0.55,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        '${dashboard.lowAttendanceStudents} student${dashboard.lowAttendanceStudents == 1 ? '' : 's'} below the attendance threshold.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'No low-attendance alerts in your assigned classes.',
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceMetric(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                errorMessage!,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: _refresh,
              child: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Faculty Dashboard',
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh dashboard',
            onPressed: isLoading
                ? null
                : _refresh,
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.refresh,
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 1250,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    if (errorMessage != null) ...[
                      _buildError(context),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${dashboard.facultyName}',
                                style: theme
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                dashboard.departmentName ??
                                    'Faculty Portal',
                                style: theme
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                  color: theme
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (
                        context,
                        constraints,
                      ) {
                        final compact =
                            constraints.maxWidth <
                                800;

                        final cards = [
                          _buildStatCard(
                            context,
                            title:
                                'Assigned Subjects',
                            value:
                                dashboard
                                    .assignedSubjects
                                    .toString(),
                            subtitle:
                                'Subjects currently assigned',
                            icon: Icons
                                .menu_book_outlined,
                          ),
                          _buildStatCard(
                            context,
                            title:
                                'Assigned Sections',
                            value:
                                dashboard
                                    .assignedSections
                                    .toString(),
                            subtitle:
                                'Sections you teach',
                            icon: Icons
                                .groups_outlined,
                          ),
                          _buildStatCard(
                            context,
                            title:
                                'Pending Marks',
                            value:
                                dashboard
                                    .pendingMarksCount
                                    .toString(),
                            subtitle:
                                'Entries requiring attention',
                            icon: Icons
                                .edit_note_outlined,
                          ),
                          _buildStatCard(
                            context,
                            title:
                                'Attendance',
                            value:
                                '${dashboard.averageAttendance.toStringAsFixed(1)}%',
                            subtitle:
                                'Average class attendance',
                            icon: Icons
                                .percent_outlined,
                          ),
                        ];

                        if (compact) {
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: cards
                                .map(
                                  (card) =>
                                      SizedBox(
                                    width:
                                        (constraints.maxWidth -
                                                12) /
                                            2,
                                    child: card,
                                  ),
                                )
                                .toList(),
                          );
                        }

                        return Row(
                          children: [
                            for (var i = 0;
                                i < cards.length;
                                i++) ...[
                              Expanded(
                                child:
                                    cards[i],
                              ),
                              if (i <
                                  cards.length - 1)
                                const SizedBox(
                                  width: 12,
                                ),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Quick Actions',
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
                        final compact =
                            constraints.maxWidth < 700;

                        final actions = [
                          _buildQuickAction(
                            context,
                            icon:
                                Icons.menu_book_outlined,
                            title:
                                'My Subjects',
                            subtitle:
                                'View your assigned subjects.',
                            onPressed:
                                onMySubjects,
                          ),
                          _buildQuickAction(
                            context,
                            icon:
                                Icons.fact_check_outlined,
                            title:
                                'Mark Attendance',
                            subtitle:
                                'Record attendance for a class.',
                            onPressed:
                                onMarkAttendance,
                          ),
                          _buildQuickAction(
                            context,
                            icon:
                                Icons.history_outlined,
                            title:
                                'Attendance History',
                            subtitle:
                                'Review previously marked attendance.',
                            onPressed:
                                onAttendanceHistory,
                          ),
                          _buildQuickAction(
                            context,
                            icon:
                                Icons.edit_note_outlined,
                            title:
                                'Marks Entry',
                            subtitle:
                                'Enter or update assessment marks.',
                            onPressed:
                                onMarksEntry,
                          ),
                          _buildQuickAction(
                            context,
                            icon:
                                Icons.manage_history_outlined,
                            title:
                                'Marks History',
                            subtitle:
                                'Review your marks submissions.',
                            onPressed:
                                onMarksHistory,
                          ),
                          _buildQuickAction(
                            context,
                            icon:
                                Icons.assessment_outlined,
                            title:
                                'Class Results',
                            subtitle:
                                'View class performance and results.',
                            onPressed:
                                onClassResults,
                          ),
                        ];

                        if (compact) {
                          return Column(
                            children: [
                              for (
                                var i = 0;
                                i < actions.length;
                                i++
                              ) ...[
                                actions[i],
                                if (i <
                                    actions.length - 1)
                                  const SizedBox(
                                    height: 10,
                                  ),
                              ],
                            ],
                          );
                        }

                        return GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 3.4,
                          children: actions,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (
                        context,
                        constraints,
                      ) {
                        final compact =
                            constraints.maxWidth < 900;

                        final schedule =
                            _buildTodaySchedule(
                          context,
                        );

                        final pending =
                            _buildPendingMarks(
                          context,
                        );

                        if (compact) {
                          return Column(
                            children: [
                              schedule,
                              const SizedBox(
                                height: 14,
                              ),
                              pending,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: schedule,
                            ),
                            const SizedBox(
                              width: 14,
                            ),
                            Expanded(
                              child: pending,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildAttendanceOverview(
                      context,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FacultyDashboardData {
  final String facultyName;
  final String? departmentName;

  final int assignedSubjects;
  final int assignedSections;
  final int pendingMarksCount;

  final double averageAttendance;
  final int attendanceClassesMarked;
  final int lowAttendanceStudents;

  final List<FacultyDashboardClassItem> todayClasses;
  final List<FacultyDashboardPendingMarkItem> pendingMarks;

  const FacultyDashboardData({
    this.facultyName = 'Faculty',
    this.departmentName,
    this.assignedSubjects = 0,
    this.assignedSections = 0,
    this.pendingMarksCount = 0,
    this.averageAttendance = 0,
    this.attendanceClassesMarked = 0,
    this.lowAttendanceStudents = 0,
    this.todayClasses = const [],
    this.pendingMarks = const [],
  });

  factory FacultyDashboardData.fromJson(
    Map<String, dynamic> json,
  ) {
    return FacultyDashboardData(
      facultyName:
          json['faculty_name']?.toString() ??
              json['name']?.toString() ??
              'Faculty',
      departmentName:
          json['department_name']?.toString(),
      assignedSubjects:
          _toInt(json['assigned_subjects']) ??
              0,
      assignedSections:
          _toInt(json['assigned_sections']) ??
              0,
      pendingMarksCount:
          _toInt(json['pending_marks_count']) ??
              0,
      averageAttendance:
          _toDouble(json['average_attendance']) ??
              0,
      attendanceClassesMarked:
          _toInt(json['attendance_classes_marked']) ??
              0,
      lowAttendanceStudents:
          _toInt(json['low_attendance_students']) ??
              0,
      todayClasses:
          _parseList(
        json['today_classes'],
        FacultyDashboardClassItem.fromJson,
      ),
      pendingMarks:
          _parseList(
        json['pending_marks'],
        FacultyDashboardPendingMarkItem.fromJson,
      ),
    );
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

  static double? _toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }

  static List<T> _parseList<T>(
    dynamic value,
    T Function(Map<String, dynamic>) parser,
  ) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map(
          (item) => parser(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }
}

class FacultyDashboardClassItem {
  final int id;
  final int? subjectId;
  final String subjectCode;
  final String subjectName;
  final String sectionName;
  final String time;
  final String? room;
  final bool isCurrent;

  const FacultyDashboardClassItem({
    required this.id,
    this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.sectionName,
    required this.time,
    this.room,
    this.isCurrent = false,
  });

  factory FacultyDashboardClassItem.fromJson(
    Map<String, dynamic> json,
  ) {
    final subject = json['subject'];
    final section = json['section'];

    return FacultyDashboardClassItem(
      id: _toInt(json['id']) ?? 0,
      subjectId:
          _toInt(json['subject_id']),
      subjectCode:
          subject is Map
              ? subject['code']?.toString() ?? ''
              : json['subject_code']?.toString() ?? '',
      subjectName:
          subject is Map
              ? subject['name']?.toString() ?? ''
              : json['subject_name']?.toString() ?? '',
      sectionName:
          section is Map
              ? section['name']?.toString() ?? ''
              : json['section_name']?.toString() ?? '',
      time:
          json['time']?.toString() ??
              json['class_time']?.toString() ??
              '',
      room:
          json['room']?.toString(),
      isCurrent:
          json['is_current'] == true,
    );
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
}

class FacultyDashboardPendingMarkItem {
  final int id;
  final int? subjectId;
  final String subjectCode;
  final String subjectName;
  final String sectionName;
  final String assessmentName;

  const FacultyDashboardPendingMarkItem({
    required this.id,
    this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.sectionName,
    required this.assessmentName,
  });

  factory FacultyDashboardPendingMarkItem.fromJson(
    Map<String, dynamic> json,
  ) {
    final subject = json['subject'];
    final section = json['section'];
    final assessment = json['assessment'];

    return FacultyDashboardPendingMarkItem(
      id: _toInt(json['id']) ?? 0,
      subjectId:
          _toInt(json['subject_id']),
      subjectCode:
          subject is Map
              ? subject['code']?.toString() ?? ''
              : json['subject_code']?.toString() ?? '',
      subjectName:
          subject is Map
              ? subject['name']?.toString() ?? ''
              : json['subject_name']?.toString() ?? '',
      sectionName:
          section is Map
              ? section['name']?.toString() ?? ''
              : json['section_name']?.toString() ?? '',
      assessmentName:
          assessment is Map
              ? assessment['name']?.toString() ?? ''
              : json['assessment_name']?.toString() ?? '',
    );
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
}