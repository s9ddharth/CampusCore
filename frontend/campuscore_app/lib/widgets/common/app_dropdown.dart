import 'package:flutter/material.dart';

class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<AppDropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  final bool isDense;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final double? width;

  const AppDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.isDense = false,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final dropdown = DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      isDense: isDense,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
      ),
      dropdownColor: theme.colorScheme.surface,
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item.value,
              enabled: item.enabled,
              child: Row(
                children: [
                  if (item.icon != null) ...[
                    Icon(
                      item.icon,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
      validator: validator,
    );

    if (width == null) {
      return dropdown;
    }

    return SizedBox(
      width: width,
      child: dropdown,
    );
  }
}

class AppDropdownItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final bool enabled;

  const AppDropdownItem({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });
}