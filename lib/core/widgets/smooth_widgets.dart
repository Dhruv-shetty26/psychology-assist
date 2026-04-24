import 'dart:ui';

import 'package:flutter/material.dart';

/// A smooth, rounded card widget with optional border and shadow
class SmoothCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double elevation;
  final VoidCallback? onTap;
  final Duration animationDuration;

  const SmoothCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0.5,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(0),
    this.elevation = 0,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBgColor = backgroundColor ?? theme.colorScheme.surface;
    final border = borderColor != null
        ? Border.all(color: borderColor!, width: borderWidth)
        : null;

    final effectiveBorder = border ??
        Border.all(
          color: theme.dividerColor.withOpacity(0.55),
          width: borderWidth,
        );
    final cardWidget = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: cardBgColor.withOpacity(
              theme.brightness == Brightness.dark ? 0.64 : 0.72,
            ),
            border: effectiveBorder,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: elevation > 0
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      blurRadius: elevation,
                      offset: Offset(0, elevation / 2),
                    ),
                  ]
                : [],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    if (onTap == null) {
      return Padding(padding: margin, child: cardWidget);
    }

    return Padding(
      padding: margin,
      child: AnimatedScale(
        scale: 1.0,
        duration: animationDuration,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: cardWidget,
        ),
      ),
    );
  }
}

/// A smooth button with fade and scale animations
class SmoothButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final bool isLoading;
  final bool isEnabled;
  final Widget? icon;
  final bool isOutlined;

  const SmoothButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.isOutlined = false,
  });

  @override
  State<SmoothButton> createState() => _SmoothButtonState();
}

class _SmoothButtonState extends State<SmoothButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = widget.backgroundColor ?? theme.colorScheme.primary;
    final textColor =
        widget.textColor ?? (widget.isOutlined ? bgColor : Colors.white);

    return MouseRegion(
      onEnter: (_) => setState(() => _isPressed = true),
      onExit: (_) => setState(() => _isPressed = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedOpacity(
            opacity: widget.isEnabled ? 1.0 : 0.6,
            duration: const Duration(milliseconds: 200),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isEnabled && !widget.isLoading
                    ? widget.onPressed
                    : null,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.isOutlined ? Colors.transparent : bgColor,
                    border: widget.isOutlined
                        ? Border.all(color: bgColor, width: 1.5)
                        : null,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
                  padding: widget.padding,
                  child: widget.isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(textColor),
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              widget.icon!,
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.label,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Smooth input field with focus animation
class SmoothTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final int maxLines;
  final int minLines;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;

  const SmoothTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.maxLines = 1,
    this.minLines = 1,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
  });

  @override
  State<SmoothTextField> createState() => _SmoothTextFieldState();
}

class _SmoothTextFieldState extends State<SmoothTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.02).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOut,
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            keyboardType: widget.keyboardType,
            onChanged: widget.onChanged,
            validator: widget.validator,
            obscureText: widget.obscureText,
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
