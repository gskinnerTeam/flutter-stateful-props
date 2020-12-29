import 'dart:async';

import '../stateful_props_manager.dart';

class TimerProp extends StatefulProp<TimerProp> {
  TimerProp(this.seconds, this.callback, {this.periodic = false}) {
    restart(seconds, callback, periodic: periodic);
  }
  final double seconds;
  final void Function(Timer) callback;
  final bool periodic;

  // Helper methods
  Timer get timer => _timer;
  void cancel() => _timer?.cancel();
  void restart(double seconds, void Function(Timer) callback, {bool periodic = false}) {
    cancel();
    _timer = periodic ? Timer.periodic(seconds.duration, callback) : Timer(seconds.duration, () => callback(timer));
  }

  //Internal state
  Timer _timer;

  @override
  void dispose() => cancel();
}
