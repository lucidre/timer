import 'package:timer/common_libs.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

extension DeviceBar on BuildContext {
  Future<T?> showBottomBar<T>({
    required Widget child,
    double? height,
    bool dismissable = true,
    bool ignoreHeight = false,
  }) {
    final defaultHeight = screenHeight - (topPadding + kToolbarHeight);

    const BorderRadius borderRadius = BorderRadius.only(
      topLeft: Radius.circular(space12),
      topRight: Radius.circular(space12),
    );
    final result = showModalBottomSheet<T>(
      context: this,
      isScrollControlled: true,
      isDismissible: dismissable,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(maxHeight: height ?? defaultHeight),
      builder: (_) => Material(
        color: Colors.transparent,
        child: Container(
          height: ignoreHeight ? null : height,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          decoration: BoxDecoration(borderRadius: borderRadius),
          child: child.fadeInAndMoveFromBottom(),
        ),
      ),
    );
    return result;
  }

  Future<T?> showCenterBar<T>({
    required Widget child,
    double? height,
    String? barrierLabel,
    bool dismissable = true,
    bool ignoreHeight = false,
  }) {
    final defaultHeight = screenHeight - (topPadding + kToolbarHeight * 2);

    const BorderRadius borderRadius = BorderRadius.all(
      Radius.circular(space16),
    );

    final result = showGeneralDialog<T>(
      context: this,
      barrierLabel: barrierLabel,
      barrierDismissible: dismissable,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: medDuration,
      pageBuilder: (_, _, _) => Dialog(
        backgroundColor: backgroundColor,
        shape: const RoundedRectangleBorder(borderRadius: borderRadius),
        elevation: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius,
            ),
            constraints: BoxConstraints(maxHeight: height ?? defaultHeight),
            child: child.fadeIn(),
          ),
        ),
      ),
      transitionBuilder: (_, anim, _, child) => FadeTransition(
        opacity: Tween(begin: 0.0, end: 1.0).animate(anim),
        child: child,
      ),
    );

    return result;
  }

  void showInformationSnackBar(String desciption) => showTopSnackBar(
    Overlay.of(this),
    CustomSnackBar.info(
      message: desciption,
      backgroundColor: Colors.blue.shade700,
      iconRotationAngle: 0,
      iconPositionTop: -10,
      iconPositionLeft: -10,
      icon: Icon(
        Icons.info_outline_rounded,
        color: neutral800.withValues(alpha: .15),
        size: 120,
      ),
      messagePadding: const EdgeInsets.all(space16),
      textAlign: TextAlign.start,
      textStyle: font500S14.copyWith(
        color: lightColor,
        fontWeight: FontWeight.w600,
      ),
    ),
    snackBarPosition: SnackBarPosition.top,
  );

  Future<T?> $showGeneralDialog<T>({
    required Widget child,
    bool dismissible = true,
    required String barrierLabel,
  }) => showGeneralDialog<T>(
    context: this,
    barrierDismissible: dismissible,
    barrierColor: darkBackgroundColor.withValues(alpha: 0.5),
    transitionDuration: fastDuration,
    pageBuilder: (_, _, _) => Dialog(
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(space10)),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(space10),
        child: child.fadeInAndMoveFromBottom(),
      ),
    ),
    barrierLabel: barrierLabel,
    transitionBuilder: (_, anim, _, child) => FadeTransition(
      opacity: Tween(begin: 0.0, end: 1.0).animate(anim),
      child: child,
    ),
  );

  void showErrorSnackBar(String? cause) => showTopSnackBar(
    Overlay.of(this),
    CustomSnackBar.error(
      message: cause ?? 'An error occurred',
      backgroundColor: destructive600,
      messagePadding: const EdgeInsets.all(space16),
      textAlign: TextAlign.start,
      textStyle: font500S14.copyWith(
        color: lightColor,
        fontWeight: FontWeight.w600,
      ),
    ),
    snackBarPosition: .top,
  );

  void showSuccessSnackBar(String message) => showTopSnackBar(
    Overlay.of(this),
    CustomSnackBar.success(
      message: message,
      backgroundColor: success600,
      messagePadding: const EdgeInsets.all(space16),
      textAlign: TextAlign.start,
      textStyle: font500S14.copyWith(
        color: lightColor,
        fontWeight: FontWeight.w600,
      ),
    ),
    snackBarPosition: SnackBarPosition.top,
  );
}
