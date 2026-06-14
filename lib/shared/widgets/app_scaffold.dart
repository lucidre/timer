import 'package:timer/common_libs.dart';

///App Scaaffold
class AppScaffold extends StatelessWidget {
  final Widget body;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final bool enableInternetBanner;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final List<Widget> bannerActions;
  final SystemUiOverlayStyle? overlayStyle;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBody;
  final bool ignoreSafeArea;
  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.enableInternetBanner = true,
    this.floatingActionButtonLocation,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.scaffoldKey,
    this.backgroundColor,
    this.bannerActions = const [],
    this.extendBody = false,
    this.ignoreSafeArea = false,
    this.overlayStyle,
  });
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle ?? (context.$isDarkMode ? .light : .dark),
      child: Scaffold(
        appBar: appBar,
        drawer: drawer,
        key: scaffoldKey,
        extendBody: extendBody,
        backgroundColor: backgroundColor ?? context.backgroundColor,
        body: ignoreSafeArea
            ? buildBody(context)
            : SafeArea(child: buildBody(context)),
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return Stack(
      children: [
        SizedBox(width: double.infinity, height: double.infinity, child: body),
        Positioned(
          left: 0,
          right: 0,
          top: appBar == null ? (context.top + 10) : 0,
          child: GetX<ConnectionStatusController>(
            builder: (controller) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!controller.hasConnection && enableInternetBanner) ...[
                    buildNetworkWidget(context),
                    verticalSpacer10,
                  ],
                  for (final banner in bannerActions) ...[
                    banner,
                    verticalSpacer10,
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildNetworkWidget(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(space20 / 4),
        margin: const EdgeInsets.only(left: space20 / 4, right: space20 / 4),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: .5),
          borderRadius: BorderRadius.circular(cornersSmall),
        ),
        child: Row(
          children: [
            Text(
              'No Internet Connection',
              style: context.font500S18.copyWith(
                color: lightColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            const Icon(Icons.warning_rounded, color: lightColor, size: 16),
          ],
        ),
      ),
    );
  }
}
