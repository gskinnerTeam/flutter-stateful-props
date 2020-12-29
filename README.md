NOTE: This plugin is pre-release, and there are some missing API's and probably some  bugs. It will be marked as 1.0 when it's ready for primetime!
# stateful_props
**A simple and familiar way to encapsulate state and behavior across your Flutter Widgets:**
Inspired by hooks (and prior art like DisplayScript) but embraces a classic OOP approach that fits well with Flutter and Dart.

`StatefulProps` can be thought of as "**encapsulated lifecycle mixins**", or alternatively, as "**micro-states**". They have access to the full state/widget lifecycles (including a build() call), but maintain their own unpolluted namespace. They can even work on StatelessWidgets!

For more information on the rationale and thinking around StatefulProps, check out this blog post: ADD LINK

## 🔨 Installation
```yaml
dependencies:
  stateful_props: ^0.0.1
```

### ⚙ Import

```dart
import 'package:stateful_props/stateful_props.dart';
```

### The goals of this package are: 
* Prevent common bugs around init/dispose/didUpdateWidget/didChangeDependencies  
* Provide a method of re-using common logic or behaviors across Widgets
* Improve readability and reduce boilerplate by reducing nesting
* Be easy and familiar for existing Flutter devs (no foreign concepts or 'magic')
* Provide a core set of opinionated "Props" with helper methods for common use cases

In concrete terms, this library will stop bugs by doing things like:
* Ensure `dispose()` is called on all [`Animation`, `TextEditing`, `Scroll`]`Controller`'s  
* Remove repetitive `setState` calls inside your components, just change values and the views rebuild
* Automatically handle Widget and Context dependancies changes
* Add common primitive defaults like `IntProp(0)`, `DoubleProp(0)` and `BoolProp(false)`. 

It will reduce boilerplate and increase readability by:
* Reduce all `GestureDetector`, `MouseRegion`, `KeyboardListener` etc builders to 1 or 2 lines of non-nested code
* Eliminate the need for nested builders like `TweenAnimationBuilder`, `StreamBuilder`, `FutureBuilder` etc which are hard to read  
* Add quality of life helpers like `animProp.isGoingForward/isGoingBack/isPlaying`, `mouseProp.isHovered`, `mouseProp.normalizedOffset`, `scrollProp.onChanged(prop.position)` etc

This image shows how it can help flatten the tree, but removing extraneous builders or wrappers that have no visual purpose for being in the tree:
![](https://user-images.githubusercontent.com/736973/103203905-4a6dfc80-48b3-11eb-9933-1082c3e25404.png)

This image shows how much boilerplate can be removed by encapsulating common `didUpdate` and `dispose` logic for a pair of AnimationController's:
![](http://screens.gskinner.com/shawn/Photoshop_2020-12-28_23-25-14.png)

When you combine the ability to flatten Builders and Widgets with the ability to automatically update and dispose Controllers, you can increase the readability of your code dramatically as well as prevent bugs before they happen!

## 🕹️ Usage
From a high level, it works like this:
```
  //Props are instance vars that wrap some internal state
  AnimationProp anim;  // this holds an AnimationController
  TextEditProp text; // this holds an TextEditingController
  IntProp counter;  //This holds an int
  ... 
  // All props must be registered in initProps()
  void initProps(){
    anim = addProp(AnimationProp(0.5));  
    text = addProp(TextProp(initialText: "Hello"));
    count = addProp(IntProp(0));
  } 
  ...  
   // Use the Prop in your tree:
  Widget buildWithProps(BuildContext context){
    double value = anim.value;
    return MyWidget(color: Colors.black.withOpacity(value), child: ..., );
  }
  
   // Change the props, they will rebuild the view themselves as needed
  void _handlePressed(){
    anim.controller.forward();
    text.controller.selection = ... 
    count.value += 1; 
  }
}
```
Hopefully that doesn't look to crazy! We just change `initState` => `initProps` and `build` => `buildWithProps` but everything else is the same as a regular old `State`.

This package suports both Stateful and "Stateless" implementations, `StatefulPropsMixin` and `PropsWidget` respectively. The `PropsWidget` is nice for very small components, but we'll start with the `StatefulPropsMixin` first as it will be the most familiar and has the least amount of boilerplate.

## 🕹️  - StatefulPropsMixin

There are a few steps to start with:
* Add the `StatefulPropsMixin` to your state
* override `initProps` instead of `initState` and initialize your props
* override `buildWithProps` instead of `build()` and use your props

Here's a basic CounterApp implementation:
```
(+4 ^  lines for StatefulWidget) 
class _MyViewState extends State<MyView> with StatefulPropsMixin {
    IntProp _counter;
    
    @override 
    void initProps(){
        _counter = addProp(IntProp(0));
    } 
    
    void _handleBtnPressed() => _counter.value++; //setState is handled by Prop
    
    @override 
    Widget buildWithProps(BuildContext context) => FlatButton(child: Text("${_counter.value}"), onPressed: _handleBtnPressed);
}
```

You can see that we are using a `StatefulProp` called `IntProp`, which simply holds a value, and rebuilds the view anytime that value is changed. This replaces the common pattern of using a `ValueNotifier<int>` + `ValueListenableBuilder` or repeatedly calling `setState(()=> _myInt = value)`.

**Ok, so an int is kinda boring, you could do that easily enough with regular old `setState`.** Lets add an animation with a delayed start. Something that generally requires a custom widget, or manually creating/disposing an `AnimationController`. The former creates extra work, the latter is bug-prone, both have a lot of code duplication.
```
class _MyViewState extends State<MyView> with StatefulPropsMixin {
    AnimationControllerProp _anim;
    @override 
    void initProps(){
        _anim = addProp(AnimationControllerProp(0.5));
        Future.delayed(Duration(seconds: 1), ()=>_anim.controller.forward());
    } 
    @override 
    Widget buildWithProps(BuildContext context) => Opacity(opacity: _anim.value, child: ...);
}
```
Notice how we don't have to dispose the `AnimationController` here, it is handled automatically by the Prop. You will never again see an error about a improperly disposed `FocusNode`, `AnimationController` or `TextEditingController`! This goes the same for your own Controllers as well, which you can wrap in a Prop, to make sure no one on the teams forgets those `dispose()` calls!

Now lets take it a bit further and add some interaction. **Lets say we want to make the animation start over when the Widget is tapped**. Normally this would require a `GestureDetector` which would eat up 3 lines and add a level of nesting (for a compeletely non-visual element). 

Adding this with a `StatefulProp` is easy:
```
class _MyViewState extends State<MyView> with StatefulPropsMixin {
    AnimationControllerProp _anim;
    @override 
    void initProps(){
        _anim = addProp(AnimationControllerProp(0.5));
        addProp(GestureDetectorProp(onTap: ()=> _anim.controller.forward()))
    } 
    @override 
    Widget buildWithProps(BuildContext context) => Opacity(opacity: _anim.value, child: ...);
}
```
Notice how we don't even declare an instance property for the `GestureDetectorProp`. Since it is just providing callbacks, and has no internal state we care about, we don't need to keep a reference at all. We can just call `addProp` once to register it, and `StatefulProps` will take care of wrapping the `GestureDetector` for us.


The final use case to discuss for the Stateful implementation is the `syncProp`. You use this if your Prop has some dependancy on context (using Provider or InheritedWidget) or on the properties of the enclosing Widget. This is a cause of many hard to spot errors in Flutter apps and reduces the effectiveness of hot-reload.

Consider a `State` like this, it declares an AnimationController, with a `widget.duration` and `context.read` dependencies. 
```
class MyView extends StatefulWidget {
  MyView(this.duration);
  final double duration;
  @override
  _MyViewState createState() => _MyViewState();
}

class _MyViewState extends State<MyView> {
    void initState(){
        super.initState();
        animController = AnimationController(
          widget.duration, 
          vsync: context.read<TickerProvider>());
    }
}
```
**In the above code there are actually 2 potential bugs.** If either the provided `Duration` or the `widget.vsync` values change, the `AnimationController` would not be updated to match, **it would be out of sync**. To fix this traditionally, devs need to override `didUpdateWidget` or `didUChangeDependancies` and manually handle this "sync". **This is error prone, cumbersome to experienced devs, and confusing to new ones. Basically no one wants to do this.**

`StatefulProps` handles this in an elegant way: using a simple `builder(BuildContext, MyWidget)` to create the Prop. With this one closure `StatefulProps` can keep all Props in-sync with the enclosing Widget and Context:
```
void initProps(){
    _anim = syncProp((c, w) => AnimationControllerProp(
        w.duration, 
        vsync: c.read<TickerProvider>()));
}
```

The only difference in this code is the `addProp(...)` has become `syncProp((c, w) => ... )`, and we use the `c` and `w` params to fetch any required dependencies. The rest is managed automatically! 

Traditionally you would need to:
* override `dispose()` remember to dispose the controller
* override `didUpdateDependencies()` and inject the the provided value (if it's changed)
* override `didChangeWidget()` and inject the new `widget.duration` value (if it's changed)

This is a savings of dozens of lines of code, and prevents several sneaky bugs. 

**This is pretty nice! But there is still a bit of an issue: `StatelessWidget` itself**. Declaring 2 classes everytime we need State has a negative impact on readability, makes refactoring more tedious, increases line count and adds boilerplate. On larger Widgets this is usually not an issue (it's 5 lines!), but it can still get annoying on smaller Widgets that only need a couple pieces of state.

This is where `PropsWidget` comes in!

## 🕹️  PropsWidget

`PropsWidget` takes a very similar approach, it also has `initProps` and `buildwithProps`, but there are a couple key differences:
* Use `PropsWidget` rather than `State with StatefulPropsMixin`
* `addProp` or `syncProp` methods gain 1 required parameter a `ref`
* Prop declarations change from `IntProp prop1` to `static Ref<IntProp> _prop1 = Ref()`
* To get a Prop, you call `use(_ref)`

Other than those changes most everything else is identical. 

This may seem like a lot, but when viewed side by side, you can see it's not so bad:
![](http://screens.gskinner.com/shawn/Photoshop_2020-12-28_22-44-10.png)

**To recreate the Animated Widget above, in a Stateless way, you can write:**
```
class BasicAnimatorStateless extends PropsWidget<BasicAnimatorStateless> {
  BasicAnimatorStateless(this.duration);
  final Duration duration;

  static final Ref<AnimationProp> _anim1 = Ref();
  AnimationProp get anim1 => use(_anim1);

  @override
  void initProps() {
    syncProp(_anim1, (c, w) => AnimationProp(w.duration, vsync: c.read<TickerProvider>()));
  }
  
  @override
  Widget buildWithProps(BuildContext context) => Opacity(opacity: anim1.value, child: ...);
}
```

**That is the _entire_ component!** No additional 5 lines, or extra class decleration like you have with a StatefulWidget.

There is some tradeoff here between the increased boilerplate of `use(...)` and `Ref()` vs. the reduced line count and readability win of a single Class, but you can decide which you like best and where. Typically the `PropsWidget` works great up to 2 or 3 Props, and after that a `StatefulPropsMixin` feels a little nicer to work with as the boilerplate adds up.


#### What about dispose()?
Using `dispose()` is extremely rare with `StatefulProps` since Props typically clean up and dispose their own internal objects. However both the `StatefulPropsMixin` and the `PropsWidget` support a `dispose()` override should you need it.



## 👀 Code Examples

Below are a large number of different code examples, showing what can be done out of the box. 

In all cases assume these code examples are inside of a `State` + `StatefulPropsMixin`:

* Show a FutureBuilder 
* KeyboardListener + MouseRegion
* Gesture + Tap Listener
* FocusProp
* TextController
* MouseRegion
* LayoutBuilder
* Primitive
* GestureProp
* MultipleAnimations


### 📝 Contributing
 We are actively seeking support setting up some integrated testing and are welcoming all contributions and Pull Requests from the community. We would like StatefulProps to become defacto flutter code, and that can only be done if the community embraces it!
 
 This package focuses on providing useful, pragmatic Props to get things done. The only requirement for adding a Prop to the core should be that many people want it to exist. We are happy to be guided by a simple system of votes and popularity for adding Props to the core.


## 🐞 Bugs/Requests

If you encounter any problems please open an issue. If you feel the library is missing a feature, please raise a ticket on Github and we'll look into it. Pull request are welcome.

## Creating your own Props
It's very easy to create your own Props. Just extend `StateProperty`, and override any of the optional methods. There are various flavors of Props you can look at for reference:
* Controller style props like AniMProp [ADD LINK] and FocusProp [ADD LINK]
* Pure callback props like `GestureProp` and `KeyboardProp`
* Combinations of callbacks and state, like the `MouseRegionProp` (ADD LINK)
* Builders that change context like `LayoutProp` and `FutureProp` 
* Pure state encapsulation like `IntProp` (ADD LINK), `BoolProp` (ADD LINK) and `ValueProp` (ADD LINK)

The available methods that your custom Prop can override are:
* `init()`
* `update(Prop latest)`
* `dispose()`
* `restoreState(registerFn)`
* `getBuilder(Widget Function(BuildContext) childBuilder)`

You can override all or none of these. Many props override `init`, `update` and `dispose`, but some override none at all. This is perfectly valid for Props that do not need any lifecycle hooks and just encapsulate some state + some logic. Going forward it may become best practice for all Props to implement `restoreState` whenever they can, but there will always be things like `MouseRegionProp` where restoration just doesn't make sense.


#### A note on composition and inheritence (and interfaces and mixins...)
Because `StatefulProps` are classes, and not functions, they benefit from all of the code re-use strategies available in Dart. Inheritence, composition, inrerfaces and mixins and are all available as tools in the toolbox when constructing your own `StatefulProps`.

There's a lot of advanced things you can do with this, but even the most primitive examples are quite useful. For example, if you look at the existing `IntProp` class, you can see that it simply extends a more basic `ValueProp<T>`:
```
class IntProp extends ValueProp<int> {
  IntProp([int defaultValue = 0]) : super(defaultValue);
}
...
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
Another example of inheritence in action, is our shortcut handler for Taps. Since these are so common, we created a dedicated mixin just for taps:
```
class TapProp extends GestureProp {
  TapProp(VoidCallback onTap) : super(onTap: onTap);

  @override
  ChildBuilder getBuilder(ChildBuilder childBuilder) {
    return super.getBuilder(childBuilder);
  }
}
```
For an example of composition, you can look at the `FutureProp` (ADD LINK), which internally uses a ValueProp to track it's future:
```
  @override
  void init() {
    // Use a ValueProp to handle our 'did-change' check
    futureValue = addProp?.call(ValueProp(initialFuture));
  }
```
Any Prop can add/sync any other Prop, as long as they do it in `init()`.


## 📃 License

MIT License
