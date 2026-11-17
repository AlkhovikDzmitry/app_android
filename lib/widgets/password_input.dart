import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'rn_input.dart';

/// Поле пароля с переключателем видимости («глазик»).
///
/// Состояние скрытия живёт внутри виджета: экранам не нужно держать отдельный
/// `bool _obscure` и свой `suffixIcon`. Остальные параметры совпадают с
/// [RNInput], чтобы поле выглядело как любое другое поле формы.
class PasswordInput extends StatefulWidget {
  const PasswordInput({
    super.key,
    required this.controller,
    this.focusNode,
    this.hintText,
    this.prefixIcon,
    this.showError = false,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.autofillHints,
    this.fontSize,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? hintText;
  final IconData? prefixIcon;
  final bool showError;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final double? fontSize;

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return RNInput(
      controller: widget.controller,
      focusNode: widget.focusNode,
      hintText: widget.hintText,
      showError: widget.showError,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      obscureText: _obscure,
      prefixIcon: widget.prefixIcon,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      fontSize: widget.fontSize,
      autocorrect: false,
      enableSuggestions: false,
      suffixIcon: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        icon: Icon(
          _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.textSecondary,
        ),
        tooltip: _obscure ? 'Показать пароль' : 'Скрыть пароль',
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    );
  }
}
