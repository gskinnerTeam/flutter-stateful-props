import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stateful_props/stateful_props.dart';

// Subscribes to a Future and returns its current state as an AsyncSnapshot.
// preserveState determines if the current value should be preserved when changing the Future instance.
//
class FutureProp<T> extends StatefulProp with ChangeNotifier {
  FutureProp(
    StatefulPropsManager manager,
    Future<T> future, {
    this.initialData,
    this.preserveState = true,
    bool autoBuild = true,
  }) : super(manager) {
    // Create snapshot value prop
    _snapshot = ValueProp<AsyncSnapshot<T>>(
      manager,
      initial: const AsyncSnapshot.waiting(),
      autoBuild: autoBuild,
    )..addListener(notifyListeners);
    // Load future
    _setFuture(future, firstLoad: true);
    _future = future;
  }
  final T? initialData;
  // Holds the current future
  late Future<T> _future;
  late final ValueProp<AsyncSnapshot<T>> _snapshot;

  bool preserveState;

  AsyncSnapshot<T> get snapshot => _snapshot.value;

  void _setFuture(Future<T> future, {required bool firstLoad}) {
    // Preserve existing state?
    if (preserveState && firstLoad == false) {
      _snapshot.value = AsyncSnapshot.withData(ConnectionState.waiting, snapshot.data!);
    }
    // Lose state, reset to initialData if we have some
    else if (snapshot.hasData) {
      _snapshot.value = (initialData == null)
          ? const AsyncSnapshot.waiting()
          : AsyncSnapshot.withData(ConnectionState.waiting, initialData!);
    }
    // Listen to progress on the future
    future.then(
      (data) {
        if (future != _future) return;
        _snapshot.value = AsyncSnapshot.withData(ConnectionState.done, data);
      },
      onError: (err, st) {
        if (future != _future) return;
        _snapshot.value = AsyncSnapshot.withError(ConnectionState.done, err, st);
      },
    );
  }

  Future<T> get future => _future;
  set future(Future<T> value) {
    _setFuture(value, firstLoad: false);
    _future = value;
  }
}
