NOTE: This plugin is under construction and this page is just a placeholder. 

# stateful_props - 

#### Provides a simple and familiar way to re-use state and behavior across your flutter components.

This package was heavily inspired by hooks (and prior art like DisplayScript), but it utilizes a more classic OOP approach that fits well with Flutter and Dart.

### The goals of this package are: 
* improve readability and reduce boilerplate
* prevent common bugs around init/dispose/didUpdateWidget/didChangeDependencies  
* provide opinionated defaults and helper methods for common use cases
* be easy and familiar for existing Flutter devs (no foreign concepts or 'magic')

To put that in concrete terms, this library will stop bugs by doing things like:
* ensure `dispose()` is called on all [`Animation`, `TextEditing`, `Scroll`]`Controller`'s  
* add common primitive defaults like `IntProp(0)`, `DoubleProp(0)` and `BoolProp(false)`. 
* remove repetitive `setState` calls inside your components, just change values and the views rebuild
* automatically handle Restorable state implementation details

It will reduce boilerplate and increase readability by:
* reduce all `GestureDetector`, `MouseRegion`, `KeyboardListener` etc builders to 1 or 2 lines of non-nested code
* eliminate the need for nested builders like `TweenAnimationBuilder`, `StreamBuilder`, `FutureBuilder` etc which are hard to read  
* add quality of life helpers like `animProp.isGoingForward/isGoingBack/isPlaying`, `mouseProp.isHovered`, `mouseProp.normalizedOffset`, `scrollProp.onChanged(prop.position)` etc
* prefer a `double` over `Duration` for animation related methods as is common practice

In additional to all of the above, it is an extremely flexible and composable system that you can use to share any of your own behavior within your application. 

## How does it work? 
This package suports both Stateful and "Stateless" implementations, `StatefulPropsMixin` and `StatefulPropsWidget` respectively. The `StatefulPropsWidget` can handle most components, and is _very_ compact, but we'll start with the `StatefulPropsMixin` first as it will be the most familiar.

### StatefulPropsMixin
The basic idea with the Mixin is something like this:
```
  AnimationControllerProp anim; //Props are instance vars that wrap some internal state
  ... 
  // Props are added/registered in initProps()
  void initProps(){
    anim = addProp(AnimationControllerProp(Duration(seconds: 1))); 
  } 
  ...  
   // Use the Prop in buildWithProps()
  Widget buildWithProps(BuildContext context){
    double value = anim.value;
    return MyWidget(color: Colors.black.withOpacity(value), child: ..., );
  }
}
```

There are a few required steps to start with:
* Add the `StatefulPropsMixin` to your state
* override `initProps()` to initialize your props
* override `buildWithProps` instead of `build()`
* declare and initialize your Props 

Here's a basic CounterApp implementation:
```
(+4 ^  lines for StatefulWidget) 
class _MyViewState extends State<MyView> with StatefulPropsMixin {
    IntProp _counter;
    
    @override // You can still use initState if you want, but this  is less error prone, and no need to call super()
    void initProps(){
        _counter = addProp(IntProp(0));
    } 
    
    void _handleBtnPressed() => _counter.value++; //setState is handled by Prop
    
    @override 
    Widget buildWithProps(BuildContext context) => FlatButton(child: Text("${_counter.value}"), onPressed: _handleBtnPressed);
}
```

That's all you need for basic `StatefulPropsMixin` support! **The magic is really happening in the `addProp()` method**, which registers the Prop with the Mixin. For more advanced use cases, there is `syncProp(BuildContext, Widget)` which we'll come back to in a bit.

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
Notice how we don't have to dispose the `AnimationController` here, it is handled automatically by the Prop.

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
Notice how we don't even declare an instance property for the `GestureDetectorProp`. Since it is just providing callbacks, and has no internal state we care about, we don't need to keep a reference at all. We can just call `addProp` once to register it, and `StatefulProps` will take it from there.

The final use case to discuss for the Stateful implementation is the `syncProp`. You use this if your Prop has some dependancy on context (using Provider or InheritedWidget) or on the properties of the enclosing Widget. This is a cause of many hard to spot errors in Flutter apps and reduces the effectiveness of hot-reload.

Consider a `State` like this:
```
class _MyViewState extends State<MyView> {
    void initState(){
        super.initState();
        animController = AnimationController(
          widget.duration, 
          vsync: context.read<TickerProvider>());
    }
}
```
**In the above code there are actually 2 potential bugs.** If either the provided `Duration` or the `widget.vsync` values change, the `AnimationController` would not be updated properly. To fix this, devs need to override `didUpdateWidget` or `didUChangeDependancies` and manually handle this "sync". This is error prone, cumbersome to experienced devs, and confusing to new ones. Basically no one wants to do this.

`StatefulProps` handles this in an elegant way: using a simple `builder()` that passes the latest `BuildContext` and `Widget`. With this one closure `StatefulProps` can keep all Props in-sync internally:
```
class MyView extends StatefulWidget {
  MyView(this.duration);
  final double duration;
  @override
  _MyViewState createState() => _MyViewState();
}
 
class _MyViewState extends State<MyView> with StatefulPropsMixin {
    AnimationControllerProp _anim;
    @override 
    void initProps(){
        _anim = syncProp((c, w) => AnimationControllerProp(
           w.duration, 
           vsync: c.read<TickerProvider>()));
    } 
    @override 
    Widget buildWithProps(BuildContext context) => Opacity(opacity: _anim.value, child: ...);
}
```

**This is pretty nice! But there is still a bit of an issue: `StatelessWidget` itself**. Declaring 2 classes everytime we need State has a negative impact on readability, makes refactoring more tedious, increases line count and adds boilerplate. In this simple widget 6 of 16 lines are boilerplate related to StatefulWidget. We can do better!

This is where `StatefulPropsWidget` comes in.

### StatefulPropsWidget

`StatefulPropsWidget` takes a very similar approach, it also has `initProps` and `buildwithProps`, but there are a couple key differences:
* use `StatefulPropsWidget` rather than `State with StatefulPropsMixin`
* builders are defined as `final` methods 
* there is no `addProp` or `syncProp` methods
* instead there is just `useProp` which has a similar function signature to `syncProp`

Other than those changes, virtually everything else is identical.

**To recreate the Animated Widget above, in a Stateless way, you can write:**
```
class MyView extends StatefulPropsWidget {
    MyView(this.duration);
    final double duration;
    
    final Prop<AnimationControllerProp> _anim1 = (_, __) => AnimationControllerProp(0.5);
    final Prop<AnimationControllerProp> _anim2 = (c, w) => AnimationControllerProp(
           (w as MyView).duration, 
           vsync: c.read<TickerProvider>());
    
    @override 
    Widget buildWithProps(BuildContext context) => Opacity(opacity: useProp(_anim1).value, child: ...);
}
```

**That is the _entire_ component.** In this case `useProp()` is taking care of registering the Prop with the Widget. As long as `useProp()` is called at least once, the Prop is registered. Order of operations, and conditional calls do not matter. 

Not only does the above code take care of disposing the Animator and enjoy built-in Restoration API support, it  also will stay in sync with all dependencies automatically. Taken together, this is a savings of 15 - 20 lines, and elimates 3 potential bugs from the picture.

#### What else?
There's a lot of advanced things you can do with this, but even the most primitive examples are quite useful. For example, if you want a simpel `Bool _isLoading` with a classic StatelessWidget you would have to write:
```
class MyView extends StatefulWidget {
  @override
  _MyViewState createState() => _MyViewState();
}

class _MyViewState extends State<MyView> {
  bool _isLoading = false;
  void setIsLoading(bool value){
      if(value == _isLoading) return;
      setState(()=> _isLoading = value);
  }

  @override
  Widget build(BuildContext context) {
    print(_isLoading);
    return FlatButton(onPressed: ()=> setState(() => _isLoading = value), child: ...);
  }
}
```
With StatefulPropsWidget that can be simplified significantly:
```
class MyView extends StatefulPropsWidget {
    final Prop<BoolProp> _isLoading = (_, __) => false;
    @override 
    Widget buildWithProps(BuildContext context) {
      print(useProp(_isLoading).value);
      return FlatButton(onPressed: ()=> useProp(_isLoading).value = true, child: ...);
    }
}
```

#### What about init?
Not to worry, `StatefulPropsWidget` also has an `initProp` method that you can override to run some behavior when the Widget is first mounted, or register properties that do not have any state (like a `GestureDetectorProp`). In this example, we'll use `TapProp` which is a tiny a wrapper (ADD LINK) around `GestureDetectorProp`, and we'll kick-off a delayed animation.
```
class MyView extends StatefulPropsWidget {
    final Prop<AnimationControllerProp> _tap = (_, w) => TapProp((w as MyView).handleTap);
    final Prop<AnimationControllerProp> _anim = (c, w) => AnimationControllerProp(0.5);
           
    void initProps(){
        Future.delayed(Duration(seconds: 1), ()=>useProp(_anim).controller.forward();
        useProp(_tap); // useProp must be called at least once for each prop
    }

    @override 
    Widget buildWithProps(BuildContext context) => return Opacity(opacity: useProp(_anim).value, child: ...);
}
```

## Creating your own Props
It's very easy to create your own Props. Just extend `StateProperty`, and override any of the optional methods. There are various flavors of Props you can look at for reference:
* Controller style props like AnimatorController [ADD LINK] and FocusNode [ADD LINK]
* Pure callback props like `GestureDetectorProp` and `RawKeyboardProp`
* Combinations of callbacks and state, like the `MouseRegionProp` (ADD LINK)
 
### Code Examples

Below are a large number of different code examples, showing what can be done.


Usage
Contributing
This package focuses on providing useful, pragmatic "Props" and does not try and take an opinion on how you should use them.
We are actively seeking community support and Pull Requests to add additional Props. Especially, we could use help getting Integrated Tests setup.


<img src="TODO: ADD_IMG" alt="" />

## 🔨 Installation
```yaml
dependencies:
  stateful_props: ^0.0.1
```

### ⚙ Import

```dart
import 'package:stateful_props/stateful_props.dart';
```

## 🕹️ Usage

TODO: ADD USAGE

## 🐞 Bugs/Requests

If you encounter any problems please open an issue. If you feel the library is missing a feature, please raise a ticket on Github and we'll look into it. Pull request are welcome.

## 📃 License

MIT License
