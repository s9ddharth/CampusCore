import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool expands;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final bool dense;
  final bool filled;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final VoidCallback? onTap;
  final bool showCounter;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.expands = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.dense = false,
    this.filled = false,
    this.fillColor,
    this.contentPadding,
    this.inputFormatters,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.onTap,
    this.showCounter = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      obscureText: obscureText,
      expands: expands,
      maxLines: expands ? null : maxLines,
      minLines: expands ? null : minLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      textAlign: textAlign,
      focusNode: focusNode,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      validator: validator,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        prefixText: prefixText,
        suffixText: suffixText,
        filled: filled,
        fillColor: fillColor,
        isDense: dense,
        counterText: showCounter ? null : '',
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2,
          ),
        ),
      ),
    );
  }
}