import 'package:flutter/material.dart';

class ResultCalculationDialog extends StatefulWidget {
  final String subjectName;
  final String semester;
  final String academicYear;
  final int studentCount;
  final bool isLoading;
  final Future<void> Function(ResultCalculationOptions options)? onCalculate;

  const ResultCalculationDialog({
    super.key,
    required this.subjectName,
    required this.semester,
    required this.academicYear,
    this.studentCount = 0,
    this.isLoading = false,
    this.onCalculate,
  });

  static Future<void> show({
    required BuildContext context,
    required String subjectName,
    required String semester,
    required String academicYear,
    int studentCount = 0,
    bool isLoading = false,
    Future<void> Function(ResultCalculationOptions options)?
        onCalculate,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: !isLoading,
      builder: (_) => ResultCalculationDialog(
        subjectName: subjectName,
        semester: semester,
        academicYear: academicYear,
        studentCount: studentCount,
        isLoading: isLoading,
        onCalculate: onCalculate,
      ),
    );
  }

  @override
  State<ResultCalculationDialog> createState() =>
      _ResultCalculationDialogState();
}

class _ResultCalculationDialogState
    extends State<ResultCalculationDialog> {
  bool _confirmRelativeGrading = true;
  bool _recalculateExisting = false;
  bool _publishResults = false;

  Future<void> _calculate() async {
    if (widget.isLoading) {
      return;
    }

    final options = ResultCalculationOptions(
      useRelativeGrading: _confirmRelativeGrading,
      recalculateExisting: _recalculateExisting,
      publishResults: _publishResults,
    );

    if (widget.onCalculate != null) {
      await widget.onCalculate!(options);
      return;
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.calculate_outlined,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Calculate Results'),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context,
                      'Subject',
                      widget.subjectName,
                    ),
                    _buildInfoRow(
                      context,
                      'Semester',
                      widget.semester,
                    ),
                    _buildInfoRow(
                      context,
                      'Academic Year',
                      widget.academicYear,
                    ),
                    _buildInfoRow(
                      context,
                      'Students',
                      widget.studentCount.toString(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Calculation Options',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Use relative grading'),
                subtitle: const Text(
                  'Rank eligible students and assign grades '
                  'using the active grading policy.',
                ),
                value: _confirmRelativeGrading,
                onChanged: widget.isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _confirmRelativeGrading = value;
                        });
                      },
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Recalculate existing results'),
                subtitle: const Text(
                  'Replace results already calculated for this '
                  'subject and semester.',
                ),
                value: _recalculateExisting,
                onChanged: widget.isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _recalculateExisting = value;
                        });
                      },
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Publish results'),
                subtitle: const Text(
                  'Make calculated results available to students.',
                ),
                value: _publishResults,
                onChanged: widget.isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _publishResults = value;
                        });
                      },
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Students with missing marks should remain '
                        'incomplete rather than being silently assigned '
                        'a grade.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.isLoading
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: widget.isLoading ? null : _calculate,
          icon: widget.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.calculate_outlined),
          label: Text(
            widget.isLoading ? 'Calculating...' : 'Calculate',
          ),
        ),
      ],
    );
  }
}

class ResultCalculationOptions {
  final bool useRelativeGrading;
  final bool recalculateExisting;
  final bool publishResults;

  const ResultCalculationOptions({
    required this.useRelativeGrading,
    required this.recalculateExisting,
    required this.publishResults,
  });

  Map<String, dynamic> toJson() {
    return {
      'use_relative_grading': useRelativeGrading,
      'recalculate_existing': recalculateExisting,
      'publish_results': publishResults,
    };
  }
}