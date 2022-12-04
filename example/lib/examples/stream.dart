import 'package:flutter/material.dart';
import 'package:reactives/stateful_props.dart';

class StreamDemo extends StatefulWidget {
  const StreamDemo({Key? key}) : super(key: key);

  @override
  State<StreamDemo> createState() => _StreamDemoState();
}

class _StreamDemoState extends State<StreamDemo> with StatefulPropsMixin {
  late final stream = StreamProp(
    this,
    Stream<int>.periodic(const Duration(seconds: 1), _updateStream),
  );
  late final streamController = StreamControllerProp(this);

  int _updateStream(int x) {
    // pump the value from this stream into the controller
    streamController.controller.sink.add((x));
    // return the new value to the first stream
    return x + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('value=${stream.snapshot.data}'),
        StreamBuilder(
          stream: streamController.controller.stream,
          builder: (_, snapshot) => Text('value=${snapshot.data}'),
        )
      ],
    );
  }
}
