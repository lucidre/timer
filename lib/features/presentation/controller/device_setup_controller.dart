import 'package:timer/common_libs.dart';
import 'package:timer/shared/api/network_methods.dart';

class DeviceSetupController extends GetxController {
  final nameController = TextEditingController();
  final idController = TextEditingController();
  final ipController = TextEditingController();

  final _isSaving = false.obs;
  final _isTesting = false.obs;
  final _isOnline = false.obs;
  final _lastSeen = Rxn<DateTime>();

  bool get isSaving => _isSaving.value;
  bool get isTesting => _isTesting.value;
  bool get isOnline => _isOnline.value;
  DateTime? get lastSeen => _lastSeen.value;

  set isSaving(bool value) => _isSaving.value = value;
  set isTesting(bool value) => _isTesting.value = value;
  set isOnline(bool value) => _isOnline.value = value;
  set lastSeen(DateTime? value) => _lastSeen.value = value;

  //8.8.4.4:80

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  @override
  void onClose() {
    nameController.dispose();
    idController.dispose();
    ipController.dispose();
    super.onClose();
  }

  void _load() {
    nameController.text = AppPreferences.deviceName;
    ipController.text = AppPreferences.deviceIp;
    idController.text = AppPreferences.deviceId.isEmpty
        ? _generateId()
        : AppPreferences.deviceId;
    lastSeen = AppPreferences.deviceLastSeen;
  }

  String _generateId() {
    final suffix = DateTime.now().millisecondsSinceEpoch
        .toRadixString(36)
        .toUpperCase()
        .substring(0, 6);
    return 'DEVICE_$suffix';
  }

  Future<void> saveProfile() async {
    final name = nameController.text.trim();
    final ip = ipController.text.trim();
    final id = idController.text.trim();

    if (name.isEmpty || ip.isEmpty) {
      throw DeviceSetupControllerErrors.fillAllFields;
    }

    if (isSaving) return;
    isSaving = true;
    await AppPreferences.setDeviceName(name);
    await AppPreferences.setDeviceIp(ip);
    await AppPreferences.setDeviceId(id);

    await Future.delayed(2.seconds);
    isSaving = false;
  }

  Future<void> testConnection() async {
    final ip = ipController.text.trim();
    if (ip.isEmpty) return;

    isTesting = true;
    isOnline = false;

    try {
      await Future.delayed(500.milliseconds);
      final result = await $get('/', host: 'http://$ip').timeout(4.seconds);

      isOnline = !result.isError;

      if (isOnline) {
        lastSeen = .now();
        await AppPreferences.setDeviceLastSeen(lastSeen!);
      }
    } catch (_) {
      isOnline = false;
      rethrow;
    } finally {
      isTesting = false;
    }
  }
}

enum DeviceSetupControllerErrors { fillAllFields }
