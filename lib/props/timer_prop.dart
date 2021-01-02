import 'dart:async';

import '../stateful_props_manager.dart';

class TimerProp extends StatefulProp<TimerProp> {
  TimerProp(this.seconds, this.callback, {this.periodic = false});
  final double seconds;
  final void Function(Timer) callback;
  final bool periodic;

  //Internal state
  Timer _timer;

  @override
  void init() {
    restart(seconds, callback, periodic: periodic);
  }

  @override
  void dispose() => cancel();

  // Helper methods
  Timer get timer => _timer;
  void cancel() => _timer?.cancel();
  void restart(double seconds, void Function(Timer) callback, {bool periodic = false}) {
    cancel();
    _timer = periodic ? Timer.periodic(seconds.duration, callback) : Timer(seconds.duration, () => callback(timer));
  }
}
