import '../stateful_props_manager.dart';

/// TODO: Add RestorationAPI support. Figure out how to check if a Restorable has been registered, and fallback to regular value if not.
class IntProp extends ValueProp<int> {
  IntProp([int defaultValue = 0]) : super(defaultValue);

  void increment() => value++;
  void decrement() => value--;

  double get toDouble => value.toDouble();
}

class BoolProp extends ValueProp<bool> {
  BoolProp([bool defaultValue = false]) : super(defaultValue);

  void toggle() => value = !value;
}

class DoubleProp extends ValueProp<double> {
  DoubleProp([double defaultValue = 0]) : super(defaultValue);

  int get toInt => value.toInt();
}

class ValueProp<T> extends StatefulProp<ValueProp<T>> {
  ValueProp(this._value, {this.onChange});
  T _value;
  T _prev;
  void Function(T oldValue, T newValue) onChange;

  T get value => _value;
  set value(T value) {
    if (value == _value) return;
    setState(() {
      _prev = _value;
      _value = value;
      onChange?.call(_prev, _value);
    });
  }
}
