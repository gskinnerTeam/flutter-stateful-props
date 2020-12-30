NOTE: This plugin is in beta. There are missing API and likely some bugs. It will be marked as 1.0 when it's stable. 
_We're asking everyone to please try it out, and [log any issues that you find](https://github.com/gskinnerTeam/flutter-stateful-props/issues)._

# stateful_props (beta)
**A simple and familiar way to re-use behavior and improve readability in your Flutter Widgets:**
[![](http://screens.gskinner.com/shawn/Photoshop_2020-12-30_01-14-51.png)](http://screens.gskinner.com/shawn/Photoshop_2020-12-30_01-14-51.png)
### 🔨 Installation
```yaml
dependencies:
  stateful_props: ^0.1.1
```

### ⚙ Import

```dart
import 'package:stateful_props/stateful_props.dart';
```

## 📖 Background
Flutter has a problem: **there is no great way to re-use stateful behavior across Widgets**. Mixins are useful, but share a common scope, making them limited and prone to name clashes. Builders have encapsulated state, but turn your layout tree into a nested mess, reducing readability and obfuscating your layout code. There is a long discussion on the issue [here](https://github.com/flutter/flutter/issues/51752).

This manifests in some common pain-points:
* Having to `override dispose` for controllers, timers, streams etc
* Having to `override didUpdateDependencies/didChangeWidget` to sync state with dependencies
* Having to calling `setState((){})` each time you want to change some state and rebuild (which almost always go together)
* Having to use Builders to get non-visual functionality like gestures, keyboard/mouse events and layout constraints
* Having to write verbose custom Widgets or Builders just to encapsulate some state or behavior

`StatefulProps` offers a solution to this: "Props". Small, encapsulated state objects, tied to the lifecycle of the Widget. Each Widget has a list of these "mini states". Props can `init` and `dispose` themselves, they can add Widgets to the tree, and they can sync themselves when dependencies change.

## 💡 Inspiration
`StatefulProps` is heavily inspired by [hooks](https://youtu.be/dpw9EHDh2bM?t=1092) (and prior art like [DisplayScript](http://displayscript.org/introduction.html)), but it takes a less functional approach, leaning into classic OOP techniques. You can still do everything you could do with `hooks`(functional composition) but other patterns like inheritence, mixins, interfaces and abstract classes are all on the table as well. 

For more on extensibility and custom Props scroll down to **Creating your own Props** section.

## 🕹️ Usage
Out of the box it comes with [all the standard Props](https://github.com/gskinnerTeam/flutter-stateful-props/tree/master/lib/props) you'll need (`AnimationProp`, `TextEditProp`, `FocusProp`, `FutureProp` etc) but you can declare your own Props extremely easily as well. 

The core set of props provide some opinionated syntactic sugar where we think it's useful. They have a focus on pragmatism and brevity, over strict 1:1 adherence to the underlying Flutter API. For example: `onChange` events will contain the payload you would expect rather than the empty ones Flutter often provides; `AnimationProps` take a `double` over `Duration`; etc.  

**It is important to note that the opinionated nature of the core Props is seperate from the underlying system. A set of Props with strict-adherence would be very easy to create if someone were so inclined.** The average size of a Prop in the lib now is around 40 lines, and that's with the syntactic sugar.

With the preamble out of the way, lets look at some code!

### Use Case 1: Disposing Controllers
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
* We didn't need to use `TickerProviderMixin`, the StatefulProp has it's own `Ticker`, showing how Props can fully encapsulate their function.
* The Animation automatically calls `setState` when it's playing, no need to `addListener(()=>setState((){}))`, use a `Transition` widget or an `AnimatedBuilder`. 
* `AnimationProp` has syntax sugar like `autoStart`, `autoBuild` and a `double seconds` value insted of `Duration duration` (we provide built-in extensions for `duration.double` and `double.duration` for quick conversion). 
* Not seen here, `AnimationProp` also has other cool helpers like `tweenDouble({double begin, double end, Curve curve})` which makes it super easy to add tweens onto a controller.

Already with this simple example, you can begin to see the benefits. A couple potential bugs have been eliminated, the Widget itself is more readable and maintainable when `dispose` does not exist, and we do not need to introduce builders into our tree.

### Use Case 2: Having to override `didUpdateDependencies` and `didChangeWidget`
Probably the biggest pain-point in Flutter currently is keeping internal controllers synced with the outside state, either from the Widget or the Context (using `Provider` or `InheritedWidget`). 

For example, if you create something like this inside `initState`: 
```
anim1 = AnimationController(
   duration: widget.duration, 
   vsync: Provider.of<TickerProvider>(context))
```
This Controller will become out of sync if either of these dependencies change in the future. It's up to you to override `didChangeWidget` and implement the diff-check your self: `if(oldWidget.foo != widget.foo) // blah blah blah`. This is confusing for new devs, annoying for experienced devs, and prone to bugs for all.

StatefulProps solves this issue by using a `syncProp()` call when registering your Props:
```
animProp1 = syncProp((c, w) => AnimationProp(
    w.duration, 
    vsync: Provider.of<TickerProvider>(c))); 
```
That's all you have to do! The `.duration` and `.vsync` values will always stay in sync with the Widget and Context, no `override` necessary, **no bugs possible**. All you have to do is remember to use `syncProp` instead of `addProp`, the `StatefulProp` will take care of the sync and the diff.

### Use Case 3: Having to call setState all the time
This is a minor one in comparison to the others, but it does get pretty annoying after a while, and it can lead to bugs occasionally.

Currently, anytime you want to update the view, you need to wrap your state change in `setState((){}))`, inevitably this begins to hurt readability, and you will either write a `function setFoo(value)` or encapsulate the variable with `get foo` and `set foo` accessors. Either way it costs you a few lines and some wasted typing. No big deal with 1 field, but after 3 or 4, this gets pretty ugly and can begin to overwhelm your more important code. 

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


### Use Case 4: Having to use Widgets/Builders for non-visual behaviors, leading to nesting hell
Builders actually do a great job of _encapsulating_ logic and state, the problem with them is _readability_. 4 out of 5 ~~dentists~~ developers agree: nesting sucks when it comes to reading code. It also kinda sucks when writing. No one wants to deal with lining up endless brackets, moving things around is harder than it should be, and your more important content can get lost in a sea of behavioral wrappers.

`StatefulProps` solves this by allowing each Prop to wrap your tree, in additional Widgets. With this we can collapse many common Builders to a 1 or 2 lines and remove all indentation. Widgets like `GestureDetector`, `LayoutBuilder`, `TweenAnimationBuilder`, `MouseRegion`, `RawKeyboardListener` are all essentially replaced by `StatefulProps`.

Lets say we had a button widget that is clickable (+`GestureDetector`), but also needs to know it's parent's size so it can make some responsive decisions (+`LayoutBuilder`). On top of that, we want to detect when the mouse is over the widget (+`MouseRegion`), and we want to listen to the Keyboard to support the [ENTER] key (+`RawKeyboardListener`). On top of all that, lets say we want to run a Future when something happens (+`FutureBuilder`).

You probably see where we are going with this :D In vanilla Flutter, we're looking at something like this:
```
  Widget build(BuildContext _) {
    print(_isOver.isHovered);
    return MouseRegion(
      onExit: (_) => setState(() => _isOver = false),
      onEnter: (_) => setState(() => _isOver = true),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _someFuture = _loadData()),
        child: RawKeyboardListener(
          onKey: _handleKeyPressed,
          child: LayoutBuilder(builder: (lc, constraints) {
            print(constraints.size.width);
            return FutureBuilder<int>(
                future: _someFuture,
                builder: (fc, snapshot) {
                  print(snapshot.hasData);
                  // Build tree
                });
          }),
        ),
      ),
    );
```

This is ~20 lines of code of pure boilerplate and a mess of indents. Before we've even written a single line of unique code! **As an experiment, try and find the 3 `print()` calls and the `//Build Tree` above.** Not super fun, right? That was way harder than it ought to be.

With `StatefulProps`, this all just goes away:
```
    LayoutProp _layout;
    MouseRegionProp _mouse;
    FutureProp _futureProp;
    
    @override 
    void initProps(){
        _layout = addProp(LayoutProp());
        _mouse = addProp(MouseRegionProp());
        _futureProp = addProp(FutureProp(_loadData())
        addProp(TapProp(() => _futureProp.future = _loadData())));
        addProp(KeyboardProp(onPressed: _handleKeyPressed)
    } 
    
    @override 
    Widget buildWithProps(BuildContext context){
       print(_layout.size.width);
       print(_mouse.isHovered);
       print(_futureProp.snapshot.hasData);
        // Build tree
    }
```

Notice how much easier everything is to parse here, finding the unique/custom code is now extremely easy. Removing the nesting allows us to present the display tree clearly and without visual clutter. Our unique code is front and center, and the boilerplate and nesting is just gone! 

Another interesting thing to note is that we do not keep a reference to the `TapProp` or the `KeyboardProp`. Since we are only interested in the callbacks we just call `addProp()` and forget about them. `StatefulProps` will handle everything whether you keep a reference or not. We _will_ keep a handle to `layout`, `futureProp` and `mouse` because we want to use those later in our `buildWithProps()` method.

### A word about dispose()
It is quite rare to need `dispose()` within your main `State<T>` as Props (by design) clean up their own state. However, if needed you can override the standard `dispose()` method, and do your thing! 

## 👀  PropsWidget
Sometimes you really just don't want to create 2 classes for a simple Widget with a bit of State. That's where `PropsWidget` comes in! They are single-class variations of `StatefulPropsMixin` that are slightly cludgier to use, but they avoid the readability and line-count hit of having 2 classes. They do not replace `StatefulWidget`, but they are quite useful for when you want to attach just 1 or 2 pieces of state to an otherwise basic Widget.

Switching from the `StatefulPropsMixin` to the `PropsWidget` is pretty simple:
* Use `PropsWidget` rather than `State with StatefulPropsMixin`
* Change `ref = addProp(...)` and `ref = syncProp(...)` to `addProp(ref, ...)` and `syncProp(ref, ...)`
* Prop declarations change from `IntProp prop1` to `static Ref<IntProp> _prop1 = Ref()`
* To use a Prop, you call `use(ref)` which can **not** be called from `initProps`

This may seem like a lot, but when viewed side by side, you can see it's not so bad:
![](http://screens.gskinner.com/shawn/Photoshop_2020-12-30_01-23-03.png)

Other than those changes most everything else is identical. Both versions use the same Props under the hood, and the Widget overrides are identical:
```
class MyView extends PropsWidget {
    static final Ref<TimerProp> _timer = Ref(); //This holds a Timer inside
    static final Ref<AnimationProp> _anim1 = Ref(); //This holds an AnimationController inside

    AnimationProp get anim1Prop => use(_anim1); // Setup a one-line getter to wrap the `use()` call

    @override
    initProps(){
      addProp(_anim1, AnimationProp(.1, autoStart: false)); 
      // The use() call in the closure is fine, cause it's not called right now
      final anim = addProp(_timer, TimerProp(.5, ()=>anim1Prop.controller.forward(), repeat: true)));
      // If we need to use a prop here, we can just use the instance returned from add/sync
      anim.controller.forward(); 
    }
    
    @override
    Widget buildWithProp(BuildContext c){
        return FadeTransition(opacity: anim1Prop.controller, ...);
    }
}
```

**This is the entire Widget!** No extra 5 lines of boilerplate. As you can see, there is some trade-off here between the increased boilerplate of `use(...)` and `Ref()` vs. the reduced line count and readability win of a single Class, and also some increased complexity overall. You can decide which you like best and where. In our experience the `PropsWidget` works great up to 2 or 3 Props, and after that a `StatefulPropsMixin` becomes a little nicer to work with as the `Ref` and `use` boilerplate adds up.

## 👀  More Code Examples!
Below are a large number of different code examples, showing some different use cases that can be done with the core Props.

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


### A note on composition and inheritance (and interfaces and mixins...)
Because `StatefulProps` are classes, and not functions, they benefit from all of the code re-use strategies available in Dart. Inheritence, composition, inrerfaces and mixins are all available as options when putting together your own `StatefulProps`. 

While there's many advanced things you can do with this extensibility, even the primitive examples are quite interesting. For example, if you look at the existing `IntProp` class:
```
class IntProp extends ValueProp<int> {
  IntProp([int defaultValue = 0]) : super(defaultValue);
}
```
You can see that it simply extends a more basic `ValueProp<T>`:
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
This is the entire code for both these Props! They have no lifecycle hooks at all, except that they call `setState()` when their value changes.

All of the various primitives in the library are implemented on this generic `ValueProp` and the same Prop could be used as a " ValueNotifier" style object for your own types:
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
 If (when) you get sick of writing out the generic, you can just define your own `ThingProp` by extending `ValueProp` yourself:
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
Another example of inheritance is our shortcut handler for Taps. Since taps are by far the most common gesture, we created a dedicated `TapProp(VoidCallback)` to reduce boilerplate as low as possible. It extends `GestureProp` and just passes it a `onTap: ` value:
```
class TapProp extends GestureProp {
  TapProp(VoidCallback onTap) : super(onTap: onTap);
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
As you can see composition is very easy, it has one rule: 
* **any Prop can `add`/`sync` any other Prop, as long as they do it in `init()`!** 

We're still scratching the surface of what can be done here, and excited to see what people come up with.


## 📝 Contributing
 We are actively seeking support setting up some integrated testing and are welcoming all contributions and Pull Requests from the community. We would like `StatefulProps` to become a standard flutter library, and that can only be done with community support.


## 🐞 Bugs/Requests

If you encounter any problems please open an issue. If you feel the library is missing a feature, please create an issue on Github. 

## 📃 License

MIT License
