import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/text_styles.dart';
import '../../core/theme_styles.dart';

/// A button that shows a loading spinner during async operations.
///
/// ```dart
/// LoadingButton(
///   onPressed: () async {
///     await doSomething();
///   },
///   label: 'Kaydet',
/// )
/// ```
class LoadingButton extends StatefulWidget {
  final Future<void> Function() onPressed;
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final bool enabled;

  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = 52,
    this.borderRadius,
    this.enabled = true,
  });

  /// Destructive variant (red background)
  const LoadingButton.destructive({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.width,
    this.height = 52,
    this.borderRadius,
    this.enabled = true,
  })  : backgroundColor = const Color(0xFFFF3B30),
        foregroundColor = Colors.white;

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (_isLoading || !widget.enabled) return;
    HapticFeedback.lightImpact();

    setState(() => _isLoading = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = widget.backgroundColor ?? theme.primaryColor;
    final fg = widget.foregroundColor ?? Colors.white;
    final radius = widget.borderRadius ?? AppThemeStyles.radius16;
    final isDisabled = _isLoading || !widget.enabled;

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height,
      child: Material(
        color: isDisabled ? bg.withValues(alpha: 0.5) : bg,
        borderRadius: radius,
        elevation: isDisabled ? 0 : 2,
        shadowColor: bg.withValues(alpha: 0.3),
        child: InkWell(
          onTap: isDisabled ? null : _handlePress,
          borderRadius: radius,
          child: Center(
            child: _isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(fg),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: fg, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: AppTextStyles.button.copyWith(
                          color: fg,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
