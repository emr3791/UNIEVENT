import 'package:flutter/material.dart';

void main() {
  runApp(const UniEventApp());
}

class UniEventApp extends StatelessWidget {
  const UniEventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniEventAI',
      home: Scaffold(
        appBar: AppBar(title: const Text('UniEventAI')),
        body: const Center(child: Text('Hoşgeldiniz — UniEventAI')),
      ),
    );
  }
}
