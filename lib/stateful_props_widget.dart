// Combines PropsStatelessWidgetMixin + PropsWidget widget into a single `extends` call
import 'package:flutter/widgets.dart';

import 'stateful_props.dart';

class HelloStateless extends PropsWidget<HelloStateless> {
  HelloStateless(this.someValue, this.someText);
  final bool someValue;
  final String someText;

  static final Ref<BoolProp> _isLoading = Ref();
  static final Ref<TapProp> _tap = Ref();

  @override
  void initProps() {
    syncProp(_tap, (c, w) => TapProp(() => print(w.someValue)));
    addProp(_isLoading, BoolProp());
  }

  @override
  Widget buildWithProps(BuildContext context) {
    return Text("Hello${use(_isLoading).value}");
  }
}

// Used to curry data from one widget to another.
class _Mutable<T> {
  T value;
}

// Used to define a static lookup key inside of PropWidgets
// Similar in usage to an enum: `prop1 = propsByKey[MyView.prop1]`
// IMPORTANT: This should always be used in a Static context or it will not work.
// DO: static final Ref someProp = Ref();
// DON'T: final Ref someProp = Ref(); // <-- Props will lose state each time Widget rebuilds
class Ref<T extends StatefulProp<dynamic>> {
  const Ref();
}

abstract class PropsWidget<W extends Widget> extends StatelessWidget {
  PropsWidget({Key key}) : super(key: key);
  static String nullPropError =
      "was called with a null Ref. ** All Refs should be non-null and static **: `static Ref<BoolProp> myBool = Ref()`";

  // Create a wrapper object we can use to add state into an 'immutable' class
  final _Mutable<StatefulPropsManager> _manager = _Mutable();

  //Return the custom _StatefulPropsElement which does most of the work
  @override
  StatelessElement createElement() => _PropsWidgetElement(this);

  // Provide accessors which will allows all descendants to access these props
  int get buildCount => _manager.value.buildCount;
  BuildContext get context => _manager.value.getContext();
  void Function(VoidCallback) get setState => _manager.value.setState;
  // Provide .mounted as a quality-of-life improvement for devs and to keep the API surface consistent.
  bool get mounted => _manager.value.mounted;

  // Associate a Prop to a create method. This method is re-run when the widget changes and the Prop
  // gets a copy of the new state so it can check for changes.
  T syncProp<T extends StatefulProp<dynamic>>(Ref<T> key, T Function(BuildContext c, W w) create, [String restoreId]) {
    assert(key != null, "$this.addProp() $nullPropError");
    // Because of how dart handles Generic, we can's cast Function(MyWidget) to Function(Widget),
    // but we can make it happen with a fancy little closure :) Declare the method signature that we need, then, internally do the cast, which will work correctly.
    T Function(BuildContext, Widget) _c = (c, w) => create?.call(c, w as W);
    return _manager.value.syncPropKeys(key, _c, restoreId);
  }

  // Add prop to the manager
  T addProp<T extends StatefulProp<dynamic>>(Ref<T> key, T defaultValue, [String restoreId]) {
    assert(key != null, "$this.addProp() $nullPropError");
    return _manager.value.addPropWithKey(key, defaultValue, restoreId);
  }

  // Use a property that has been previously added or sync'd
  T use<T extends StatefulProp<dynamic>>(Ref<T> key) {
    return _manager.value.useProp(key);
  }

  /// Optional override
  @protected
  void initProps() {}

  /// Required
  @protected
  Widget buildWithProps(BuildContext context);

  /// Optional override
  @protected
  void disposeProps() {}

  // Override build
  @override
  @protected
  Widget build(BuildContext context) {
    // Each Prop can wrap the Widget's tree with 1 or more Widgets, they are called in top-down order.
    return _manager.value.buildProps((c) => buildWithProps(c));
  }
}

// This is actually our BuildContext (Element implements Context)
class _PropsWidgetElement<W extends PropsWidget> extends StatelessElement {
  StatefulPropsManager _propsManager = StatefulPropsManager();

  // New element was created, this is the true first-mount for a StatelessWidget
  _PropsWidgetElement(W widget) : super(widget) {
    // Sync the manager once when the widget is created. Also called from update()
    _syncPropsManagerWithWidget(widget);
  }
  @override
  W get widget => super.widget as W;

  // A new widget has been created for this element
  // Inject the props manager with the latest context etc, then ask it to update it's props
  @override
  void update(W newWidget) {
    //_sync _must_ happen before _propsManager.didUpdateWidget,
    // otherwise all the Props may be working with old widget/context instances.
    _syncPropsManagerWithWidget(newWidget);
    _propsManager.didUpdateWidget();
    super.update(newWidget);
  }

  // Inject latest context, widget, setState into the manager
  // Wrap markNeedsBuild() in a setState-like so all Props have the same setBuild API
  void _syncPropsManagerWithWidget(W newWidget) {
    _propsManager.setContext(this);
    _propsManager.widget = newWidget;
    _propsManager.setState = (VoidCallback fn) {
      fn?.call();
      this.markNeedsBuild();
    };
    // Pass the state along from one PropsWidget to another
    newWidget._manager.value = _propsManager;
  }

  @override
  Widget build() {
    // We have to initialize Props in build to avoid issues with Provider.
    // Provider requires a context have an owner, but we don't have an owner until we call super.mount()
    // If we call super.mount(), build() is called, so it's too late to call initProps().
    if (_propsManager.buildCount == 0) {
      (_propsManager.widget as PropsWidget).initProps();
    }
    // Track buildCount as a quality-of-life improvement for devs.
    _propsManager.buildCount++;
    return super.build();
  }

  @override
  void mount(Element parent, dynamic newSlot) {
    _propsManager.mounted = true;
    super.mount(parent, newSlot);
  }

  // Dispose all props automatically and give the widget a chance to do any extra disposal (rare)
  @override
  void unmount() {
    _propsManager.dispose();
    widget.disposeProps();
    _propsManager.mounted = false;
    super.unmount();
  }
}
