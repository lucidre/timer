import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:timer/common_libs.dart';
import 'package:timer/features/splash/data/data_sources/schedule_sync.dart';

Future<void> initializeApplication() async {
  await _initializeWindow();
  _initializeControlllers();
  await _initializeSharedPreferences();
  _initializeNotification();
  await dotenv.load(fileName: "assets/.env");
}

void _initializeControlllers() {
  Get.put(ConnectionStatusController(), permanent: true);
  Get.put(RouterController(), permanent: true);
  Get.put(AppNotificationController(), permanent: true);
  Get.put(ScheduleSyncService());
  EasyLoading.init();
}

Future<void> _initializeWindow() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

Future<void> _initializeSharedPreferences() async {
  await AppPreferences.init();
}

Future<void> _initializeNotification() =>
    Get.find<AppNotificationController>().initNotifications();
