import 'package:timer/common_libs.dart';

extension DeviceWidget on BuildContext {
  Widget errorWidget({
    required VoidCallback onRetry,
    String? description,
    EdgeInsets? padding,
    String? title,
    bool? expand,
    String? btnText,
    IconData? btnIcon,
    String? lottie,
    Color? color,
    Color? bgColor,
    Color? textColor,
    BorderSide? border,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.scale(
          scale: 1.3,
          child: Center(
            child: Lottie.asset(
              lottie ?? (errorLottie),
              width: 150,
              animate: true,
              reverse: true,
              repeat: true,
              height: 200,
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
          ),
        ),
        Text(
          title ?? 'Error Occurred ',
          style: font600S20,
        ).fadeInAndMoveFromBottom(),
        verticalSpacer8,
        Text(
          description ??
              "Data couldn't be fetched. Please check your internet connection and try again.",
          style: font500S12.copyWith(),
          textAlign: TextAlign.center,
        ).fadeInAndMoveFromBottom(),
        verticalSpacer12,
        AppBtn.from(
          expand: expand ?? true,
          onPressed: () => onRetry.call(),
          text: btnText ?? "Refresh",
          icon: btnIcon ?? Icons.refresh_rounded,
          bgColor: bgColor,
          border: border,
          textColor: textColor,
        ),
      ],
    );
  }

  Widget noDataWidget({
    String? description,
    EdgeInsets? padding,
    String? title,
    String? lottie,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.scale(
          scale: 1.3,
          child: Lottie.asset(
            lottie ?? lottieNoData,
            width: 200,
            animate: true,
            reverse: true,
            repeat: true,
            height: 200,
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ).fadeInAndMoveFromBottom(),
        verticalSpacer4,
        Text(
          title ?? 'No Data Available',
          style: font500S18.copyWith(
            color: $isDarkMode ? lightColor : neutral800,
            fontWeight: FontWeight.w700,
          ),
        ).fadeInAndMoveFromBottom(),
        verticalSpacer8,
        Text(
          description ??
              'No data is available to display at the moment. Please check back later. ',
          style: font500S14.copyWith(
            color: $isDarkMode ? neutral200 : neutral700,
          ),
          textAlign: TextAlign.center,
        ).fadeInAndMoveFromBottom(),
      ],
    );
  }

  Widget buildLoadingWidget({
    String? lottie,
    String? description,
    double? scale,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        verticalSpacer8,
        Transform.scale(
          scale: scale ?? 1.2,
          child: Lottie.asset(
            lottie ?? loadingLottie,
            animate: true,
            repeat: true,
            reverse: true,
            width: 250,
            height: 250,
            fit: BoxFit.contain,
          ),
        ),
        Text(
          description ?? "Loading...",
          style: font500S14,
        ).fadeInAndMoveFromBottom(),
      ],
    );
  }
}
