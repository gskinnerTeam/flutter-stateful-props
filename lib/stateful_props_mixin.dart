// This mixin is just a light proxy around lifecycle events and a wrapper around build()
// [StatefulPropsManager] does most of the work here.
import 'package:flutter/widgets.dart';
import 'stateful_props_manager.dart';

mixin StatefulPropsMixin<W extends StatefulWidget> on State<W> {
  @protected
  StatefulPropsManager _propsManager = StatefulPropsManager<W>();

  int get buildCount => _propsManager.buildCount;
  bool _propsDirty = false;
  @override
  @protected
  void initState() {
    super.initState();
    // Inject stateful hooks into the manager, who will in-turn inject them into any managed Props.
    _propsManager.setContext(context);
    _propsManager.widget = widget;
    _propsManager.setState = setState;
    _propsManager.mounted = true;
  }

  /// Optional: Safe place to initialize props.
  void initProps() {}

  /// Required: Use this instead of regular build(), everything else is the same.
  Widget buildWithProps(BuildContext context);

  /// Optional: Safe place to cleanup the view. Rare to ever use this because Props clean themselves up.
  void disposeProps() {}

  /// ///////////////////////////////////////
  /// Register Props
  T syncProp<T>(StatefulProp<dynamic> Function(BuildContext c, W w) create, [String restoreId]) {
    //Because we can't cast generics of sub-classes, we have to do this little closure wrap-trick
    StatefulProp<dynamic> Function(BuildContext c, Widget w) callback = (c, w) => create(c, w as W);
    return _propsManager.syncProp(callback, restoreId);
  }

  T addProp<T>(StatefulProp<dynamic> prop, [String restoreId]) {
    return _propsManager.addProp(prop, restoreId);
  }

  /// TODO: Would be nice if we could avoid renaming build()...Could use a build() + PropBuilder(builder: (){}), but that adds nesting, ambiguity and boilerplate.
  /// ///////////////////////////////////////
  /// Lifecycle Hooks, proxy Stateful Lifecycle into the Manager
  /// Build: Need to replace the main build function to wrap any helper Widgets/Builders used by the StatefulProps.
  @override
  @protected
  Widget build(BuildContext _) {
    // Call initProps from within Build. This is so we can use Provider.watch instead of .read, inside of initProps.
    if (_propsManager.buildCount == 0) {
      initProps();
    } else if (_propsDirty) {
      _propsDirty = false;
      _propsManager.syncProps();
    }
    // Each Prop can wrap the Widget's tree with 1 or more Widgets, they are called in top-down order.
    Widget children = _propsManager.buildProps((c) => buildWithProps(c));
    _propsManager.buildCount++;
    return children;
  }

  @override
  void didUpdateWidget(W _) {
    _propsDirty = true;
    // Pass the latest widget into the propsManager
    _propsManager.widget = widget;
    super.didUpdateWidget(_);
  }

  @override
  void didChangeDependencies() {
    _propsDirty = true;
    super.didChangeDependencies();
  }

  @override
  @protected
  void dispose() {
    _propsManager.mounted = false;
    _propsManager.dispose();
    disposeProps();
    super.dispose();
  }

  /// //////////////////////////////////////
  /// State Restoration
  void restoreState(RestorationBucket oldBucket, bool initialRestore) {
    _propsManager.restoreState(oldBucket, initialRestore);
  }
}
