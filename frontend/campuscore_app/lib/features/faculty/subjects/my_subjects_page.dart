import 'package:flutter/material.dart';

class MySubjectsPage extends StatefulWidget {
  final List<MySubjectItem> subjects;
  final bool isLoading;
  final String? errorMessage;

  final Future<void> Function()? onRefresh;
  final void Function(MySubjectItem subject)? onOpenSubject;
  final VoidCallback? onBack;

  const MySubjectsPage({
    super.key,
    this.subjects = const [],
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
    this.onOpenSubject,
    this.onBack,
  });

  @override
  State<MySubjectsPage> createState() =>
      _MySubjectsPageState();
}

class _MySubjectsPageState
    extends State<MySubjectsPage> {
  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(
      _handleSearchChanged,
    );
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(
        _handleSearchChanged,
      )
      ..dispose();

    super.dispose();
  }

  void _handleSearchChanged() {
    final query =
        _searchController.text.trim();

    if (_searchQuery == query) {
      return;
    }

    setState(() {
      _searchQuery = query;
    });
  }

  List<MySubjectItem> get _filteredSubjects {
    final query =
        _searchQuery.toLowerCase();

    if (query.isEmpty) {
      return widget.subjects;
    }

    return widget.subjects.where(
      (subject) {
        return subject.code
                .toLowerCase()
                .contains(query) ||
            subject.name
                .toLowerCase()
                .contains(query) ||
            subject.departmentName
                .toLowerCase()
                .contains(query) ||
            subject.sectionName
                .toLowerCase()
                .contains(query) ||
            subject.academicYear
                .toLowerCase()
                .contains(query);
      },
    ).toList();
  }

  Future<void> _refresh() async {
    if (widget.isLoading ||
        widget.onRefresh == null) {
      return;
    }

    await widget.onRefresh!();
  }

  void _clearSearch() {
    _searchController.clear();
  }

  Widget _buildSearch(
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: TextField(
          controller:
              _searchController,
          enabled:
              !widget.isLoading,
          decoration:
              InputDecoration(
            hintText:
                'Search by subject, code, department or section',
            prefixIcon:
                const Icon(
              Icons.search,
            ),
            suffixIcon:
                _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip:
                            'Clear search',
                        onPressed:
                            _clearSearch,
                        icon:
                            const Icon(
                          Icons.clear,
                        ),
                      ),
            border:
                const OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectCard(
    BuildContext context,
    MySubjectItem subject,
  ) {
    final theme =
        Theme.of(context);

    return Card(
      child: InkWell(
        onTap:
            widget.onOpenSubject == null
                ? null
                : () => widget
                    .onOpenSubject!(
                      subject,
                    ),
        borderRadius:
            BorderRadius.circular(12),
        child: Padding(
          padding:
              const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration:
                        BoxDecoration(
                      color: theme
                          .colorScheme
                          .primaryContainer,
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Icon(
                      Icons
                          .menu_book_outlined,
                      color: theme
                          .colorScheme
                          .primary,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          subject.code,
                          style: theme
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                            color: theme
                                .colorScheme
                                .primary,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          subject.name,
                          maxLines: 2,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style: theme
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons
                        .chevron_right,
                    color: theme
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              const Divider(
                height: 1,
              ),
              const SizedBox(
                height: 14,
              ),
              _buildInfoRow(
                context,
                icon:
                    Icons.credit_card_outlined,
                label: 'Credits',
                value:
                    subject.credits
                        .toString(),
              ),
              const SizedBox(
                height: 9,
              ),
              _buildInfoRow(
                context,
                icon:
                    Icons.school_outlined,
                label: 'Semester',
                value:
                    subject.semester == null
                        ? '—'
                        : 'Semester ${subject.semester}',
              ),
              const SizedBox(
                height: 9,
              ),
              _buildInfoRow(
                context,
                icon:
                    Icons.groups_outlined,
                label: 'Section',
                value:
                    subject.sectionName,
              ),
              const SizedBox(
                height: 9,
              ),
              _buildInfoRow(
                context,
                icon:
                    Icons.account_tree_outlined,
                label: 'Department',
                value:
                    subject.departmentName,
              ),
              if (subject.academicYear
                  .trim()
                  .isNotEmpty) ...[
                const SizedBox(
                  height: 9,
                ),
                _buildInfoRow(
                  context,
                  icon:
                      Icons.calendar_month_outlined,
                  label:
                      'Academic Year',
                  value:
                      subject.academicYear,
                ),
              ],
              if (subject.studentCount !=
                  null) ...[
                const SizedBox(
                  height: 9,
                ),
                _buildInfoRow(
                  context,
                  icon:
                      Icons.people_outline,
                  label:
                      'Students',
                  value: subject
                      .studentCount!
                      .toString(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme =
        Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme
              .colorScheme
              .onSurfaceVariant,
        ),
        const SizedBox(
          width: 9,
        ),
        SizedBox(
          width: 95,
          child: Text(
            label,
            style: theme
                .textTheme
                .bodySmall
                ?.copyWith(
              color: theme
                  .colorScheme
                  .onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Text(
            value.isEmpty
                ? '—'
                : value,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style: theme
                .textTheme
                .bodyMedium
                ?.copyWith(
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final hasSearch =
        _searchQuery.isNotEmpty;

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 48,
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                hasSearch
                    ? Icons
                        .search_off_outlined
                    : Icons
                        .menu_book_outlined,
                size: 54,
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),
              const SizedBox(
                height: 12,
              ),
              Text(
                hasSearch
                    ? 'No subjects match your search'
                    : 'No subjects assigned',
                style: theme
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                hasSearch
                    ? 'Try a different subject, code or section.'
                    : 'Your assigned teaching subjects will appear here.',
                textAlign:
                    TextAlign.center,
                style: theme
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                  color: theme
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
              if (hasSearch) ...[
                const SizedBox(
                  height: 14,
                ),
                OutlinedButton.icon(
                  onPressed:
                      _clearSearch,
                  icon:
                      const Icon(
                    Icons.refresh,
                  ),
                  label:
                      const Text(
                    'Clear search',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final subjects =
        widget.subjects;

    final totalStudents =
        subjects
            .where(
              (subject) =>
                  subject.studentCount !=
                  null,
            )
            .fold<int>(
              0,
              (
                total,
                subject,
              ) =>
                  total +
                  (subject
                          .studentCount ??
                      0),
            );

    final sections = subjects
        .map(
          (subject) =>
              '${subject.sectionName}|${subject.academicYear}',
        )
        .toSet()
        .length;

    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final compact =
            constraints.maxWidth < 700;

        final cards = [
          _buildSummaryCard(
            context,
            title: 'Subjects',
            value:
                subjects.length.toString(),
            icon:
                Icons.menu_book_outlined,
          ),
          _buildSummaryCard(
            context,
            title: 'Sections',
            value:
                sections.toString(),
            icon:
                Icons.groups_outlined,
          ),
          _buildSummaryCard(
            context,
            title: 'Students',
            value:
                totalStudents.toString(),
            icon:
                Icons.people_outline,
          ),
        ];

        if (compact) {
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: cards
                .map(
                  (card) => SizedBox(
                    width:
                        (constraints.maxWidth -
                                10) /
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
                child: cards[i],
              ),
              if (i <
                  cards.length - 1)
                const SizedBox(
                  width: 10,
                ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final theme =
        Theme.of(context);

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration:
                  BoxDecoration(
                color: theme
                    .colorScheme
                    .primaryContainer,
                borderRadius:
                    BorderRadius.circular(
                  11,
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: theme
                    .colorScheme
                    .primary,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    title,
                    style: theme
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                      color: theme
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    value,
                    style: theme
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
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

  Widget _buildError(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            Icon(
              Icons.error_outline,
              color:
                  theme.colorScheme.error,
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                widget.errorMessage!,
                style: theme
                    .textTheme
                    .bodyMedium,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            OutlinedButton(
              onPressed:
                  _refresh,
              child:
                  const Text(
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
    final theme =
        Theme.of(context);

    final subjects =
        _filteredSubjects;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'My Subjects',
        ),
        leading: IconButton(
          tooltip: 'Back',
          onPressed:
              widget.onBack ??
                  () =>
                      Navigator.of(
                        context,
                      ).maybePop(),
          icon:
              const Icon(
            Icons.arrow_back,
          ),
        ),
        actions: [
          IconButton(
            tooltip:
                'Refresh subjects',
            onPressed:
                widget.isLoading
                    ? null
                    : _refresh,
            icon: widget.isLoading
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
          const SizedBox(
            width: 8,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(
                  maxWidth: 1200,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      'My Subjects',
                      style: theme
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'View the subjects and sections assigned to you.',
                      style: theme
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color: theme
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    if (widget.errorMessage !=
                        null) ...[
                      _buildError(
                        context,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                    ],
                    _buildSummary(
                      context,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    _buildSearch(
                      context,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    if (subjects.isEmpty)
                      _buildEmptyState(
                        context,
                      )
                    else
                      LayoutBuilder(
                        builder: (
                          context,
                          constraints,
                        ) {
                          final columns =
                              constraints
                                      .maxWidth >=
                                  1050
                              ? 3
                              : constraints
                                      .maxWidth >=
                                  700
                              ? 2
                              : 1;

                          if (columns == 1) {
                            return Column(
                              children: [
                                for (
                                  var i = 0;
                                  i < subjects.length;
                                  i++
                                ) ...[
                                  _buildSubjectCard(
                                    context,
                                    subjects[i],
                                  ),
                                  if (i <
                                      subjects.length -
                                          1)
                                    const SizedBox(
                                      height: 12,
                                    ),
                                ],
                              ],
                            );
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(),
                            itemCount:
                                subjects.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  columns,
                              crossAxisSpacing:
                                  12,
                              mainAxisSpacing:
                                  12,
                              childAspectRatio:
                                  columns == 3
                                      ? 1.35
                                      : 1.55,
                            ),
                            itemBuilder:
                                (context, index) =>
                                    _buildSubjectCard(
                                      context,
                                      subjects[index],
                                    ),
                          );
                        },
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

class MySubjectItem {
  final int id;
  final String code;
  final String name;
  final dynamic credits;
  final int? semester;
  final String departmentName;
  final String sectionName;
  final String academicYear;
  final int? departmentId;
  final int? sectionId;
  final int? studentCount;

  const MySubjectItem({
    required this.id,
    required this.code,
    required this.name,
    required this.credits,
    this.semester,
    this.departmentName = '',
    this.sectionName = '',
    this.academicYear = '',
    this.departmentId,
    this.sectionId,
    this.studentCount,
  });

  factory MySubjectItem.fromJson(
    Map<String, dynamic> json,
  ) {
    final subject = json['subject'];
    final section = json['section'];
    final department = json['department'];

    return MySubjectItem(
      id: _toInt(json['id']) ??
          _toInt(subject is Map ? subject['id'] : null) ??
          0,
      code: subject is Map
          ? subject['code']?.toString() ?? ''
          : json['code']?.toString() ?? '',
      name: subject is Map
          ? subject['name']?.toString() ?? ''
          : json['name']?.toString() ?? '',
      credits: subject is Map
          ? subject['credits'] ?? 0
          : json['credits'] ?? 0,
      semester: _toInt(
        subject is Map
            ? subject['semester']
            : json['semester'],
      ),
      departmentName: department is Map
          ? department['name']?.toString() ?? ''
          : json['department_name']?.toString() ??
              '',
      sectionName: section is Map
          ? section['name']?.toString() ?? ''
          : json['section_name']?.toString() ?? '',
      academicYear: section is Map
          ? section['academic_year']?.toString() ??
              ''
          : json['academic_year']?.toString() ??
              '',
      departmentId: _toInt(
        json['department_id'] ??
            (department is Map
                ? department['id']
                : null),
      ),
      sectionId: _toInt(
        json['section_id'] ??
            (section is Map
                ? section['id']
                : null),
      ),
      studentCount: _toInt(
        json['student_count'] ??
            json['students_count'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'credits': credits,
      'semester': semester,
      'department_id': departmentId,
      'department_name': departmentName,
      'section_id': sectionId,
      'section_name': sectionName,
      'academic_year': academicYear,
      'student_count': studentCount,
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
}