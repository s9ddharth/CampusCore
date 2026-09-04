import 'package:flutter/material.dart';

class AppPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int>? onPageChanged;
  final bool isLoading;
  final int maxVisiblePages;
  final bool showFirstLast;
  final bool showPreviousNext;

  const AppPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPageChanged,
    this.isLoading = false,
    this.maxVisiblePages = 5,
    this.showFirstLast = true,
    this.showPreviousNext = true,
  });

  int get _safeCurrentPage {
    if (totalPages <= 0) {
      return 1;
    }

    return currentPage.clamp(1, totalPages);
  }

  void _goToPage(int page) {
    if (isLoading || onPageChanged == null) {
      return;
    }

    if (page < 1 || page > totalPages) {
      return;
    }

    if (page == _safeCurrentPage) {
      return;
    }

    onPageChanged!(page);
  }

  List<int> _visiblePages() {
    if (totalPages <= 0) {
      return [];
    }

    final visibleCount = maxVisiblePages
        .clamp(3, totalPages);

    if (totalPages <= visibleCount) {
      return List.generate(
        totalPages,
        (index) => index + 1,
      );
    }

    final half = visibleCount ~/ 2;

    int start = _safeCurrentPage - half;
    int end = start + visibleCount - 1;

    if (start < 1) {
      start = 1;
      end = visibleCount;
    }

    if (end > totalPages) {
      end = totalPages;
      start = end - visibleCount + 1;
    }

    return List.generate(
      end - start + 1,
      (index) => start + index,
    );
  }

  Widget _pageButton(
    BuildContext context, {
    required int page,
    required Widget child,
    String? tooltip,
    bool selected = false,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);

    final button = Material(
      color: selected
          ? theme.colorScheme.primary
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled && !isLoading
            ? () => _goToPage(page)
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          child: DefaultTextStyle(
            style: theme.textTheme.bodyMedium!.copyWith(
              color: selected
                  ? theme.colorScheme.onPrimary
                  : enabled
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.45),
              fontWeight: selected
                  ? FontWeight.bold
                  : FontWeight.w500,
            ),
            child: IconTheme(
              data: IconThemeData(
                size: 19,
                color: selected
                    ? theme.colorScheme.onPrimary
                    : enabled
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.45),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );

    if (tooltip == null) {
      return button;
    }

    return Tooltip(
      message: tooltip,
      child: button,
    );
  }

  Widget _ellipsis(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 40,
      child: Center(
        child: Text(
          '...',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }

  List<Widget> _buildPageButtons(BuildContext context) {
    final pages = _visiblePages();
    final widgets = <Widget>[];

    if (pages.isEmpty) {
      return widgets;
    }

    if (pages.first > 1) {
      widgets.add(
        _pageButton(
          context,
          page: 1,
          child: const Text('1'),
          selected: _safeCurrentPage == 1,
        ),
      );

      if (pages.first > 2) {
        widgets.add(_ellipsis(context));
      }
    }

    for (final page in pages) {
      widgets.add(
        _pageButton(
          context,
          page: page,
          child: Text('$page'),
          selected: page == _safeCurrentPage,
        ),
      );
    }

    if (pages.last < totalPages) {
      if (pages.last < totalPages - 1) {
        widgets.add(_ellipsis(context));
      }

      widgets.add(
        _pageButton(
          context,
          page: totalPages,
          child: Text('$totalPages'),
          selected: _safeCurrentPage == totalPages,
        ),
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    final current = _safeCurrentPage;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 520;

          if (compact) {
            return Column(
              children: [
                Text(
                  'Page $current of $totalPages',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showPreviousNext)
                      _pageButton(
                        context,
                        page: current - 1,
                        child: const Icon(
                          Icons.chevron_left,
                        ),
                        tooltip: 'Previous page',
                        enabled: current > 1,
                      ),
                    if (showFirstLast &&
                        current > 1)
                      _pageButton(
                        context,
                        page: 1,
                        child: const Icon(
                          Icons.first_page,
                        ),
                        tooltip: 'First page',
                      ),
                    ..._buildPageButtons(context),
                    if (showFirstLast &&
                        current < totalPages)
                      _pageButton(
                        context,
                        page: totalPages,
                        child: const Icon(
                          Icons.last_page,
                        ),
                        tooltip: 'Last page',
                      ),
                    if (showPreviousNext)
                      _pageButton(
                        context,
                        page: current + 1,
                        child: const Icon(
                          Icons.chevron_right,
                        ),
                        tooltip: 'Next page',
                        enabled: current < totalPages,
                      ),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: Text(
                  'Page $current of $totalPages',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (showFirstLast)
                _pageButton(
                  context,
                  page: 1,
                  child: const Icon(
                    Icons.first_page,
                  ),
                  tooltip: 'First page',
                  enabled: current > 1,
                ),
              if (showPreviousNext)
                _pageButton(
                  context,
                  page: current - 1,
                  child: const Icon(
                    Icons.chevron_left,
                  ),
                  tooltip: 'Previous page',
                  enabled: current > 1,
                ),
              const SizedBox(width: 4),
              ..._buildPageButtons(context),
              const SizedBox(width: 4),
              if (showPreviousNext)
                _pageButton(
                  context,
                  page: current + 1,
                  child: const Icon(
                    Icons.chevron_right,
                  ),
                  tooltip: 'Next page',
                  enabled: current < totalPages,
                ),
              if (showFirstLast)
                _pageButton(
                  context,
                  page: totalPages,
                  child: const Icon(
                    Icons.last_page,
                  ),
                  tooltip: 'Last page',
                  enabled: current < totalPages,
                ),
            ],
          );
        },
      ),
    );
  }
}