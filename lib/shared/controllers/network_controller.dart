import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectionStatusController extends GetxController {
  static final ConnectionStatusController instance = Get.find();
  
  //This tracks the current connection status
  final RxBool _hasConnection = true.obs;
  bool get hasConnection => _hasConnection.value;

  final Connectivity _connectivity = Connectivity();
  ConnectionStatusController() {
    _checkConnection();
    _connectivity.onConnectivityChanged.listen(_connectionChange);
  }

  //flutter_connectivity's listener
  void _connectionChange(List<ConnectivityResult> connectivityResult) {
    bool hasNetwork = false;
    networkLoop:
    for (final result in connectivityResult) {
      if (result != ConnectivityResult.none && !hasNetwork) {
        hasNetwork = true;
        break networkLoop;
      }
    }

    if (hasNetwork != hasConnection) {
      _hasConnection.value = hasNetwork;
    }
  }

  void _checkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    bool hasNetwork = false;
    networkLoop:
    for (final result in connectivityResult) {
      if (result != ConnectivityResult.none && !hasNetwork) {
        hasNetwork = true;
        break networkLoop;
      }
    }

    if (hasNetwork != hasConnection) {
      _hasConnection.value = hasNetwork;
    }
  }
}
