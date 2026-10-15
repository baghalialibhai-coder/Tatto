// lib/widgets/common/custom_text_field.dart
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final IconData? icon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final String? initialValue;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Function? onTap;
  final FormFieldValidator<String>? validator;
  final InputDecoration? decoration;
  final EdgeInsetsGeometry? contentPadding;
  final double borderRadius;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusBorderColor;
  final Color? errorBorderColor;
  final bool showCounter;

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.icon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.decoration,
    this.contentPadding,
    this.borderRadius = 12,
    this.fillColor,
    this.borderColor,
    this.focusBorderColor,
    this.errorBorderColor,
    this.showCounter = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = false;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final Color borderColor = _getBorderColor(hasError);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label.isNotEmpty) ...[
          Row(
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: hasError ? Colors.red : Colors.grey.shade700,
                ),
              ),
              if (widget.validator != null)
                const Text(
                  ' *',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          const SizedBox(height: 6),
        ],

        // Text Field
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          obscureText: _isObscured,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: () {
            if (widget.onTap != null) widget.onTap!();
          },
          validator: widget.validator,
          decoration: widget.decoration ?? _buildDecoration(borderColor, hasError),
          onTapOutside: (event) => FocusScope.of(context).unfocus(),
          style: TextStyle(
            fontSize: 16,
            color: widget.enabled ? Colors.black : Colors.grey.shade600,
          ),
          cursorColor: Colors.blue,
        ),

        // Helper text
        if (widget.helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],

        // Error text
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _buildDecoration(Color borderColor, bool hasError) {
    final bool hasIcon = widget.icon != null;
    final bool hasSuffixIcon = widget.suffixIcon != null ||
        widget.obscureText ||
        (widget.maxLength != null && widget.showCounter);

    return InputDecoration(
      hintText: widget.hint,
      hintStyle: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade400,
      ),
      errorText: null, // We handle error text manually
      errorStyle: const TextStyle(height: 0),
      counterText: widget.maxLength != null && widget.showCounter ? null : '',
      filled: true,
      fillColor: widget.fillColor ?? Colors.grey.shade50,
      isDense: widget.maxLines == 1,
      contentPadding: widget.contentPadding ??
          EdgeInsets.symmetric(
            horizontal: 16,
            vertical: widget.maxLines > 1 ? 12 : 14,
          ),
      prefixIcon: hasIcon
          ? Icon(
        widget.icon,
        color: hasError ? Colors.red : Colors.grey.shade600,
        size: 22,
      )
          : null,
      suffixIcon: hasSuffixIcon
          ? _buildSuffixIcon(hasError)
          : null,
      border: _buildBorder(borderColor, false),
      enabledBorder: _buildBorder(borderColor, false),
      focusedBorder: _buildBorder(_getFocusBorderColor(), true),
      errorBorder: _buildBorder(Colors.red, false),
      focusedErrorBorder: _buildBorder(Colors.red, true),
      disabledBorder: _buildBorder(Colors.grey.shade300, false),
    );
  }

  Widget? _buildSuffixIcon(bool hasError) {
    final List<Widget> children = [];

    // Obscure toggle for password fields
    if (widget.obscureText) {
      children.add(
        IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility_off : Icons.visibility,
            color: hasError ? Colors.red : Colors.grey.shade600,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured;
            });
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          splashRadius: 20,
        ),
      );
    }

    // Custom suffix icon
    if (widget.suffixIcon != null) {
      children.add(
        IconButton(
          icon: Icon(
            widget.suffixIcon,
            color: hasError ? Colors.red : Colors.grey.shade600,
            size: 20,
          ),
          onPressed: widget.onSuffixIconTap,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          splashRadius: 20,
        ),
      );
    }

    // Counter
    if (widget.maxLength != null && widget.showCounter) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Builder(
            builder: (context) {
              final String currentText = widget.controller?.text ?? '';
              return Text(
                '${currentText.length}/${widget.maxLength}',
                style: TextStyle(
                  fontSize: 12,
                  color: hasError ? Colors.red : Colors.grey.shade500,
                ),
              );
            },
          ),
        ),
      );
    }

    if (children.isEmpty) return null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  InputBorder _buildBorder(Color color, bool isFocused) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      borderSide: BorderSide(
        color: color,
        width: isFocused ? 2 : 1.5,
      ),
    );
  }

  Color _getBorderColor(bool hasError) {
    if (hasError) return Colors.red;
    if (_hasFocus) return _getFocusBorderColor();
    if (!widget.enabled) return Colors.grey.shade300;
    return widget.borderColor ?? Colors.grey.shade300;
  }

  Color _getFocusBorderColor() {
    return widget.focusBorderColor ?? Colors.blue.shade700;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update counter when text changes
    if (widget.controller != null && widget.maxLength != null) {
      widget.controller!.addListener(() {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller != null && widget.maxLength != null) {
      widget.controller!.removeListener(() {});
    }
    super.dispose();
  }
}

// Extension for easy validation
extension CustomTextFieldValidation on CustomTextField {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Field'} is required';
    }
    return null;
  }

  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Number is required';
    }
    if (double.tryParse(value) == null) {
      return 'Enter a valid number';
    }
    return null;
  }
}