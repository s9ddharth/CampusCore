import 'package:flutter/material.dart';

class FacultyClassResultsPage extends StatefulWidget {
  final List<FacultyClassResultItem> results;
  final List<FacultyResultSubjectOption> subjects;

  final bool isLoading;
  final String? errorMessage;

  final Future<void> Function()? onRefresh;
  final Future<void> Function(int subjectId)? onLoadResults;

  final VoidCallback? onBack;

  const FacultyClassResultsPage({
    super.key,
    this.results = const [],
    this.subjects = const [],
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
    this.onLoadResults,
    this.onBack,
  });

  @override
  State<FacultyClassResultsPage> createState() =>
      _FacultyClassResultsPageState();
}

class _FacultyClassResultsPageState
    extends State<FacultyClassResultsPage> {
  int? _selectedSubjectId;

  String _searchQuery = '';
  String _gradeFilter = 'ALL';

  final TextEditingController _searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    _selectedSubjectId = widget.subjects.isNotEmpty
        ? widget.subjects.first.id
        : null;

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

  @override
  void didUpdateWidget(
    covariant FacultyClassResultsPage oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (_selectedSubjectId != null &&
        !widget.subjects.any(
          (subject) => subject.id == _selectedSubjectId,
        )) {
      _selectedSubjectId = widget.subjects.isEmpty
          ? null
          : widget.subjects.first.id;
    }

    if (_selectedSubjectId == null &&
        widget.subjects.isNotEmpty) {
      _selectedSubjectId = widget.subjects.first.id;
    }
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

  Future<void> _loadSelectedSubject() async {
    if (_selectedSubjectId == null ||
        widget.onLoadResults == null) {
      return;
    }

    await widget.onLoadResults!(
      _selectedSubjectId!,
    );
  }

  Future<void> _onSubjectChanged(
    int? value,
  ) async {
    if (value == null) {
      return;
    }

    setState(() {
      _selectedSubjectId = value;
      _searchController.clear();
      _gradeFilter = 'ALL';
    });

    if (widget.onLoadResults != null) {
      await widget.onLoadResults!(
        value,
      );
    }
  }

  Future<void> _refresh() async {
    if (widget.isLoading ||
        widget.onRefresh == null) {
      return;
    }

    await widget.onRefresh!();
  }

  void _clearFilters() {
    _searchController.clear();

    setState(() {
      _gradeFilter = 'ALL';
    });
  }

  List<FacultyClassResultItem> get _filteredResults {
    final query =
        _searchQuery.toLowerCase();

    return widget.results.where(
      (result) {
        final matchesSearch =
            query.isEmpty ||
                result.studentName
                    .toLowerCase()
                    .contains(query) ||
                result.rollNo
                    .toLowerCase()
                    .contains(query);

        final matchesGrade =
            _gradeFilter == 'ALL' ||
                result.grade.toUpperCase() ==
                    _gradeFilter;

        return matchesSearch &&
            matchesGrade;
      },
    ).toList();
  }

  double get _classAverage {
    final results = widget.results;

    if (results.isEmpty) {
      return 0;
    }

    final total = results.fold<double>(
      0,
      (sum, result) => sum + result.totalScore,
    );

    return total / results.length;
  }

  double get _passPercentage {
    final results = widget.results;

    if (results.isEmpty) {
      return 0;
    }

    final passed = results.where(
      (result) => !result.isFail,
    ).length;

    return passed / results.length * 100;
  }

  int get _failedCount {
    return widget.results
        .where(
          (result) => result.isFail,
        )
        .length;
  }

  Map<String, int> get _gradeDistribution {
    final distribution = <String, int>{
      'S': 0,
      'A': 0,
      'B': 0,
      'C': 0,
      'D': 0,
      'E': 0,
      'F': 0,
    };

    for (final result in widget.results) {
      final grade =
          result.grade.toUpperCase();

      if (distribution.containsKey(grade)) {
        distribution[grade] =
            distribution[grade]! + 1;
      }
    }

    return distribution;
  }

  Widget _buildSubjectSelector(
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final compact =
                constraints.maxWidth < 700;

            final subjectDropdown =
                DropdownButtonFormField<int>(
              initialValue: _selectedSubjectId,
              decoration:
                  const InputDecoration(
                labelText: 'Subject',
                prefixIcon:
                    Icon(
                  Icons.menu_book_outlined,
                ),
                border:
                    OutlineInputBorder(),
              ),
              items: widget.subjects
                  .map(
                    (subject) =>
                        DropdownMenuItem<int>(
                      value: subject.id,
                      child: Text(
                        '${subject.code} - ${subject.name}',
                        overflow:
                            TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged:
                  widget.isLoading
                      ? null
                      : _onSubjectChanged,
            );

            final refreshButton =
                OutlinedButton.icon(
              onPressed:
                  widget.isLoading
                      ? null
                      : _loadSelectedSubject,
              icon:
                  const Icon(
                Icons.refresh,
              ),
              label:
                  const Text(
                'Reload',
              ),
            );

            if (compact) {
              return Column(
                children: [
                  subjectDropdown,
                  const SizedBox(
                    height: 12,
                  ),
                  Align(
                    alignment:
                        Alignment.centerRight,
                    child:
                        refreshButton,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child:
                      subjectDropdown,
                ),
                const SizedBox(
                  width: 12,
                ),
                refreshButton,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchFilters(
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final compact =
                constraints.maxWidth < 750;

            final search =
                TextField(
              controller:
                  _searchController,
              enabled:
                  !widget.isLoading,
              decoration:
                  InputDecoration(
                hintText:
                    'Search student or roll number',
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
                            onPressed: () {
                              _searchController
                                  .clear();
                            },
                            icon:
                                const Icon(
                              Icons.clear,
                            ),
                          ),
                border:
                    const OutlineInputBorder(),
              ),
            );

            final grade =
                DropdownButtonFormField<String>(
              initialValue:
                  _gradeFilter,
              decoration:
                  const InputDecoration(
                labelText:
                    'Grade',
                prefixIcon:
                    Icon(
                  Icons
                      .grade_outlined,
                ),
                border:
                    OutlineInputBorder(),
              ),
              items:
                  const [
                DropdownMenuItem(
                  value: 'ALL',
                  child:
                      Text('All grades'),
                ),
                DropdownMenuItem(
                  value: 'S',
                  child:
                      Text('S'),
                ),
                DropdownMenuItem(
                  value: 'A',
                  child:
                      Text('A'),
                ),
                DropdownMenuItem(
                  value: 'B',
                  child:
                      Text('B'),
                ),
                DropdownMenuItem(
                  value: 'C',
                  child:
                      Text('C'),
                ),
                DropdownMenuItem(
                  value: 'D',
                  child:
                      Text('D'),
                ),
                DropdownMenuItem(
                  value: 'E',
                  child:
                      Text('E'),
                ),
                DropdownMenuItem(
                  value: 'F',
                  child:
                      Text('F'),
                ),
              ],
              onChanged:
                  widget.isLoading
                      ? null
                      : (value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            _gradeFilter = value;
                          });
                        },
            );

            final clear =
                OutlinedButton.icon(
              onPressed:
                  widget.isLoading
                      ? null
                      : _clearFilters,
              icon:
                  const Icon(
                Icons
                    .filter_alt_off_outlined,
              ),
              label:
                  const Text(
                'Clear',
              ),
            );

            if (compact) {
              return Column(
                children: [
                  search,
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: grade,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      clear,
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: search,
                ),
                const SizedBox(
                  width: 12,
                ),
                SizedBox(
                  width: 190,
                  child: grade,
                ),
                const SizedBox(
                  width: 12,
                ),
                clear,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricCard(
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
              width: 11,
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

  Widget _buildMetrics(
    BuildContext context,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final compact =
            constraints.maxWidth < 800;

        final cards = [
          _buildMetricCard(
            context,
            title: 'Students',
            value:
                widget.results.length.toString(),
            icon:
                Icons.people_outline,
          ),
          _buildMetricCard(
            context,
            title: 'Class Average',
            value:
                _classAverage.toStringAsFixed(2),
            icon:
                Icons.analytics_outlined,
          ),
          _buildMetricCard(
            context,
            title: 'Pass Rate',
            value:
                '${_passPercentage.toStringAsFixed(1)}%',
            icon:
                Icons.check_circle_outline,
          ),
          _buildMetricCard(
            context,
            title: 'Failures',
            value:
                _failedCount.toString(),
            icon:
                Icons.warning_amber_outlined,
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

  Widget _buildGradeDistribution(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final distribution =
        _gradeDistribution;

    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Grade Distribution',
              style: theme
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  distribution.entries
                      .map(
                        (entry) =>
                            Container(
                          width: 58,
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 10,
                          ),
                          decoration:
                              BoxDecoration(
                            color: theme
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              10,
                            ),
                          ),
                          child:
                              Column(
                            children: [
                              Text(
                                entry.key,
                                style: theme
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Text(
                                entry.value
                                    .toString(),
                                style: theme
                                    .textTheme
                                    .bodySmall,
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeBadge(
    BuildContext context,
    String grade,
  ) {
    final theme =
        Theme.of(context);

    final normalized =
        grade.toUpperCase();

    final isFail =
        normalized == 'F';

    return Container(
      width: 34,
      height: 30,
      alignment:
          Alignment.center,
      decoration:
          BoxDecoration(
        color: isFail
            ? theme
                .colorScheme
                .errorContainer
            : theme
                .colorScheme
                .primaryContainer,
        borderRadius:
            BorderRadius.circular(
          8,
        ),
      ),
      child: Text(
        normalized,
        style: theme
            .textTheme
            .labelLarge
            ?.copyWith(
          color: isFail
              ? theme
                  .colorScheme
                  .onErrorContainer
              : theme
                  .colorScheme
                  .primary,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildResultTable(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final results =
        _filteredResults;

    if (results.isEmpty) {
      return Card(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 44,
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons
                      .assessment_outlined,
                  size: 52,
                  color: theme
                      .colorScheme
                      .onSurfaceVariant,
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  'No results found',
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
                  'Try changing the search or grade filter.',
                  style: theme
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color: theme
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      clipBehavior:
          Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection:
            Axis.horizontal,
        child: DataTable(
          headingRowColor:
              WidgetStatePropertyAll(
            theme.colorScheme
                .surfaceContainerHighest
                .withValues(
              alpha: 0.55,
            ),
          ),
          horizontalMargin:
              18,
          columnSpacing:
              30,
          columns: const [
            DataColumn(
              label:
                  Text('Rank'),
            ),
            DataColumn(
              label:
                  Text('Student'),
            ),
            DataColumn(
              label:
                  Text('Score'),
            ),
            DataColumn(
              label:
                  Text('Grade'),
            ),
            DataColumn(
              label:
                  Text('Grade Point'),
            ),
            DataColumn(
              label:
                  Text('Status'),
            ),
          ],
          rows: results
              .asMap()
              .entries
              .map(
                (entry) {
                  final index =
                      entry.key;

                  final result =
                      entry.value;

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          result.rank == null
                              ? (index + 1)
                                  .toString()
                              : result.rank!
                                  .toString(),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 240,
                          child:
                              Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                result
                                    .studentName,
                                maxLines:
                                    1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              ),
                              Text(
                                result
                                    .rollNo,
                                style: theme
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  color: theme
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          result
                              .totalScore
                              .toStringAsFixed(
                            2,
                          ),
                        ),
                      ),
                      DataCell(
                        _buildGradeBadge(
                          context,
                          result.grade,
                        ),
                      ),
                      DataCell(
                        Text(
                          result
                              .gradePoint
                              .toStringAsFixed(
                            2,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          result
                              .resultStatus,
                          style: theme
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            color: result.isFail
                                ? theme
                                    .colorScheme
                                    .error
                                : theme
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )
              .toList(),
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
              onPressed: _refresh,
              child:
                  const Text('Retry'),
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

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Class Results'),
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
                'Refresh results',
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
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 1250,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    'Class Results',
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
                    'Review the calculated results for your assigned subject.',
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
                  _buildSubjectSelector(
                    context,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  _buildMetrics(
                    context,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  _buildGradeDistribution(
                    context,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  _buildSearchFilters(
                    context,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  _buildResultTable(
                    context,
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

class FacultyClassResultItem {
  final int studentId;
  final String studentName;
  final String rollNo;

  final double totalScore;
  final String grade;
  final double gradePoint;

  final String resultStatus;
  final int? rank;

  const FacultyClassResultItem({
    required this.studentId,
    required this.studentName,
    required this.rollNo,
    required this.totalScore,
    required this.grade,
    required this.gradePoint,
    required this.resultStatus,
    this.rank,
  });

  bool get isFail {
    final normalized =
        resultStatus.toUpperCase();

    return normalized == 'FAIL' ||
        grade.toUpperCase() == 'F';
  }

  factory FacultyClassResultItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return FacultyClassResultItem(
      studentId:
          _toInt(json['student_id']) ??
              0,
      studentName:
          json['student_name']
                  ?.toString() ??
              json['name']
                  ?.toString() ??
              '',
      rollNo:
          json['roll_no']
                  ?.toString() ??
              '',
      totalScore:
          _toDouble(
                json['total_score'],
              ) ??
              0,
      grade:
          json['grade']
                  ?.toString() ??
              '',
      gradePoint:
          _toDouble(
                json['grade_point'],
              ) ??
              0,
      resultStatus:
          json['result_status']
                  ?.toString() ??
              'UNKNOWN',
      rank:
          _toInt(json['rank']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'roll_no': rollNo,
      'total_score': totalScore,
      'grade': grade,
      'grade_point': gradePoint,
      'result_status': resultStatus,
      'rank': rank,
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
}

class FacultyResultSubjectOption {
  final int id;
  final String code;
  final String name;

  const FacultyResultSubjectOption({
    required this.id,
    required this.code,
    required this.name,
  });
}