import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stateful_props/stateful_props.dart';

/// Subscribes to a [Stream] and returns its current state as an [AsyncSnapshot].
/// * [preserveState] determines if the current value should be preserved when
/// changing the [Stream] instance.
class StreamProp<T> extends StatefulProp {
  StreamProp(
    StatefulPropsManager manager,
    this.stream, {
    T? initialData,
    this.onChange,
  }) : super(manager) {
    if (initialData != null) {
      _snapshot = AsyncSnapshot.withData(ConnectionState.waiting, initialData);
    }

    _subscription = stream.listen((T data) {
      _snapshot = afterData(_snapshot, data);
      _onChange();
    }, onError: (Object error, StackTrace stackTrace) {
      _snapshot = afterError(_snapshot, error, stackTrace);
      _onChange();
    }, onDone: () {
      _snapshot = afterDone(_snapshot);
      _onChange();
    });
  }

  final Stream<T> stream;
  StreamSubscription<T>? _subscription;

  AsyncSnapshot<T> _snapshot = const AsyncSnapshot.waiting();
  AsyncSnapshot get snapshot => _snapshot;

  @protected
  final void Function(AsyncSnapshot<T>)? onChange;

  void _onChange() {
    final lis = onChange;
    if (lis != null) {
      lis(_snapshot);
    } else {
      manager.scheduleBuild();
    }
  }

  AsyncSnapshot<T> afterConnected(AsyncSnapshot<T> current) => current.inState(ConnectionState.waiting);

  AsyncSnapshot<T> afterData(AsyncSnapshot<T> current, T data) {
    return AsyncSnapshot<T>.withData(ConnectionState.active, data);
  }

  AsyncSnapshot<T> afterError(AsyncSnapshot<T> current, Object error, StackTrace stackTrace) {
    return AsyncSnapshot<T>.withError(ConnectionState.active, error, stackTrace);
  }

  AsyncSnapshot<T> afterDone(AsyncSnapshot<T> current) => current.inState(ConnectionState.done);

  AsyncSnapshot<T> afterDisconnected(AsyncSnapshot<T> current) => current.inState(ConnectionState.none);

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}
