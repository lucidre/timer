// ignore_for_file: must_be_immutable

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:timer/common_libs.dart';

// ─── App Button ───────────────────────────────────────────────────────────────

class AppBtn extends StatelessWidget {
  // ─── Default Constructor ───────────────────────────────────────────────────

  AppBtn({
    super.key,
    required this.onPressed,
    required this.semanticLabel,
    required this.padding,
    this.child,
    this.bgColor,
    this.textColor,
    this.border,
    this.minimumSize,
    this.enableFeedback = true,
    this.isOutlined = false,
    this.elevated = false,
    this.isLoadingEnabled = false,
    this.pressEffect = true,
    this.expand = false,
    this.circular = false,
    this.animationDisabled = false,
  }) : _builder = null;

  // ─── From Constructor ──────────────────────────────────────────────────────

  AppBtn.from({
    super.key,
    required this.onPressed,
    required String? text,
    String? semantics,
    IconData? icon,
    double? iconSize,
    this.bgColor,
    this.textColor,
    this.border,
    this.minimumSize,
    this.padding = const EdgeInsets.all(space16),
    this.enableFeedback = true,
    this.isOutlined = false,
    this.elevated = false,
    this.isLoadingEnabled = false,
    this.pressEffect = true,
    this.expand = true,
    this.animationDisabled = false,
  }) : child = null,
       semanticLabel = semantics ?? text ?? '',
       circular = false {
    if (semantics == null && text == null) {
      throw ArgumentError('AppBtn.from requires either text or semanticLabel.');
    }

    _builder = (context) {
      // Outlined: primaryColor text. Filled: white text.
      final txtColor =
          textColor ??
          (isOutlined
              ? (context.$isDarkMode ? lightColor : primaryColor)
              : lightTextColor);

      if (text == null && icon == null) return const SizedBox.shrink();

      if (isLoadingEnabled) return _loadingIndicator(txtColor);

      final txt = text == null
          ? null
          : Text(
              text,
              style: context.font500S12.copyWith(color: txtColor),
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
              ),
            );

      final icn = icon == null
          ? null
          : _AppBtnIcon(
              icon: icon,
              isOutlined: isOutlined,
              textColor: textColor,
              size: iconSize,
            );

      if (txt != null && icn != null) {
        return Row(
          mainAxisAlignment: .center,
          mainAxisSize: .min,
          children: [txt, horizontalSpacer8, icn],
        );
      }

      return (txt ?? icn)!;
    };
  }

  // ─── Basic Constructor ─────────────────────────────────────────────────────
  /// For text buttons or fully custom content.

  AppBtn.basic({
    super.key,
    required this.onPressed,
    required this.child,
    this.semanticLabel = '',
    this.textColor,
    this.minimumSize,
    this.padding = EdgeInsets.zero,
    this.enableFeedback = true,
    this.isOutlined = false,
    this.pressEffect = true,
    this.elevated = false,
    this.circular = false,
    this.animationDisabled = false,
  }) : expand = false,
       bgColor = Colors.transparent,
       border = null,
       isLoadingEnabled = false,
       _builder = null;

  // ─── Fields ────────────────────────────────────────────────────────────────

  // interaction
  final VoidCallback onPressed;
  final String semanticLabel;
  final bool enableFeedback;

  // content
  late Widget? child;
  late WidgetBuilder? _builder;

  // layout
  final EdgeInsets padding;
  final bool expand;
  final bool circular;
  final Size? minimumSize;
  final bool elevated;

  // style
  final bool isOutlined;
  final bool isLoadingEnabled;
  final bool pressEffect;
  final bool animationDisabled;
  final BorderSide? border;
  final Color? bgColor;
  final Color? textColor;

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final txtColor =
        textColor ??
        (isOutlined
            ? (context.$isDarkMode ? lightColor : primaryColor)
            : lightTextColor);

    final side =
        border ??
        (isOutlined
            ? BorderSide(
                width: 0.5,
                color: (context.$isDarkMode
                    ? lightColorHalfShade
                    : primaryColor),
              )
            : BorderSide.none);

    final shape = circular
        ? CircleBorder(side: side)
        : RoundedRectangleBorder(side: side, borderRadius: .circular(space6));

    Widget content =
        _builder?.call(context) ?? child ?? const SizedBox.shrink();
    if (expand) content = Center(child: content);

    Widget button = TextButton(
      onPressed: () {
        AppHaptics.buttonPress();
        onPressed();
      },
      style: ButtonStyle(
        elevation: ButtonStyleButton.allOrNull<double>(elevated ? 4 : 0),
        minimumSize: ButtonStyleButton.allOrNull<Size>(
          minimumSize ?? Size.zero,
        ),
        tapTargetSize: .shrinkWrap,
        splashFactory: NoSplash.splashFactory,
        overlayColor: ButtonStyleButton.allOrNull<Color>(Colors.transparent),
        backgroundColor: ButtonStyleButton.allOrNull<Color>(
          bgColor ?? (isOutlined ? context.cardBackgroundColor : primaryColor),
        ),
        shape: ButtonStyleButton.allOrNull<OutlinedBorder>(shape),
        padding: ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(padding),
        enableFeedback: enableFeedback,
      ),
      child: DefaultTextStyle(
        style: DefaultTextStyle.of(context).style.copyWith(color: txtColor),
        child: content,
      ),
    );

    if (pressEffect) button = _ButtonPressEffect(button);

    final animatedButton = animationDisabled
        ? button
        : button.fadeInAndMoveFromBottom();

    if (semanticLabel.isEmpty) return animatedButton;

    return Semantics(
      label: semanticLabel,
      button: true,
      container: true,
      child: ExcludeSemantics(child: animatedButton),
    );
  }

 
  Widget _loadingIndicator(Color txtColor) => SizedBox(
    height: 15,
    width: 15,
    child: CircularProgressIndicator.adaptive(
      backgroundColor: kIsWeb || Platform.isIOS || Platform.isMacOS
          ? txtColor
          : Colors.transparent,
      valueColor: AlwaysStoppedAnimation(txtColor),
    ),
  );
}

// ─── Button Icon ──────────────────────────────────────────────────────────────

class _AppBtnIcon extends StatelessWidget {
  const _AppBtnIcon({
    required this.icon,
    required this.isOutlined,
    this.textColor,
    this.size,
  });

  final IconData icon;
  final bool isOutlined;
  final Color? textColor;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final color =
        textColor ??
        (isOutlined
            ? (context.$isDarkMode ? lightColor : primaryColor)
            : lightTextColor);
    return Icon(icon, color: color, size: size ?? 16);
  }
}

// ─── Press Effect ─────────────────────────────────────────────────────────────

class _ButtonPressEffect extends StatefulWidget {
  const _ButtonPressEffect(this.child);
  final Widget child;

  @override
  State<_ButtonPressEffect> createState() => _ButtonPressEffectState();
}

class _ButtonPressEffectState extends State<_ButtonPressEffect> {
  bool _isDown = false;

  void _setDown(bool value) => setState(() => _isDown = value);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      excludeFromSemantics: true,
      onTapDown: (_) => _setDown(true),
      onTapUp: (_) => _setDown(false),
      onTapCancel: () => _setDown(false),
      behavior: HitTestBehavior.translucent,
      child: Opacity(
        opacity: _isDown ? 0.7 : 1.0,
        child: ExcludeSemantics(child: widget.child),
      ),
    );
  }
}
