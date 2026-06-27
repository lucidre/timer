import 'package:timer/common_libs.dart';

class _TimeListener {
  StreamController<DateTime>? _controller;
  Timer? _timer;

  Stream<DateTime> get stream {
    _controller ??= StreamController<DateTime>.broadcast(
      onListen: _startTimer,
      onCancel: _stopTimer,
    );
    return _controller!.stream;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_controller != null && !_controller!.isClosed) {
        _controller!.add(DateTime.now());
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    _stopTimer();
    _controller?.close();
    _controller = null;
  }
}

class CurrentTimeWidget extends StatefulWidget {
  const CurrentTimeWidget({super.key});

  @override
  State<CurrentTimeWidget> createState() => _CurrentTimeWidgetState();
}

class _CurrentTimeWidgetState extends State<CurrentTimeWidget> {
  final _TimeListener _timeListener = _TimeListener();

  @override
  void dispose() {
    _timeListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: _timeListener.stream,
      initialData: .now(),
      builder: (context, snapshot) {
        final currentTime = snapshot.data;

        final String formattedTime = currentTime != null
            ? $appUtil.formatTimeOnly(currentTime)
            : '';

        return Text(
          formattedTime,
          style: context.font600S14.copyWith(
            color: lightColor,
            fontFamily: spaceGrotesk,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        );
      },
    );
  }
}
