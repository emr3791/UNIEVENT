// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/notification_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider?>(context, listen: true);
    final notificationProvider =
        Provider.of<NotificationProvider?>(context, listen: true);
    final currentMode = themeProvider?.themeMode ?? ThemeMode.system;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Tema',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  onChanged: themeProvider != null
                      ? (value) {
                          if (value != null) themeProvider.setThemeMode(value);
                        }
                      : null,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Uygulama',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SwitchListTile(
            value: notificationProvider?.backgroundDeliveryEnabled ?? true,
            onChanged: notificationProvider != null
                ? (value) =>
                    notificationProvider.setBackgroundDeliveryEnabled(value)
                : null,
            title: const Text('Arka Planda Bildirim Gönder'),
            subtitle: Text(
              notificationProvider != null
                  ? 'Etkinlik hatırlatmaları gibi bildirimler için arka plan desteği.'
                  : 'Bildirim ayarları geçici olarak kullanılamıyor.',
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Sürüm'),
            subtitle: Text('1.0.0'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
