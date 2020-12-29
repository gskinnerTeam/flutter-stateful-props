import 'package:flutter/widgets.dart';
import '../stateful_props_manager.dart';

class TextEditProp extends StatefulProp<TextEditProp> {
  TextEditProp({String text, this.onChanged}) {
    _initialText = text;
  }
  String _initialText;

  // Callbacks
  void Function(TextEditProp) onChanged;

  // Helper methods
  String get text => _controller.text;
  TextEditingController get controller => _controller;

  // Internal state
  TextEditingController _controller;

  @override
  void init() {
    _controller = TextEditingController(text: _initialText);
    _controller.addListener(_handleTextChanged);
  }

  @override
  void update(TextEditProp newProp) {
    onChanged = newProp.onChanged;
  }

  void _handleTextChanged() => onChanged?.call(this);

  @override
  void dispose() => _controller.dispose();
}
