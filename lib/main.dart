import 'package:timer/app_setup.dart';
import 'package:timer/common_libs.dart';

void main() async {
  await initializeApplication();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = Get.find<RouterController>().router;

    return GetMaterialApp.router(
      routerDelegate: appRouter.delegate(),
      routeInformationParser: appRouter.defaultRouteParser(),
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: context.lightTheme,
      darkTheme: context.darkTheme,
      builder: EasyLoading.init(),
      localeResolutionCallback: (locale, supportedLocales) {
        if (supportedLocales.contains(locale)) {
          return locale;
        }
        return const Locale('en');
      },
    );
  }
}
