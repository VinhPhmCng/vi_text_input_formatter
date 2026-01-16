import 'package:flutter/material.dart';
import 'package:vi_text_input_formatter/vi_text_input_formatter.dart';

void main() {
  runApp(const MyApp());
}

/// Example app for package 'vi_text_input_formatter'
class MyApp extends StatelessWidget {
  ///
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example App',
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                inputFormatters: [ViTextInputFormatter()],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
