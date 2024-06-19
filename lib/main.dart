import 'package:flutter/material.dart';
import 'package:xoxo/screen/game_screen.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
        title: 'XO',
        home: GameScreen(),
        debugShowCheckedModeBanner: true,
      );
  }
}