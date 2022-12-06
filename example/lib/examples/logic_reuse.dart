import 'package:flutter/material.dart';
import 'package:stateful_props/stateful_props.dart';

/// Shows how we can abstract the logic and state out of the widget for easier testing and re-use.
/// In this example we re-use 3 pieces of state, 2 actions and 3 helper methods.
class LoginLogicProp extends StatefulProp {
  LoginLogicProp(StatefulPropsManager manager) : super(manager);
  // Some state / props
  late final _emailText = TextEditingControllerProp(manager);
  late final _passwordText = TextEditingControllerProp(manager);
  late final _showPassword = BoolProp(manager); // rebuilds when changed

  // Helper methods
  TextEditingController get emailCtrl => _emailText.controller;
  TextEditingController get passwordCtrl => _passwordText.controller;
  bool get showPassword => _showPassword.value;

  // Actions
  void submit() => debugPrint('login logic goes here, talk to services, moderls, etc. '
      'Call manager.scheduleBuild to rebuild the widget');
  void toggleShowPassword() => _showPassword.value = !showPassword;
}

/// Use the [LoginLogicProp] inside any [StatefulWidget] using the [StatefulPropsMixin]
class LogicReuseDemo extends StatefulWidget {
  const LogicReuseDemo({Key? key}) : super(key: key);

  @override
  _LogicReuseDemoState createState() => _LogicReuseDemoState();
}

class _LogicReuseDemoState extends State<LogicReuseDemo> with StatefulPropsMixin {
  /// Here is the re-usable logic logic and state
  late final _loginLogic = LoginLogicProp(this);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(controller: _loginLogic.emailCtrl),
        TextField(
          controller: _loginLogic.passwordCtrl,
          decoration: InputDecoration(
            suffix: IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: _loginLogic.toggleShowPassword,
            ),
          ),
          obscureText: !_loginLogic.showPassword,
        ),
        ElevatedButton(child: const Text('Login'), onPressed: _loginLogic.submit),
      ],
    );
  }
}
