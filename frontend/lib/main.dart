import 'package:flutter/material.dart';
import 'package:frontend/pages/todo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do',
      theme: ThemeData(fontFamily: 'Roboto', primaryColor: Color(0xFFA44A3F)),
      home: const TodoPage(),
    );
  }
}
