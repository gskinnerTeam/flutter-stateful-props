import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:reactives/stateful_props.dart';

/// Port of [SingleTickerProviderStateMixin] on a [StatefulProp]
mixin SingleTickerStatefulPropMixin on StatefulProp implements TickerProvider {
  Ticker? _ticker;

  @override
  @protected
  Ticker createTicker(TickerCallback onTick) {
    _ticker = Ticker(
      onTick,
      debugLabel: kDebugMode ? 'created by ${describeIdentity(this)}' : null,
    );
    return _ticker!;
  }

  @override
  void didChangeDependencies() {
    if (_ticker != null) _ticker!.muted = !TickerMode.of(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    assert(() {
      if (_ticker == null || !_ticker!.isActive) return true;
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('$this was disposed with an active Ticker.'),
        ErrorDescription(
          '$runtimeType created a Ticker via its SingleTickerProviderStateMixin, but at the time '
          'dispose() was called on the mixin, that Ticker was still active. The Ticker must '
          'be disposed before calling super.dispose().',
        ),
        ErrorHint(
          'Tickers used by AnimationControllers '
          'should be disposed by calling dispose() on the AnimationController itself. '
          'Otherwise, the ticker will leak.',
        ),
        _ticker!.describeForError('The offending ticker was'),
      ]);
    }());
    super.dispose();
  }
}
