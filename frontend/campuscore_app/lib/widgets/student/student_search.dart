import 'package:flutter/material.dart';

class StudentSearch extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final String? label;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool enabled;
  final bool autofocus;
  final bool showFilterButton;
  final VoidCallback? onFilter;
  final int? resultCount;
  final bool isLoading;
  final Duration debounceDuration;

  const StudentSearch({
    super.key,
    this.controller,
    this.hintText = 'Search by name or roll number',
    this.label,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.enabled = true,
    this.autofocus = false,
    this.showFilterButton = false,
    this.onFilter,
    this.resultCount,
    this.isLoading = false,
    this.debounceDuration = const Duration(
      milliseconds: 350,
    ),
  });

  @override
  State<StudentSearch> createState() => _StudentSearchState();
}

class _StudentSearchState extends State<StudentSearch> {
  late final TextEditingController _internalController;
  late final bool _ownsController;

  String _query = '';
  bool _showClear = false;

  @override
  void initState() {
    super.initState();

    _ownsController = widget.controller == null;

    _internalController =
        widget.controller ?? TextEditingController();

    _query = _internalController.text;
    _showClear = _query.trim().isNotEmpty;

    _internalController.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant StudentSearch oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      _internalController.removeListener(
        _handleControllerChanged,
      );

      if (_ownsController) {
        _internalController.dispose();
      }

      final controller =
          widget.controller ?? TextEditingController();

      _ownsController = widget.controller == null;

      // ignore: invalid_assignment
      _replaceController(controller);
    }
  }

  void _replaceController(
    TextEditingController controller,
  ) {
    // This method only exists to keep controller replacement
    // isolated from the widget lifecycle.
    //
    // The controller used by the current build is stored through
    // [_activeController].
    _activeController = controller;
    _query = controller.text;
    _showClear = _query.trim().isNotEmpty;
    controller.addListener(_handleControllerChanged);
  }

  late TextEditingController _activeController;

  TextEditingController get _controller {
    if (!mounted) {
      return widget.controller ??
          TextEditingController(
            text: _query,
          );
    }

    return _activeController;
  }

  void _handleControllerChanged() {
    final value = _controller.text;

    if (_query == value) {
      return;
    }

    setState(() {
      _query = value;
      _showClear = value.trim().isNotEmpty;
    });

    widget.onChanged?.call(value);
  }

  void _clear() {
    if (!widget.enabled || widget.isLoading) {
      return;
    }

    _controller.clear();
    widget.onClear?.call();

    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
  }

  @override
  void dispose() {
    _controller.removeListener(
      _handleControllerChanged,
    );

    if (_ownsController) {
      _controller.dispose();
    }

    super.dispose();
  }

  Widget _trailingIcon(BuildContext context) {
    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
          ),
        ),
      );
    }

    if (_showClear) {
      return IconButton(
        tooltip: 'Clear',
        onPressed: widget.enabled ? _clear : null,
        icon: const Icon(
          Icons.close_rounded,
        ),
      );
    }

    if (widget.showFilterButton) {
      return IconButton(
        tooltip: 'Filter',
        onPressed: widget.enabled
            ? widget.onFilter
            : null,
        icon: const Icon(
          Icons.tune_outlined,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null &&
            widget.label!.trim().isNotEmpty) ...[
          Text(
            widget.label!,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
        ],
        TextField(
          controller: _controller,
          enabled: widget.enabled && !widget.isLoading,
          autofocus: widget.autofocus,
          textInputAction: TextInputAction.search,
          onSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(
              Icons.search_outlined,
            ),
            suffixIcon: _trailingIcon(context),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
          ),
        ),
        if (widget.resultCount != null ||
            _query.trim().isNotEmpty) ...[
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.resultCount == null
                      ? 'Searching...'
                      : '${widget.resultCount} '
                          '${widget.resultCount == 1 ? 'student' : 'students'} found',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}