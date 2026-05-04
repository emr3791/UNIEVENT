import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor.withAlpha(51),
                Colors.transparent
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
              child: Text('Ana Sayfa - Etkinlik Akışı',
                  style: TextStyle(fontSize: 20))),
        ),
      );
    } catch (e, st) {
      debugPrint('HomePage build error: $e\n$st');
      return const Center(child: Text('Anasayfa yüklenemiyor'));
    }
  }
}
