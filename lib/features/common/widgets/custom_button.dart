import 'package:flutter/material.dart';

enum ButtonType {
  primary,
  secondary,
  outline,
  text,
}

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final ButtonType type;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final IconData? icon;
  final double iconSize;
  final double iconSpacing;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.icon,
    this.iconSize = 20,
    this.iconSpacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Define button styles based on type
    ButtonStyle getButtonStyle() {
      switch (type) {
        case ButtonType.primary:
          return ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: padding ??
                const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ),
          );
        case ButtonType.secondary:
          return ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            padding: padding ??
                const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ),
          );
        case ButtonType.outline:
          return OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            side: BorderSide(color: theme.colorScheme.primary),
            padding: padding ??
                const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ),
          );
        case ButtonType.text:
          return TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            padding: padding ??
                const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ),
          );
      }
    }

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null && !isLoading) ...[
          Icon(icon, size: iconSize),
          SizedBox(width: iconSpacing),
        ],
        Text(
          text,
          style: theme.textTheme.labelLarge?.copyWith(
            color: type == ButtonType.outline || type == ButtonType.text
                ? theme.colorScheme.primary
                : null,
          ),
        ),
      ],
    );

    if (isLoading) {
      buttonChild = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == ButtonType.outline || type == ButtonType.text
                ? theme.colorScheme.primary
                : theme.colorScheme.onPrimary,
          ),
        ),
      );
    }

    Widget button;
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
        button = ElevatedButton(
          onPressed: isEnabled && !isLoading ? onPressed : null,
          style: getButtonStyle(),
          child: buttonChild,
        );
        break;
      case ButtonType.outline:
        button = OutlinedButton(
          onPressed: isEnabled && !isLoading ? onPressed : null,
          style: getButtonStyle(),
          child: buttonChild,
        );
        break;
      case ButtonType.text:
        button = TextButton(
          onPressed: isEnabled && !isLoading ? onPressed : null,
          style: getButtonStyle(),
          child: buttonChild,
        );
        break;
    }

    if (width != null || height != null) {
      button = SizedBox(
        width: width,
        height: height,
        child: button,
      );
    }

    return button;
  }
}
