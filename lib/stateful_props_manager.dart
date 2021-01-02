import 'package:flutter/material.dart';

import 'stateful_props.dart';

extension SecondsToDurationExtension on double {
  Duration get duration => Duration(milliseconds: (this * 1000).round());
}

extension DurationToSecondsExtension on Duration {
  double get seconds => this.inMilliseconds * .001;
}

// The core manager that tracks props for both the StatefulPropsMixin and PropsWidget.
// One of these exists for each Widget, and it is basically just a wrapper around a list of StatefulProps.
// * Maintains a list of each Prop `List<StatefulProp> _values = [];`
// * Also maintains a `Map<Ref, StatefulProp> _propsByKey` which is used by the PropWidget to track instance variables w/ static Refs as keys
// * Requires setState, context and widget injected into it (provided by [StatefulPropsMixin] or [PropsWidget])
// * Injects `context` and `setState` into each Prop
// * Calls lifecycle methods on each Prop (init, didUpdate, dispose, restore)
class StatefulPropsManager<W extends Widget> {
  static bool logDuplicateRefWarnings = true;

  // List of all props that have been registered.
  // Props can not be removed, only added. Their lifecycle is entirely bound to the owning State or Widget.
  List<StatefulProp<dynamic>> _values = [];
  Map<Ref, StatefulProp<dynamic>> _propsByKey = {};
  int buildCount = 0;

  // Widget/State Dependencies
  void Function(VoidCallback) setState;
  W widget;
  // Prop might needs to know if the view is mounted, this will hold that state.
  bool mounted = false;

  BuildContext _context;
  void setContext(BuildContext value) => _context = value;
  BuildContext getContext() => _context;

  // Calls addProp() and also injects the `create` method into the prop, so it can be called later.
  T syncProp<T>(StatefulProp<dynamic> Function(BuildContext c, W w) create, [String restoreId]) {
    // Use the builder to create the first instance of the property.
    StatefulProp<dynamic> prop = addProp(create(getContext(), widget));
    // Inject the create builder so we can compare on didUpdateWidget
    prop.create = create as StatefulProp<dynamic> Function(BuildContext, Widget);
    return prop as T;
  }

  // Add a new Prop that will be synced with lifecycle. This should only be called from `initProps` or `initState`.
  T addProp<T>(StatefulProp<dynamic> prop, [String restoreId]) {
    assert(getContext() != null, '''
      Looks like you're trying to addProp/syncProp before the StatefulPropManger has been initialized. Make sure you've called initState.super() before calling add/syncProp. Or just override initProp() instead.''');
    // Inject common hooks needed for all Props
    prop.context = getContext();
    prop.restoreId = restoreId;
    prop.setState = this.setState;
    prop.addProp = addProp;
    prop.syncProp = syncProp;
    prop.isMounted = mounted;
    _values.add(prop);
    prop.init();
    return prop as T;
  }

  T syncPropKeys<T extends StatefulProp<dynamic>>(Ref<T> ref, T Function(BuildContext c, Widget w) create,
      [String restoreId]) {
    // The first time this is called for a given create method, call the method, and cache the result.
    if (_propsByKey.containsKey(ref) == false) {
      // Use SyncProp to add the object, inject `create` and return us the new instance
      _propsByKey[ref] = syncProp(create, restoreId);
    } else if (logDuplicateRefWarnings) {
      print(
          "WARNING @ $widget: syncProp(Ref) was called twice on the same Ref. Check that you aren't calling syncProp() twice on the same reference, this is likely a mistake.");
    }
    // All future requests fo the object, get the cache
    return _propsByKey[ref] as T;
  }

  T addPropWithKey<T extends StatefulProp<dynamic>>(Ref<T> key, T prop, [String restoreId]) {
    if (_propsByKey.containsKey(key) == false) {
      // Add prop to Map and register with the manager using the same addProp() as the StatefulMixin
      _propsByKey[key] = prop;
      addProp(prop);
    } else if (logDuplicateRefWarnings) {
      print(
          "WARNING @ $widget: addProp(Ref) was called twice on the same Ref object. Check that you aren't calling addProp() twice with the same reference, this is likely a mistake.");
    }
    return prop;
  }

  T useProp<T extends StatefulProp<dynamic>>(Ref<T> ref) {
    //assert(_propsByRef.containsKey(ref),"You appear to be using a PropRef before it has been added or sync'd. Make sure addProp(refA) or syncProp(refA) has been called before you call useRef(refA))");
    if (_propsByKey.containsKey(ref)) {
      return _propsByKey[ref] as T;
    }
    return null;
  }

  // Wrap local build() call in additional "parent" build calls. Fire them all at the end from top to bottom.
  // This ensures the local build() call goes last and gets the latest state from the builders above it.
  Widget buildProps(ChildBuilder childBuild) {
    _values.forEach((prop) => childBuild = prop.getBuilder(childBuild));
    return childBuild(getContext());
  }

  // Manager will run through each prop, giving it a chance to diff the new state and update itself if needed
  // For each prop:
  //    * Use the current context and widget, to create a newProp.
  //    * Pass that newProp to each existingProp so they can update themselves.
  // The existingProps are mutable and do not get replaced, they just consume and discard newProp.
  void syncProps() {
    // Sync any props that have a create method:
    _values.forEach((property) {
      if (property.create != null) {
        StatefulProp<dynamic> newProp = property.create(getContext(), widget);
        property.update(newProp);
      }
    });
  }

  // This implements one of the required methods for RestorationMixin.
  // All that's need to implement Restoration, is to add RestorationMixin and supply a restorationId for the State
  // and another id for each prop: BoolProp(restoreId: "isFlippedOver"))
  void restoreState(RestorationBucket oldBucket, bool initialRestore) {
    //Iterate each property, and give it a chance to restore itself.
    _values.forEach((prop) {
      if (prop.restoreId != null) {
        // Ignore the protected warning here. Since Props are always a child of some state, they can act as restoration delegates
        // ignore: invalid_use_of_protected_member,
        prop.restoreState((this as RestorationMixin).registerForRestoration);
      }
    });
  }

  void dispose() {
    _values.forEach((p) {
      p.dispose();
      p.isMounted = false;
    });
  }
}

// Extend this base class to create your own StatefulProperty. Every method is optional, implement only what you need.
// Available overrides are: init(), build(), update(), dispose(), restoreState()
typedef ChildBuilder = Widget Function(BuildContext);

// Base class that all Props extend. It consists of a bunch of optional overrides (init/update/dispose/getBuilder etc),
// and some of callbacks injected by the PropsManager (addProp, syncProp, setState etc)
abstract class StatefulProp<T> {
  /// ////////////////////////////////
  /// Life cycle
  // Optional: Create whatever state you need to store, if any (maybe you are only wrapping events, like
  // GestureDetector, or data, like LayoutBuilder).
  @protected
  void init() {}

  // Optional: Wrap builders Widgets here if needed, (like GestureDetector())
  @protected
  ChildBuilder getBuilder(ChildBuilder childBuild) => childBuild;

  // Optional: Update internal state if the Widget has changed (like animation.duration)
  @protected
  void update(T newProp) {}

  // Optional: Implement if you have something to cleanup (textEditingController.dispose)
  @protected
  void dispose() {}

  // Optional: Support Restoration; call `register()` with any RestorableValues you have internally.
  @protected
  void restoreState(void Function(RestorableProperty<Object> property, String restorationId) register) {}

  /// ////////////////////////////////
  /// Internal

  // Utility method to reduce boilerplate when implementing didChangeUpdates, used by sub-classes, not meant to be overridden.
  bool compareValuesForChange<T>(T oldVal, T newVal) {
    return oldVal != newVal && newVal != null;
  }

  /// StateManager Hooks
  // Injected by the [StatefulPropertyMixin], create a StatefulProperty instance from a Widget
  @protected
  StatefulProp<dynamic> Function(BuildContext c, Widget widget) create;

  // Injected by the [StatefulPropertyMixin], rebuilds state when Property desires it
  @protected
  void Function(VoidCallback fn) setState;

  // Injected by the the manager when a prop is added
  @protected
  BuildContext context;

  @protected
  bool isMounted;

  // The Add/Sync methods are injected from the manager so props can register sub-props allowing composition
  T Function<T>(StatefulProp<dynamic> prop, [String restoreId]) addProp;
  T Function<T>(StatefulProp<dynamic> Function(BuildContext c, Widget w) create, [String restoreId]) syncProp;

  /// Restoration
  // Injected when calling [ StatefulPropertyMixin.registerProperty(restoreId: "foo") ]
  @protected
  String restoreId;
}
