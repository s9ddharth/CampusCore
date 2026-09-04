import 'package:flutter/material.dart';

class GradingPolicyForm extends StatefulWidget {
  final String? initialName;
  final double initialScale;
  final double initialQualifyingThreshold;
  final double initialTeePassMarks;
  final int initialTopSCount;
  final List<GradeBandData> initialBands;
  final bool isLoading;
  final String submitLabel;
  final Future<void> Function(GradingPolicyFormData data)? onSubmit;

  const GradingPolicyForm({
    super.key,
    this.initialName,
    this.initialScale = 200,
    this.initialQualifyingThreshold = 80,
    this.initialTeePassMarks = 40,
    this.initialTopSCount = 5,
    this.initialBands = const [],
    this.isLoading = false,
    this.submitLabel = 'Save Policy',
    this.onSubmit,
  });

  @override
  State<GradingPolicyForm> createState() => _GradingPolicyFormState();
}

class _GradingPolicyFormState extends State<GradingPolicyForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _scaleController;
  late final TextEditingController _qualifyingController;
  late final TextEditingController _teePassController;
  late final TextEditingController _topSController;

  late List<_EditableBand> _bands;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.initialName ?? '',
    );

    _scaleController = TextEditingController(
      text: _formatNumber(widget.initialScale),
    );

    _qualifyingController = TextEditingController(
      text: _formatNumber(widget.initialQualifyingThreshold),
    );

    _teePassController = TextEditingController(
      text: _formatNumber(widget.initialTeePassMarks),
    );

    _topSController = TextEditingController(
      text: widget.initialTopSCount.toString(),
    );

    _bands = widget.initialBands.isEmpty
        ? [
            _EditableBand(
              grade: 'A',
              minScore: 80,
              maxScore: 100,
              gradePoint: 9,
            ),
            _EditableBand(
              grade: 'B',
              minScore: 70,
              maxScore: 79.99,
              gradePoint: 8,
            ),
            _EditableBand(
              grade: 'C',
              minScore: 60,
              maxScore: 69.99,
              gradePoint: 7,
            ),
            _EditableBand(
              grade: 'D',
              minScore: 50,
              maxScore: 59.99,
              gradePoint: 6,
            ),
            _EditableBand(
              grade: 'E',
              minScore: 40,
              maxScore: 49.99,
              gradePoint: 5,
            ),
          ]
        : widget.initialBands
            .map(
              (band) => _EditableBand(
                grade: band.grade,
                minScore: band.minScore,
                maxScore: band.maxScore,
                gradePoint: band.gradePoint,
              ),
            )
            .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scaleController.dispose();
    _qualifyingController.dispose();
    _teePassController.dispose();
    _topSController.dispose();

    for (final band in _bands) {
      band.dispose();
    }

    super.dispose();
  }

  String _formatNumber(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toString();
  }

  double? _parseDouble(String value) {
    return double.tryParse(value.trim());
  }

  int? _parseInt(String value) {
    return int.tryParse(value.trim());
  }

  String? _requiredNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }

    if (_parseDouble(value) == null) {
      return 'Enter a valid number';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final scale = _parseDouble(_scaleController.text)!;
    final qualifyingThreshold =
        _parseDouble(_qualifyingController.text)!;
    final teePassMarks = _parseDouble(_teePassController.text)!;
    final topSCount = _parseInt(_topSController.text)!;

    if (scale <= 0) {
      _showError('Scale must be greater than 0.');
      return;
    }

    if (qualifyingThreshold < 0 ||
        qualifyingThreshold > scale) {
      _showError(
        'Qualifying threshold must be between 0 and the policy scale.',
      );
      return;
    }

    if (teePassMarks < 0) {
      _showError('TEE pass marks cannot be negative.');
      return;
    }

    if (topSCount < 0) {
      _showError('Top S count cannot be negative.');
      return;
    }

    if (_bands.isEmpty) {
      _showError('Add at least one grade band.');
      return;
    }

    final bands = <GradeBandData>[];

    for (final band in _bands) {
      if (band.gradeController.text.trim().isEmpty) {
        _showError('Every grade band must have a grade.');
        return;
      }

      final minScore = _parseDouble(
        band.minController.text,
      );

      final maxScore = _parseDouble(
        band.maxController.text,
      );

      final gradePoint = _parseDouble(
        band.gradePointController.text,
      );

      if (minScore == null ||
          maxScore == null ||
          gradePoint == null) {
        _showError(
          'Enter valid values for every grade band.',
        );
        return;
      }

      if (minScore < 0 || maxScore < 0) {
        _showError(
          'Grade band scores cannot be negative.',
        );
        return;
      }

      if (minScore > maxScore) {
        _showError(
          'Minimum score cannot be greater than maximum score.',
        );
        return;
      }

      if (gradePoint < 0) {
        _showError(
          'Grade points cannot be negative.',
        );
        return;
      }

      bands.add(
        GradeBandData(
          grade: band.gradeController.text.trim(),
          minScore: minScore,
          maxScore: maxScore,
          gradePoint: gradePoint,
        ),
      );
    }

    final data = GradingPolicyFormData(
      name: _nameController.text.trim(),
      scale: scale,
      qualifyingThreshold: qualifyingThreshold,
      teePassMarks: teePassMarks,
      topSCount: topSCount,
      bands: bands,
    );

    if (widget.onSubmit != null) {
      await widget.onSubmit!(data);
    }
  }

  void _addBand() {
    setState(() {
      _bands.add(
        _EditableBand(
          grade: '',
          minScore: 0,
          maxScore: 0,
          gradePoint: 0,
        ),
      );
    });
  }

  void _removeBand(int index) {
    final band = _bands[index];
    band.dispose();

    setState(() {
      _bands.removeAt(index);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grading Policy',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Policy Name',
              hintText: 'Example: 2026 Relative Grading',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Policy name is required';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 650;

              if (isCompact) {
                return Column(
                  children: [
                    _numberField(
                      controller: _scaleController,
                      label: 'Policy Scale',
                      validator: _requiredNumber,
                    ),
                    const SizedBox(height: 16),
                    _numberField(
                      controller: _qualifyingController,
                      label: 'Qualifying Threshold',
                      validator: _requiredNumber,
                    ),
                    const SizedBox(height: 16),
                    _numberField(
                      controller: _teePassController,
                      label: 'TEE Pass Marks',
                      validator: _requiredNumber,
                    ),
                    const SizedBox(height: 16),
                    _integerField(
                      controller: _topSController,
                      label: 'Top S Count',
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _numberField(
                      controller: _scaleController,
                      label: 'Policy Scale',
                      validator: _requiredNumber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _numberField(
                      controller: _qualifyingController,
                      label: 'Qualifying Threshold',
                      validator: _requiredNumber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _numberField(
                      controller: _teePassController,
                      label: 'TEE Pass Marks',
                      validator: _requiredNumber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _integerField(
                      controller: _topSController,
                      label: 'Top S Count',
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: Text(
                  'Grade Bands',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: widget.isLoading ? null : _addBand,
                icon: const Icon(Icons.add),
                label: const Text('Add Band'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (_bands.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'No grade bands added.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ...List.generate(
              _bands.length,
              (index) => _buildBandRow(
                context,
                index,
                _bands[index],
              ),
            ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: widget.isLoading ? null : _submit,
              icon: widget.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                widget.isLoading
                    ? 'Saving...'
                    : widget.submitLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  Widget _integerField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Required';
        }

        final parsed = int.tryParse(value.trim());

        if (parsed == null) {
          return 'Enter a whole number';
        }

        if (parsed < 0) {
          return 'Cannot be negative';
        }

        return null;
      },
    );
  }

  Widget _buildBandRow(
    BuildContext context,
    int index,
    _EditableBand band,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 600;

          final fields = [
            Expanded(
              child: _bandField(
                controller: band.gradeController,
                label: 'Grade',
              ),
            ),
            Expanded(
              child: _bandNumberField(
                controller: band.minController,
                label: 'Min Score',
              ),
            ),
            Expanded(
              child: _bandNumberField(
                controller: band.maxController,
                label: 'Max Score',
              ),
            ),
            Expanded(
              child: _bandNumberField(
                controller: band.gradePointController,
                label: 'Grade Point',
              ),
            ),
          ];

          if (isCompact) {
            return Column(
              children: [
                Row(
                  children: [
                    fields[0],
                    const SizedBox(width: 12),
                    fields[1],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    fields[2],
                    const SizedBox(width: 12),
                    fields[3],
                    const SizedBox(width: 12),
                    IconButton(
                      tooltip: 'Remove band',
                      onPressed: widget.isLoading
                          ? null
                          : () => _removeBand(index),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              fields[0],
              const SizedBox(width: 12),
              fields[1],
              const SizedBox(width: 12),
              fields[2],
              const SizedBox(width: 12),
              fields[3],
              const SizedBox(width: 12),
              IconButton(
                tooltip: 'Remove band',
                onPressed: widget.isLoading
                    ? null
                    : () => _removeBand(index),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _bandField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _bandNumberField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

class GradingPolicyFormData {
  final String name;
  final double scale;
  final double qualifyingThreshold;
  final double teePassMarks;
  final int topSCount;
  final List<GradeBandData> bands;

  const GradingPolicyFormData({
    required this.name,
    required this.scale,
    required this.qualifyingThreshold,
    required this.teePassMarks,
    required this.topSCount,
    required this.bands,
  });
}

class GradeBandData {
  final String grade;
  final double minScore;
  final double maxScore;
  final double gradePoint;

  const GradeBandData({
    required this.grade,
    required this.minScore,
    required this.maxScore,
    required this.gradePoint,
  });
}

class _EditableBand {
  final TextEditingController gradeController;
  final TextEditingController minController;
  final TextEditingController maxController;
  final TextEditingController gradePointController;

  _EditableBand({
    required String grade,
    required double minScore,
    required double maxScore,
    required double gradePoint,
  })  : gradeController = TextEditingController(text: grade),
        minController = TextEditingController(
          text: minScore.toString(),
        ),
        maxController = TextEditingController(
          text: maxScore.toString(),
        ),
        gradePointController = TextEditingController(
          text: gradePoint.toString(),
        );

  void dispose() {
    gradeController.dispose();
    minController.dispose();
    maxController.dispose();
    gradePointController.dispose();
  }
}