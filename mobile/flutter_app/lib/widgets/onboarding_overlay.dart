import 'package:flutter/material.dart';

class OnboardingOverlay extends StatelessWidget {
  final VoidCallback? onClose;
  const OnboardingOverlay({Key? key, this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Uygulama Tanıtımı',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          _bubbleRow(
              Icons.explore, 'Keşfet', 'Etkinlikleri kaydırarak keşfedin.'),
          const SizedBox(height: 8),
          _bubbleRow(Icons.account_balance_wallet, 'Cüzdan',
              'UNV bakiyenizi görüntüleyin ve kullanın.'),
          const SizedBox(height: 8),
          _bubbleRow(Icons.message, 'Sohbetler',
              'Etkinlik sohbetleri otomatik oluşturulur.'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (onClose != null) onClose!();
            },
            child: const Text('Anladım'),
          )
        ]),
      ),
    );
  }

  Widget _bubbleRow(IconData icon, String title, String subtitle) {
    return Row(children: [
      CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(icon, color: Colors.blue)),
      const SizedBox(width: 12),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: const TextStyle(fontSize: 13, color: Colors.black54))
      ]))
    ]);
  }
}
