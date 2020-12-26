import 'package:flutter/material.dart';

class StatefulProps {}

class MyView extends StatefulWidget {
  @override
  _MyViewState createState() => _MyViewState();
}

class _MyViewState extends State<MyView> {
  bool _isLoading = false;

  void setIsLoading(bool value) {
    setState(() => _isLoading = value);
  }

  @override
  Widget build(BuildContext context) => Container();
}
