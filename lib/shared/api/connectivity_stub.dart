import 'package:web/web.dart' as web;

Future<bool> checkHasInternet() async => web.window.navigator.onLine;
