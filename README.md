Provides a simple way to re-use behaviors across StatefulWidgets. Improves readability and robustness of your components.

## 🔨 Installation
```
dependencies:
  stateful_props: ^1.0.0
```
## ⚙ Import
```
import 'package:stateful_props/stateful_props.dart';
```

## 🕹️ Basic Usage
The package includes pre-made props for many common flutter use cases, these include:
- `AnimationControllerProp`
- `FocusNodeProp`
- `FutureProp`
- `IntProp`, `DoubleProp` `StringProp`, `BoolProp`
- `PageControllerProp`
- `ScrollControllerProp`
- `StreamProp`
- `StreamControllerProp`
- `TabControllerProp`
- `TextEditingControllerProp`

Generally speaking the built in props handle common use cases like calling `setState` when values change and properly calling `dispose` when required.

To get started, add a `StatefulPropsMixin` to any `StatefulWidget` and then use one of the built-in props. In this case we'll use an `AnimationProp` to manage an `AnimationController` for us:
```dart
class _MyWidgetState extends State<MyWidget> with StatefulPropsMixin {
  late final fadeAnim = AnimationControllerProp(duration: 1.seconds, autoBuild: false);

  @override
  Widget build(BuildContext context) => FadeTransition(opacity: fadeAnim.controller, child: ...)
}
```
Notice that `autoBuild` is set to false, if this were true, `setState` would be called automatically each time the animation ticks. Also notice that we don't call `dispose()` on the controller, the prop is handling that for us.

## 📖 Background & Motivation
It is difficult to reuse `State` logic in Flutter. We either end up with a complex and deeply nested build method or have to copy-paste the logic across multiple widgets. For a full discussion, see here: https://github.com/flutter/flutter/issues/51752#.

For example, have you ever written code like this?
```dart
class _MyWidgetState extends State<MyWidget> with TickerProviderStateMixin {
  late TextEditingController textController = TextEditingController();
  late AnimationController fadeInAnim = AnimationController(vsync: this, duration: Duration(seconds: 1));
  late AnimationController scaleAnim = AnimationController(vsync: this, duration: Duration(seconds: 1));
  late FocusNode focusNode = FocusNode(descendantsAreFocusable: false);

  int _count = 0;
  int get count => _count;
  set count(int count) => setState(() => _count = count);

  @override
  void dispose() {
    fadeInAnim.dispose();
    scaleAnim.dispose();
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ...
```

Not only is this code overly verbose, but it's also error-prone. If any of the `dipose()` calls are missed, you will have a bug. If the `setState` calls is missed, the view will not appear to update. It would be much nicer if each type of object could handle it's own `dispose()` call, or automatically rebuild the state when changed.

With `StatefulProps` this can be written as:
```dart
class _MyWidgetState extends State<MyWidget> with StatefulPropsMixin {
  late final textController = TextEditingControllerProp(this);
  late final fadeInAnim = AnimationControllerProp(duration: Duration(seconds: 1));
  late final scaleAnim = AnimationControllerProp(duration: Duration(seconds: 1));
  late final focusNode = FocusNodeProp(this, descendantsAreFocusable: false);
  late final counter = IntProp(this);

  @override
  Widget build(BuildContext context) => ...
}
```
Notice that all the calls to `dispose()` and `setState()` have gone away, as each `StatefulProp` is responsible for disposing itself and (optionally) calling `setState` when it has changed. This makes the code easier to read and more robust; `dispose` calls can't get missed, and the work of rebuilding when the counter value changes is done automatically.

While a similar level of robustness could also be achieved using a combination of nested `Builder` widgets, it would come at the cost of reduced readability.

### Flexible & Robust Design
Because each prop is a proper class, and can nest other props, they fully support inheritence, composition and mixins, allowing you to easily combine or extend existing props to create new ones. For example, if you check the source code, you'll see that a single `ValueProp<T>` is used as the base class for all the primitives (`IntProp`, `BoolProp`, `StringProp` and `DoubleProp`).

Props can never clash with eachother over field names because they all have their own self-contained scope. This is in contrast to `mixins` which will have issues if two mixins declare the same field name.

## 🕹️ Advanced Usage
### Creating New Props
To create a new prop extend the `StatefulProp` class, and override any of the optional methods:
```dart
class MyCustomProp extends StatefulProp {
  MyCustomProp(StatefulPropsManager manager) : super(manager);

  @override
  void didChangeDependencies() {}

  @override
  void dispose() {}

  @override
  void didUpdateWidget(covariant StatefulWidget oldWidget) {}

  @override
  void activate() {}

  @override
  void deactivate() {}
}
```

#### Rebuilding
If a prop would like to rebuild the state it is attached to it can call `manager.scheduleBuild()` which in turn will call `setState()`.

### Re-using Stateful Logic
You can use custom props to encapsulate any combination of logic and state that you would like. Either for use across multiple widgets or to isolate for easier testing. For example you could extract common login-related behavior to a `LoginBehaviorProp`:
```dart
class LoginBehaviorProp extends StatefulProp {
  LoginBehaviorProp(StatefulPropsManager manager) : super(manager);
  late final _emailText = TextEditingControllerProp(manager);
  late final _passwordText = TextEditingControllerProp(manager);
  late final _showPassword = BoolProp(manager); // rebuilds when changed

  TextEditingController get emailCtrl => _emailText.controller;
  TextEditingController get passwordCtrl => _passwordText.controller;
  bool get showPassword => _showPassword.value;

  void submit() => print('login logic goes here');

  void toggleShowPassword() => _showPassword.value = !showPassword;
}
```
This forms a sort of "micro state" that holds both stateful fields as well as shared logic to work on those fields. It also resembles what is commonly referred to as a `ViewModel` or `ViewController`. The fully encapsulated behavior could then be used inside of any `StatefulWidget`:
```dart
class _MyState extends State<MyView> with StatefulPropsMixin {
  late final _login = LoginBehaviorProp(this);

  @override
  Widget build(BuildContext context) => Column(children: [
    TextFormField(controller, _login.emailCtrl),
    TextFormField(controller, _login.passwordCtrl, obscureText: _login.showPassword),
    Button(onPressed: _login.submit),
  ]);
}
```
In this way props can act as their own reusable behaviors, shared easily across different widgets without potential bugs that come from mixins or the readability issues that come with nested builders.


## 🐞 Bugs/Requests 
If you encounter any problems please open an issue. If you feel the library is missing a feature, please raise a ticket on Github and we'll look into it. Pull request are welcome.

## 📃 License 
MIT License