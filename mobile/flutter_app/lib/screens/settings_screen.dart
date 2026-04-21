import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/notification_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentMode = themeProvider.themeMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: const Color(0xFF6366F1),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Tema',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: ThemeMode.values.map((mode) {
                final label = mode == ThemeMode.system
                    ? 'Sistem Ayarına Uygun'
                    : mode == ThemeMode.light
                        ? 'Aydınlık'
                        : 'Karanlık';
                return RadioListTile<ThemeMode>(
                  title: Text(label),
                  value: mode,
                  groupValue: currentMode,
                  onChanged: (value) {
                    if (value != null) {
                      themeProvider.setThemeMode(value);
                    }
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Uygulama',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) {
              return SwitchListTile(
                value: notificationProvider.backgroundDeliveryEnabled,
                onChanged: (value) {
                  notificationProvider.setBackgroundDeliveryEnabled(value);
                },
                title: const Text('Arka Planda Bildirim Gönder'),
                subtitle: const Text(
                    'Etkinlik hatırlatmaları gibi bildirimler için arka plan desteği.'),
              );
            },
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Sürüm'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}
