import 'package:flutter/cupertino.dart';
import 'package:reactives/stateful_props.dart';

typedef ValueChanged<T> = void Function(T? oldValue, T newValue);

class DoubleProp extends ValueProp<double> {
  DoubleProp(
    StatefulPropsManager manager, {
    double initial = 0,
    ValueChanged<double>? onChange,
    bool autoBuild = true,
  }) : super(manager, initial: initial, onChange: onChange, autoBuild: autoBuild);
}

class IntProp extends ValueProp<int> {
  IntProp(
    StatefulPropsManager manager, {
    int initial = 0,
    ValueChanged<int>? onChange,
    bool autoBuild = true,
  }) : super(manager, initial: initial, onChange: onChange, autoBuild: autoBuild);
}

class BoolProp extends ValueProp<bool> {
  BoolProp(
    StatefulPropsManager manager, {
    bool initial = false,
    ValueChanged<bool>? onChange,
    bool autoBuild = true,
  }) : super(manager, initial: initial, onChange: onChange, autoBuild: autoBuild);
}

class StringProp extends ValueProp<String> {
  StringProp(
    StatefulPropsManager manager, {
    String initial = '',
    ValueChanged<String>? onChange,
    bool autoBuild = true,
  }) : super(manager, initial: initial, onChange: onChange, autoBuild: autoBuild);
}

class ValueProp<T> extends StatefulProp with ChangeNotifier {
  ValueProp(StatefulPropsManager manager, {required this.initial, this.onChange, this.autoBuild = true})
      : super(manager) {
    _value = initial;
  }
  final T initial;
  late T _value;
  late T? _prev;
  final ValueChanged<T>? onChange;
  final bool autoBuild;

  T get value => _value;
  set value(T value) {
    if (value == _value) return;
    if (isMounted == false) return;
    _prev = _value;
    _value = value;
    onChange?.call(_prev, _value);

    /// Optionally rebuild when changed.
    if (autoBuild) {
      manager.scheduleBuild();
    }

    /// Notify listeners so we can be used in [ListenableBuilder]
    notifyListeners();
  }
}
