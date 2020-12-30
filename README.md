NOTE: This plugin is pre-release, and there are some missing API's and probably some  bugs. It will be marked as 1.0 when it's ready for primetime!
# stateful_props (beta)
**A simple and familiar way to encapsulate state and behavior across your Flutter Widgets**

## 🔨 Installation
```yaml
dependencies:
  stateful_props: ^0.0.1
```

### ⚙ Import

```dart
import 'package:stateful_props/stateful_props.dart';
```

#### Background
Flutter has a problem: there is no great way to re-use common logic across Widgets. Mixins are useful, but share a common scope, making them limited and prone to name clashes. Builders have encapsulated state, but turn your layout tree into a nested mess, reducing readability and obfuscating your layout code. There is a long discussion on the issue [here](https://github.com/flutter/flutter/issues/51752).

This manifests in the current areas currently:
* Having to override dispose for controllers, timers, streams etc
* Having to overriding didUpdate/didChange to sync internal state with widget and context dependencies
* Having to calling `setState((){})` each time you want to change some state and rebuild 
* Having to use builders/wrappers to get non-visual functionality like gestures, keyboard events and layout
* Having to write custom components or builders to encapsulate various combinations of state

`StatefulProps` offers a solution to this. "Props" are tiny, encapsulated bits of state, tied to the lifecycle of the Widget. Props can `init` and `dispose` themselves, they can add `Widgets` or `Builders` to the tree, and they can sync themselves when the Widget or its dependencies change.

Out of the box it comes with [all the standard Props](https://github.com/gskinnerTeam/flutter-stateful-props/tree/master/lib/props) you'll need (`AnimationPro`p, `TextEditProp`, `FocusProp`, `FutureProp` etc) but you can declare your own Props extremely easily as well. 

The core set of props provide some opinionated syntactic sugar where we think it's useful. They have a focus on pragmatism and brevity, over strict 1:1 adherence to the underlying Flutter API. For example, `onChange` events will contain the payload you would expect rather than the empty ones Flutter often provides, `AnimationProps` take a `double` over `Duration`, etc. A more pedantic set of Props would be quite easy to create if someone were so inclined (1-2 days work).

With the preamble out of the way, lets look at some code!

##### Use Case 1: Disposing Controllers
One of the main sources of bugs in Flutter is an `AnimationController`, or `Timer`, that is not disposed properly. 

With `StatefulProps` this is no longer something you have to think about:
```
class _MyViewState extends State with StatefulPropsMixin {
    TimerProp timer; //This holds a Timer inside
    AnimationProp anim1; //This holds an AnimationController inside
    
    @override
    initProps(){
      anim1 = addProp(AnimationProp(.1, autoStart: false)); 
      timer = addProp(TimerProp(.5, ()=>anim1.controller.forward(), repeat: true)));
    }
    
    @override
    Widget buildWithProp(BuildContext c){
        return FadeTransition(opacity: anim1.controller, ...);
    }
}
```
There are several things to note here:
* The `Timer` and the `AnimationController` are both cleaned up automatically. We can just "set it and forget it", knowing they are safe.
* We didn't need to use `TickerProviderMixin`, the StatefulProp has it's own `Ticker`, showing how Props can fully encapsulate their function
* The Animation automatically calls `setState` when it's playing, no need to `addListener(()=>setState((){}))`, use a `Transition` widget or an `AnimatedBuilder`. 

Already with this simple example, you can begin to see the benefits. A couple potential bugs have been eliminated, the Widget itself is more readable and maintainable when `dispose` does not exist, and we do not need to introduce builders into our tree.

##### Use Case 2: Having to override `didUpdateDependencies` and `didChangeWidget`
Probably the biggest pain-point in Flutter currently is keeping internal controllers sync'd with the outside state, either from the Widget or the Context (using `Provider` or `InheritedWidget`). 

For example, if you create something like: 
```
AnimationController(
   duration: widget.duration, 
   vsync: Provider.of<TickerProvider>(context))
```
This Controller will become out of sync if either of these dependencies change in the future. It's up to you to override `didChangeWidget` and implement the diff-check your self: `if(oldWidget.foo != widget.foo) // etc`. This is confusing for new devs, annoying for experienced devs, and prone to bugs for all.

StatefulProps solves this issue by using a `syncProp()` call when registering your Props:
```
    AnimationProp anim1; 
    @override
    initProps(){
      anim1 = syncProp((BuildContext c, MyView w) => 
         AnimationProp(w.duration, vsync: Provider.of<TickerProvider>(c))); 
    }
    @override
    Widget buildWithProp(BuildContext c){
        return FadeTransition(opacity: anim1.controller, ...);
    }
```
That's all you have to do! The `.duration` and `.vsync` values will always stay in sync with the Widget and Context, no `override` necessary, **no bugs possible**. All you have to do is remember to use `syncProp` instead of `addProp`!

##### Use Case 3: Having to call setState all the time
This is a minor one in comparison to the others, but it does get pretty annoying after a while, and it can lead to bugs occasionally.

Currently, anytime you want to update the view, you need to wrap your state change in `setState((){}))`, inevitably this begins to hurt readability, and you will either write a `function setValue(foo)` or encapsulate the variable with `get foo` and `set foo` accessors. Either way it costs you a few lines and a some repetitive typing. No big deal with 1 field, but after 3 or 4, this gets pretty ugly and can begin to overwhelm your more important code. 

`StatefulProps` solves this in a very simple way. There are simple primitive Props, like `IntProp`, `BoolProp`, that act as `ValueNotifier` style objects that **call `setState` when they change**. This is very handy for storing a simple `isLoading` or `currentTab` value. To build the basic `CounterApp` for example, we can just use an `IntProp _counter` and do `_counter.value++`:
```
    IntProp _counter;
    
    @override 
    void initProps(){
        _counter = addProp(IntProp(0));
    } 
    
    void _handleBtnPressed() => _counter.value++; //setState is handled by Prop
    
    @override 
    Widget buildWithProps(BuildContext context){
        return FlatButton(child: Text("${_counter.value}"), onPressed: _handleBtnPressed);
    }
```
With just one variable there is not much difference, but add a few more, and this code looks substantially cleaner with `StatefulProps`. Another benefit of using these primitive Props, is that you will get Restoration support essentially for free (coming soon!). If you're not familiar with Restoration API, you [can read up on it here](https://docs.google.com/document/d/1KIiq5CdqnSXxQXbZIDy2Ukc-JHFyLak1JR8e2cm3eO4/edit).


##### Use Case 4: Having to use Widgets/Builders for non-visual behaviors, leading to nesting hell

Builders actually do a great job of _encapsulating_ logic and state, the problem with them is _readability_. Long story short: nesting sucks when it comes to reading code. It also kinda sucks when writing. No one wants to deal with lining up endless brackets, moving things around is harder than it should be, and your more important content can get lost in a sea of behavioral wrappers.

`StatefulProps` solves this by allowing each Prop to wrap your tree, in additional Widgets. With this we can collapse many common Builders to a 1 or 2 lines and remove all indentation. Widgets like `GestureDetector`, `LayoutBuilder`, `TweenAnimationBuilder`, `MouseRegion`, `RawKeyboardListener` are all essentially replaced by `StatefulProps`.

Lets say we had a button widget that is clickable (+`GestureDetector`), but also needs to know it's parent's size so it can make some responsive decisions (+`LayoutBuilder`). On top of that, we want to detect when the mouse is over the widget (+`MouseRegion`), and we want to listen to the Keyboard to suppoer the enter key (+`RawKeyboardListener`). On top of all that, lets say we want to run a Future when something happens (+`FutureBuilder`).

You probably see where we are going with this :D In vanilla Flutter, we're looking at something like this:
```
  Widget build(BuildContext _) {
    return MouseRegion(
      onExit: (_) => setState(() => _isOver = false),
      onEnter: (_) => setState(() => _isOver = true),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _someFuture = _loadData()),
        child: RawKeyboardListener(
          onKey: _handleKeyPressed,
          child: LayoutBuilder(builder: (lc, constraints) {
            return FutureBuilder<int>(
                future: _someFuture,
                builder: (fc, snapshot) {
                  print(constraints.size.width);
                  print(_isOver.isHovered);
                  // Build tree
                });
          }),
        ),
      ),
    );
```

This is ~20 lines of code of pure boilerplate and a mess of indents. Before we've even written a single line of unique code. Notice how hard it is for your eye to actually read this tree, if you didn't already know what was in it, it's a lot of work!

With StatefulProps, this all just goes away:
```
    LayoutProp _layout;
    MouseRegionProp _mouse;
    
    @override 
    void initProps(){
        _layout = addProp(LayoutProp());
        _mouse = addProp(MouseRegionProp());
        addProp(TapProp(_handleTap));
        addProp(KeyboardProp(onPressed: _handleKeyDown)
    } 
    
    void _handleTap() => widget.onTap?.call();
    void _handleKeyDown(RawKeyEvent e) => print("$e");
    
    @override 
    Widget buildWithProps(BuildContext context){
       print(_layout.size.width);
       print(_mouse.isHovered);
        // Build tree
    }
```

Notice how much easier everything is to parse here. Removing the nesting allows us to present the display tree clearly and without visual clutter. 

Another interesting thing to note is that we do not keep a reference to the `TapProp` or the `KeyboardProp`. Since we are only interested in the callbacks we just call `addProp()` and forget about them. `StatefulProps` will handle everything whether you keep a reference or not. We _will_ keep a handle to `layout` and `mouse` because we want to use those later in our `buildWithProps()` method.

##### A word about dispose()
It is quite rare to need `dispose()` within your State when using `StatefulProps`, as Props clean up their own state by design. However, if needed you can override the standard `dispose()` method, and do any additional cleanup you need to do. 

## 👀  PropsWidget

Sometimes you really just don't want to create 2 classes for a simple Widget with a bit of State. That's where `PropsWidget` comes in! They are single-class variations of `StatefulPropsMixin` that are slightly cludgier to use, but they avoid the readability and line-count hit of having 2 classes. They do not replace `StatefulWidget`, but they are quite useful for when you want to attach just 1 or 2 pieces of state to an otherwise basic Widget.

Switching from the `StatefulPropsMixin` to the `PropsWidget` is pretty simple:
* Use `PropsWidget` rather than `State with StatefulPropsMixin`
* Change `ref = addProp(...)` and `ref = syncProp(...)` to `addProp(ref, ...)` and `syncProp(ref, ...)`
* Prop declarations change from `IntProp prop1` to `static Ref<IntProp> _prop1 = Ref()`
* To use a Prop, you call `use(ref)`

Other than those changes most everything else is identical. Both versions use the same Props under the hood, and the Widget overrides are identical. All of the examples shown here can be converted to PropsWidget using the above steps. 

This may seem like a lot, but when viewed side by side, you can see it's not so bad:
![](http://screens.gskinner.com/shawn/Photoshop_2020-12-28_22-44-10.png)

As you can see, there is some tradeoff here between the increased boilerplate of `use(...)` and `Ref()` vs. the reduced line count and readability win of a single Class, but you can decide which you like best and where. In our opinion the `PropsWidget` works great up to 2 or 3 Props, and after that a `StatefulPropsMixin` becomes a little nicer to work with as the boilerplate adds up.

## 👀  More Code Examples!

Below are a large number of different code examples, showing some different use cases that can be done outside of the box.

In all cases assume these code examples are inside of a `State with StatefulPropsMixin`. Everything here can be done in a `PropsWidget` as well, but we'll show the mixin versions as the code reads a little cleaner.

(TODO: Add More Examples)
* FutureBuilder 
* StreamBuilder 
* Gesture + Tap Listener
* ContextSafe Timer
* FocusProp
* TextController
* MouseRegion 
* LayoutBuilder
* Primitives
* GestureProp
* MultipleAnimations

## Creating your own Props
It's very easy to create your own Props. Just extend `StateProperty`, and override any of the optional methods. There are various flavors of Props you can look at for reference:
* Controller style props like [`AnimProp`](https://github.com/gskinnerTeam/flutter-stateful-props/blob/master/lib/props/animation_prop.dart) and [`FocusProp`](https://github.com/gskinnerTeam/flutter-stateful-props/blob/master/lib/props/focus_prop.dart)
* Pure callback props like [`GestureProp`](https://github.com/gskinnerTeam/flutter-stateful-props/blob/master/lib/props/gesture_prop.dart) and [`KeyboardProp`](https://github.com/gskinnerTeam/flutter-stateful-props/blob/master/lib/props/keyboard_prop.dart)
* Combinations of callbacks and state, like the [`MouseRegionProp`](https://github.com/gskinnerTeam/flutter-stateful-props/blob/master/lib/props/mouse_region_prop.dart)
* Builders that change context like [`LayoutProp`](https://github.com/gskinnerTeam/flutter-stateful-props/blob/master/lib/props/layout_prop.dart) and [`FutureProp`](https://github.com/gskinnerTeam/flutter-stateful-props/blob/master/lib/props/future_prop.dart) 
* Pure state encapsulation like [`IntProp`, `BoolProp` and `ValueProp`](https://github.com/gskinnerTeam/flutter-stateful-props/blob/master/lib/props/primitive_props.dart)

The available methods that your custom Prop can override are:
* `init()`
* `update(Prop latest)`
* `dispose()`
* `getBuilder(Widget Function(BuildContext) childBuilder)`
* `restoreState(registerFn)`

**You can override all or none of these**. Many props override `init`, `update` and `dispose`, but some override none at all. This is perfectly valid for Props that do not need any lifecycle hooks and just encapsulate some state + some logic. Going forward it may become best practice for all Props to implement `restoreState` whenever they can, but there will always be things like `MouseRegionProp` where restoration just doesn't make sense.


#### A note on composition and inheritance (and interfaces and mixins...)
Because `StatefulProps` are classes, and not functions, they benefit from all of the code re-use strategies available in Dart. Inheritence, composition, inrerfaces and mixins are all available as options when putting together your own `StatefulProps`. 

While there's many advanced things you can do with this extensibility, even the primitive examples are quite interesting. For example, if you look at the existing `IntProp` class, you can see that it simply extends a more basic `ValueProp<T>`:
```
class IntProp extends ValueProp<int> {
  IntProp([int defaultValue = 0]) : super(defaultValue);
}
```
Is build on top of this:
```
class ValueProp<T> extends StatefulProp<ValueProp<T>> {
  ValueProp(this._value, {this.onChange});
  T _value;
  void Function(T value) onChange;

  T get value => _value;
  set value(T value) {
    if (value == _value) return;
    setState(() {
      _value = value;
      onChange?.call(_value);
    });
  }
}
```
This is the entire Prop! It has no lifecycle hooks at all, except that it calls `setState()` when it changes.

All of the various primitives in the library are implemented of this generic `ValueProp` and the same Prop could be used as a " ValueNotifier" style object for your own types:
 ```
 ValueProp<MyThing> myThing;
 initProps(){
     myThing = addProp(ValueProp(MyThing()));
     print(myThing.value);
 }
 ...
 myThing.value = myThing.value; // This will not rebuild
 myThing.value = MyThing(); // This will rebuild
 ```
 And if you get sick of writing that generic, you can just define your own `ThingProp` by extending `ValueProp` yourself:
 ```
 class ThingProp extends ValueProp<ThingProp> {
  ThingProp([ThingProp defaultValue = null]) : super(defaultValue);
}
```
And then use it:
```
 ThingProp myThing;
 initProps(){
     myThing = addProp(ThingProp(Thing()));
 }
```
Another example of inheritance in action, is our shortcut handler for Taps. Since taps are by far the most common gesture, we created a dedicated mixin just for taps to reduce boilerplate. It extends `GestureProp` and just passes it a `onTap: ` value:
```
class TapProp extends GestureProp {
  TapProp(VoidCallback onTap) : super(onTap: onTap);

  @override
  ChildBuilder getBuilder(ChildBuilder childBuilder) => super.getBuilder(childBuilder);
}
```
We could just as easily have used composition here, but inheritence is more succinct in this case.

For an example of composition, you can look at the [`FutureProp`](https://github.com/gskinnerTeam/flutter-stateful-props/blob/master/lib/props/future_prop.dart), which internally uses a `ValueProp` to track it's future:
```
  @override
  void init() {
    // Use a ValueProp to handle our 'did-change' check
    futureValue = addProp?.call(ValueProp(initialFuture));
  }
```
As you can see composition is very easy, it has one rule: any Prop can add/sync any other Prop, as long as they do it in `init()`. We're still scratching the surface of what can be done here, and excited to see what people come up with!


### 📝 Contributing
 We are actively seeking support setting up some integrated testing and are welcoming all contributions and Pull Requests from the community. We would like `StatefulProps` to become a standard flutter lib, and that can only be done if the community embraces it!
 
 This package focuses on providing useful, pragmatic Props to get things done. The only requirement for adding a Prop to the core should be that many people want it to exist. We are happy to be guided by a simple system of votes and popularity for adding Props to the core.


## 🐞 Bugs/Requests

If you encounter any problems please open an issue. If you feel the library is missing a feature, please raise a ticket on Github and we'll look into it. Pull request are welcome.

## 📃 License

MIT License
