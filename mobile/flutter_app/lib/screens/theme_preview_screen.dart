import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ThemePreviewScreen extends StatelessWidget {
  const ThemePreviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.goldTheme,
      child: Scaffold(
        appBar: AppBar(title: const Text('Altın Tema Önizlemesi')),
        body: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Theme.of(context).colorScheme.surface,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Başlık',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Bu ekran siyah → altın tema önizlemesidir.'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Simple TabBar demo
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  Container(
                    color: Colors.black,
                    child: const TabBar(tabs: [
                      Tab(text: 'Bir'),
                      Tab(text: 'İki'),
                      Tab(text: 'Üç')
                    ]),
                  ),
                  SizedBox(
                    height: 120,
                    child: TabBarView(children: [
                      Center(
                          child: Text('İçerik 1',
                              style: Theme.of(context).textTheme.bodyLarge)),
                      Center(
                          child: Text('İçerik 2',
                              style: Theme.of(context).textTheme.bodyLarge)),
                      Center(
                          child: Text('İçerik 3',
                              style: Theme.of(context).textTheme.bodyLarge)),
                    ]),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
