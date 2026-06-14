import 'package:timer/common_libs.dart';

class AppFetchingBar extends StatefulWidget {
  final RxBool stateRx;
  const AppFetchingBar({super.key, required this.stateRx});

  @override
  State<AppFetchingBar> createState() => _AppFetchingBarState();
}

class _AppFetchingBarState extends State<AppFetchingBar> {
  final _currentState = ValueNotifier(false);
  Worker? stateWorker;
  @override
  void initState() {
    super.initState();
    _currentState.value = widget.stateRx.value;

    stateWorker = debounce<bool>(
      widget.stateRx,
      (value) => _currentState.value = value,
    );
  }

  @override
  void dispose() {
    stateWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _currentState,
      builder: (_, value, child) {
        if (value) {
          return child ?? const SizedBox.shrink();
        } else {
          return const SizedBox.shrink();
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        margin: const .all(space20 / 4),
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator.adaptive(
            // valueColor: AlwaysStoppedAnimation(context.textColor),
            backgroundColor: context.textColor,
          ),
        ),
      ),
    );
  }
}
