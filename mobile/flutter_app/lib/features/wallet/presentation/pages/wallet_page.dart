import 'package:flutter/material.dart';
import '../widgets/credit_card_wallet.dart';
import '../widgets/crypto_sparkline.dart';
import '../widgets/hologram_ticket.dart';
import '../../../explore/data/models/event_model.dart'; // Using mock models

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock stock data for popularity metric
    final prices1 = [12.0, 15.0, 14.5, 18.0, 25.0, 22.0, 30.0];
    final prices2 = [8.0, 7.5, 9.0, 6.0, 5.0];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cüzdan',
                style: theme.textTheme.displayLarge?.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 24),
              const CreditCardWallet(userId: 'ID-8429-TECH', balance: 1450.50),
              
              const SizedBox(height: 32),
              Text(
                'Biletlerim (Hologram)',
                style: theme.textTheme.displayLarge?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),
              
              // Hologram Ticket Display Map
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    final event = mockEvents[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: HologramTicket(
                        child: Container(
                          width: 300,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: NetworkImage(event.imageUrl),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.5),
                                BlendMode.darken,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Icon(Icons.qr_code_scanner, color: Colors.white, size: 30),
                              const Spacer(),
                              Text(
                                event.title,
                                style: const TextStyle(
                                  color: Colors.white, 
                                  fontSize: 20, 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              Text(
                                event.locationName,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 32),
              Text(
                'Borsada Etkinlikler (Popülerlik)',
                style: theme.textTheme.displayLarge?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),

              // Sparklines UI
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    _buildStockRow('Neon Kampüs Partisi', 'Çok Yüksek Talep', prices1, true),
                    const Divider(color: Colors.grey, height: 32),
                    _buildStockRow('Açık Hava Sineması', 'Düşük İvme', prices2, false),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Bottom nav bar padding spacer
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockRow(String title, String subtitle, List<double> prices, bool isPositive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1, 
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: isPositive ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 12,
                ),
              )
            ],
          ),
        ),
        CryptoSparkline(prices: prices, isPositive: isPositive),
      ],
    );
  }
}
