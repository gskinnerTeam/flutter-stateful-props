import 'package:flutter/cupertino.dart';

import '../stateful_props_manager.dart';

/// TODO: Add RestorationAPI support. Figure out how to check if a Restorable has been registered, and fallback to regular value if not.
class IntProp extends ValueProp<int> {
  IntProp({
    int defaultValue = 0,
    ValueChanged<int> onChange,
    bool autoBuild = true,
  }) : super(initial: defaultValue, onChange: onChange, autoBuild: autoBuild);

  void increment() => value++;
  void decrement() => value--;

  double get toDouble => value.toDouble();
}

class BoolProp extends ValueProp<bool> {
  BoolProp({
    bool initial = false,
    ValueChanged<bool> onChange,
    bool autoBuild = true,
  }) : super(initial: initial, onChange: onChange, autoBuild: autoBuild);

  void toggle() => value = !value;
}

class DoubleProp extends ValueProp<double> {
  DoubleProp({
    double defaultValue = 0,
    ValueChanged<double> onChange,
    bool autoBuild = true,
  }) : super(initial: defaultValue, onChange: onChange, autoBuild: autoBuild);

  int get toInt => value.toInt();
}

typedef ValueChanged<T> = void Function(T oldValue, T newValue);

class StringProp extends ValueProp<String> {
  StringProp({
    String defaultValue,
    ValueChanged<String> onChange,
    bool autoBuild = true,
  }) : super(initial: defaultValue, onChange: onChange, autoBuild: autoBuild);

  bool get isEmpty => _value == null || _value.isEmpty;
}

class ValueProp<T> extends StatefulProp<ValueProp<T>> with ChangeNotifier {
  ValueProp({this.initial, this.onChange, this.autoBuild = true}) {
    _value = initial;
  }
  final T initial;
  T _value;
  T _prev;
  void Function(T oldValue, T newValue) onChange;
  bool autoBuild;

  T get value => _value;
  set value(T value) {
    if (value == _value) return; //Optimize
    if (isMounted == false || context == null) return; // Protect against late calls
    _prev = _value;
    _value = value;
    onChange?.call(_prev, _value);
    // We can act _either_ as a ChangeNotifier or a `setState()` caller. This lets us encapsulate in a builder, or rebuild the entire state easily.
    if (autoBuild) {
      setState(() {});
    } else {
      notifyListeners();
    }
  }
}
