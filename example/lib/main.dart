import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  //Enable this to measure your repaint regions
  //debugRepaintRainbowEnabled = true;
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: Scaffold(body: MyApp())));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(color: Colors.red);
}
