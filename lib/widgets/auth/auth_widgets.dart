import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/neer_design_system.dart';

// ==========================================
// 1. PREMIUM AUTH HEADER (Logo + Title)
// ==========================================
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: NeerGradients.purplePink,
            boxShadow: [
              BoxShadow(
                color: NeerColors.primary.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.location_on_rounded, size: 36, color: Colors.white),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Visby',
            color: theme.primaryColor,
            fontSize: 48,
            fontWeight: FontWeight.w900,
            letterSpacing: -2.0,
            height: 1.0,
          ),
        ),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: NeerTypography.bodySmall.copyWith(
            color: theme.disabledColor,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 2. NEER AUTH INPUT — Glass with focus glow
// ==========================================
class NeerAuthInput extends StatefulWidget {
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onVisibilityToggle;
  final TextInputType inputType;

  const NeerAuthInput({
    super.key,
    required this.hint,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onVisibilityToggle,
    this.inputType = TextInputType.text,
  });

  @override
  State<NeerAuthInput> createState() => _NeerAuthInputState();
}

class _NeerAuthInputState extends State<NeerAuthInput> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
      if (_focusNode.hasFocus) {
        HapticFeedback.selectionClick();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: _isFocused ? 0.10 : 0.06)
            : Colors.white.withValues(alpha: _isFocused ? 0.45 : 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused
              ? NeerColors.primary.withValues(alpha: 0.40)
              : Colors.white.withValues(alpha: 0.18),
          width: _isFocused ? 1.5 : 1,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: NeerColors.primary.withValues(alpha: 0.15),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.isPassword && !widget.isPasswordVisible,
        keyboardType: widget.inputType,
        style: NeerTypography.bodyLarge,
        cursorColor: theme.primaryColor,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: NeerTypography.bodyLarge.copyWith(
            color: theme.disabledColor.withValues(alpha: 0.5),
          ),
          icon: Icon(
            widget.icon,
            color: _isFocused
                ? theme.primaryColor
                : theme.primaryColor.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    widget.isPasswordVisible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: theme.disabledColor,
                  ),
                  onPressed: widget.onVisibilityToggle,
                )
              : null,
        ),
      ),
    );
  }
}

// ==========================================
// 3. AUTH BUTTON (Gradient Glass Style)
// ==========================================
class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLoading;

  const AuthButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          gradient: isLoading ? null : NeerGradients.purplePink,
          color: isLoading ? theme.disabledColor : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: NeerColors.primary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: isLoading ? null : onTap,
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Text(
                  text,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
        ),
      ),
    );
  }
}
