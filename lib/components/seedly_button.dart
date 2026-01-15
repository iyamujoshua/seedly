import 'package:flutter/material.dart';

/// Button variants for different visual styles
enum SeedlyButtonVariant { primary, secondary, outline, ghost, danger }

/// Button sizes
enum SeedlyButtonSize { small, medium, large }

/// A customizable, reusable button component for the Seedly app.
///
/// Supports multiple variants (primary, secondary, outline, ghost, danger),
/// sizes (small, medium, large), loading states, icons, and full-width mode.
class SeedlyButton extends StatefulWidget {
  const SeedlyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = SeedlyButtonVariant.primary,
    this.size = SeedlyButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.isFullWidth = false,
    this.prefixIcon,
    this.suffixIcon,
    this.borderRadius,
  });

  /// The button label text
  final String label;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button variant style
  final SeedlyButtonVariant variant;

  /// Button size
  final SeedlyButtonSize size;

  /// Show loading spinner
  final bool isLoading;

  /// Disable the button
  final bool isDisabled;

  /// Make button full width
  final bool isFullWidth;

  /// Icon to show before the label
  final IconData? prefixIcon;

  /// Icon to show after the label
  final IconData? suffixIcon;

  /// Custom border radius
  final double? borderRadius;

  @override
  State<SeedlyButton> createState() => _SeedlyButtonState();
}

class _SeedlyButtonState extends State<SeedlyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _isEnabled => !widget.isDisabled && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getButtonColors(theme);
    final dimensions = _getButtonDimensions();

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) =>
          Transform.scale(scale: _scaleAnimation.value, child: child),
      child: SizedBox(
        width: widget.isFullWidth ? double.infinity : null,
        height: dimensions.height,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isEnabled ? _handlePress : null,
            onTapDown: _isEnabled
                ? (_) => _animationController.forward()
                : null,
            onTapUp: _isEnabled ? (_) => _animationController.reverse() : null,
            onTapCancel: _isEnabled
                ? () => _animationController.reverse()
                : null,
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? dimensions.borderRadius,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _isEnabled
                    ? colors.background
                    : colors.disabledBackground,
                borderRadius: BorderRadius.circular(
                  widget.borderRadius ?? dimensions.borderRadius,
                ),
                border: colors.borderColor != null
                    ? Border.all(
                        color: _isEnabled
                            ? colors.borderColor!
                            : colors.disabledBorderColor ?? colors.borderColor!,
                        width: 1.5,
                      )
                    : null,
                boxShadow:
                    _isEnabled && widget.variant == SeedlyButtonVariant.primary
                    ? [
                        BoxShadow(
                          color: colors.background.withAlpha(80),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: dimensions.horizontalPadding,
                vertical: dimensions.verticalPadding,
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: dimensions.iconSize,
                        height: dimensions.iconSize,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors.foreground,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.prefixIcon != null) ...[
                            Icon(
                              widget.prefixIcon,
                              size: dimensions.iconSize,
                              color: _isEnabled
                                  ? colors.foreground
                                  : colors.disabledForeground,
                            ),
                            SizedBox(width: dimensions.iconSpacing),
                          ],
                          Text(
                            widget.label,
                            style: TextStyle(
                              fontSize: dimensions.fontSize,
                              fontWeight: FontWeight.w600,
                              color: _isEnabled
                                  ? colors.foreground
                                  : colors.disabledForeground,
                              letterSpacing: 0.3,
                            ),
                          ),
                          if (widget.suffixIcon != null) ...[
                            SizedBox(width: dimensions.iconSpacing),
                            Icon(
                              widget.suffixIcon,
                              size: dimensions.iconSize,
                              color: _isEnabled
                                  ? colors.foreground
                                  : colors.disabledForeground,
                            ),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handlePress() {
    widget.onPressed?.call();
  }

  _ButtonColors _getButtonColors(ThemeData theme) {
    final primaryColor = theme.colorScheme.primary;
    final errorColor = theme.colorScheme.error;

    switch (widget.variant) {
      case SeedlyButtonVariant.primary:
        return _ButtonColors(
          background: primaryColor,
          foreground: Colors.white,
          disabledBackground: primaryColor.withAlpha(100),
          disabledForeground: Colors.white.withAlpha(150),
        );

      case SeedlyButtonVariant.secondary:
        return _ButtonColors(
          background: primaryColor.withAlpha(25),
          foreground: primaryColor,
          disabledBackground: Colors.grey.shade200,
          disabledForeground: Colors.grey.shade400,
        );

      case SeedlyButtonVariant.outline:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: primaryColor,
          borderColor: primaryColor,
          disabledBackground: Colors.transparent,
          disabledForeground: Colors.grey.shade400,
          disabledBorderColor: Colors.grey.shade300,
        );

      case SeedlyButtonVariant.ghost:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: primaryColor,
          disabledBackground: Colors.transparent,
          disabledForeground: Colors.grey.shade400,
        );

      case SeedlyButtonVariant.danger:
        return _ButtonColors(
          background: errorColor,
          foreground: Colors.white,
          disabledBackground: errorColor.withAlpha(100),
          disabledForeground: Colors.white.withAlpha(150),
        );
    }
  }

  _ButtonDimensions _getButtonDimensions() {
    switch (widget.size) {
      case SeedlyButtonSize.small:
        return _ButtonDimensions(
          height: 36,
          horizontalPadding: 14,
          verticalPadding: 8,
          fontSize: 13,
          iconSize: 16,
          iconSpacing: 6,
          borderRadius: 8,
        );

      case SeedlyButtonSize.medium:
        return _ButtonDimensions(
          height: 48,
          horizontalPadding: 20,
          verticalPadding: 12,
          fontSize: 15,
          iconSize: 18,
          iconSpacing: 8,
          borderRadius: 12,
        );

      case SeedlyButtonSize.large:
        return _ButtonDimensions(
          height: 56,
          horizontalPadding: 28,
          verticalPadding: 16,
          fontSize: 17,
          iconSize: 22,
          iconSpacing: 10,
          borderRadius: 14,
        );
    }
  }
}

class _ButtonColors {
  final Color background;
  final Color foreground;
  final Color? borderColor;
  final Color disabledBackground;
  final Color disabledForeground;
  final Color? disabledBorderColor;

  const _ButtonColors({
    required this.background,
    required this.foreground,
    this.borderColor,
    required this.disabledBackground,
    required this.disabledForeground,
    this.disabledBorderColor,
  });
}

class _ButtonDimensions {
  final double height;
  final double horizontalPadding;
  final double verticalPadding;
  final double fontSize;
  final double iconSize;
  final double iconSpacing;
  final double borderRadius;

  const _ButtonDimensions({
    required this.height,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.fontSize,
    required this.iconSize,
    required this.iconSpacing,
    required this.borderRadius,
  });
}
