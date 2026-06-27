import 'package:timer/common_libs.dart';
import 'package:timer/features/data/repositorites/splash_repository_impl.dart';
import 'package:timer/features/domain/usecases/splash_service.dart';

//TODO: LOCALIZE
final _statusMessages = [
  'Fetching your profile...',
  'Connecting to secure servers...',
  'Verifying account credentials...',
  'Syncing your preferences...',
  'Loading your library...',
  'Retrieving saved content...',
  'Optimizing your dashboard...',
  'Finalizing configurations...',
  'Applying the finishing touches...',
  'Just a moment longer...',
];

class SplashController extends GetxController {
  final SplashService service;
  static const int _maxRetries = 3;
  Timer? _statusTimer;

  SplashController() : service = .new(SplashRepositoryImpl(.new()));

  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  RxBool get isLoadingRx => _isLoading;
  set isLoading(bool value) => _isLoading.value = value;

  final _errorOccurred = false.obs;
  bool get errorOccurred => _errorOccurred.value;
  set errorOccurred(bool value) => _errorOccurred.value = value;

  final _showStatus = false.obs;
  bool get showStatus => _showStatus.value;
  set showStatus(bool value) => _showStatus.value = value;

  final _statusIndex = 0.obs;
  int get statusIndex => _statusIndex.value;
  set statusIndex(int value) => _statusIndex.value = value;

  String get statusMessage => _statusMessages[statusIndex];

  void startTimer() {
    final duration = const Duration(seconds: 2);
    _statusTimer = .periodic(duration, (_) {
      statusIndex = (statusIndex + 1) % _statusMessages.length;
    });
  }

  void endTimer() {
    _statusTimer?.cancel();
  }

  bool _isRefreshing = false;

  Future<void> refreshToken() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    isLoading = true;
    errorOccurred = false;

    int attempt = 0;
    while (attempt < _maxRetries) {
      try {
        // await service.refreshToken();
        isLoading = false;
        _isRefreshing = false;
        return;
      } catch (exception) {
        attempt++;
        if (attempt >= _maxRetries) {
          isLoading = false;
          errorOccurred = true;
          _isRefreshing = false;

          AppLogger.error('token_refresh', 'Max retries reached: $exception');
          rethrow;
        }
        await Future.delayed(medDuration);
      }
    }

    _isRefreshing = false;
  }

  @override
  void onInit() {
    super.onInit();
    _statusMessages.shuffle();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }
}
