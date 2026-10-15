// lib/widgets/common/custom_button.dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? loadingColor;
  final double? width;
  final double? height;
  final double fontSize;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final IconData? icon;
  final Widget? child;
  final bool isOutlined;
  final bool isTextButton;
  final Gradient? gradient;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.textColor,
    this.loadingColor,
    this.width,
    this.height,
    this.fontSize = 16,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.icon,
    this.child,
    this.isOutlined = false,
    this.isTextButton = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isDisabled && !isLoading;

    // Determine colors
    final Color bgColor = backgroundColor ?? Theme.of(context).primaryColor;
    final Color textColorFinal = textColor ?? Colors.white;
    final Color loadingColorFinal = loadingColor ?? Colors.white;

    // Build button content
    Widget buttonContent = child ?? _buildButtonContent(textColorFinal);

    // Wrap with loading indicator if needed
    if (isLoading) {
      buttonContent = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(loadingColorFinal),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: loadingColorFinal,
            ),
          ),
        ],
      );
    }

    // Determine button style
    if (isTextButton) {
      return TextButton(
        onPressed: isEnabled ? onPressed : null,
        style: TextButton.styleFrom(
          padding: padding,
          minimumSize: Size(width ?? double.infinity, height ?? 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: buttonContent,
      );
    }

    if (isOutlined) {
      return OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          padding: padding,
          minimumSize: Size(width ?? double.infinity, height ?? 48),
          side: BorderSide(
            color: isEnabled ? bgColor : Colors.grey.shade400,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          backgroundColor: Colors.transparent,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: isEnabled ? bgColor : Colors.grey.shade400,
          ),
        ),
      );
    }

    // Default filled button
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 52,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: gradient ?? (isEnabled ? null : null),
              color: isEnabled
                  ? (gradient != null ? null : bgColor)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: isEnabled ? bgColor : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    loadingColorFinal,
                  ),
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: textColorFinal,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: textColorFinal,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: textColor,
            size: 20,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: textColor,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// Extension for quick button creation
extension CustomButtonExtension on CustomButton {
  // Success button (Green)
  static CustomButton success({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    double? height,
    IconData? icon,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      backgroundColor: Colors.green,
      width: width,
      height: height,
      icon: icon,
    );
  }

  // Danger button (Red)
  static CustomButton danger({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    double? height,
    IconData? icon,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      backgroundColor: Colors.red,
      width: width,
      height: height,
      icon: icon,
    );
  }

  // Warning button (Orange)
  static CustomButton warning({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    double? height,
    IconData? icon,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      backgroundColor: Colors.orange,
      width: width,
      height: height,
      icon: icon,
    );
  }

  // Info button (Blue)
  static CustomButton info({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    double? height,
    IconData? icon,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      backgroundColor: Colors.blue,
      width: width,
      height: height,
      icon: icon,
    );
  }

  // Outlined button
  static CustomButton outlined({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    double? height,
    IconData? icon,
    Color? borderColor,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      isOutlined: true,
      backgroundColor: borderColor ?? Colors.blue,
      textColor: borderColor ?? Colors.blue,
      width: width,
      height: height,
      icon: icon,
    );
  }

  // Text button
  static CustomButton text({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    double? height,
    IconData? icon,
    Color? textColor,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      isTextButton: true,
      textColor: textColor ?? Colors.blue,
      width: width,
      height: height,
      icon: icon,
    );
  }

  // Gradient button
  static CustomButton gradient({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
    double? height,
    IconData? icon,
    required Gradient gradient,
  }) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      gradient: gradient,
      width: width,
      height: height,
      icon: icon,
    );
  }
}