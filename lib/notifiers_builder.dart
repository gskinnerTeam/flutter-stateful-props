import 'package:flutter/material.dart';

class NotifiersBuilder extends StatefulWidget {
  NotifiersBuilder(this.notifiers, {Key key, this.child, @required this.builder}) : super(key: key);
  final List<ChangeNotifier> notifiers;
  final Widget child;

  final Widget Function(BuildContext, Widget) builder;

  @override
  _NotifiersBuilderState createState() => _NotifiersBuilderState();
}

class _NotifiersBuilderState extends State<NotifiersBuilder> {
  @override
  void initState() {
    super.initState();
    addListeners();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, widget.child);

  @override
  void didUpdateWidget(covariant NotifiersBuilder oldWidget) {
    oldWidget.notifiers.forEach((element) => element.removeListener(rebuild));
    addListeners();
    super.didUpdateWidget(oldWidget);
  }

  void addListeners() => widget.notifiers.forEach((element) => element.addListener(rebuild));

  void rebuild() => setState(() {});
}
