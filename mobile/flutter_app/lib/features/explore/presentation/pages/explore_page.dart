import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/discover_swipe_view.dart';
// Maps/AR removed per revision: keep Discover view only
import '../../../../core/utils/haptic_utils.dart';
import '../../../sdui/presentation/pages/dynamic_club_page.dart';
// AR removed

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticUtils.selectionClick();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          title: TabBar(
            controller: _tabController,
            indicatorColor: theme.primaryColor,
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.grey,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(icon: Icon(Icons.style), text: 'Keşfet'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.dynamic_feed),
              tooltip: 'Tech Club (SDUI Demo)',
              color: theme.primaryColor,
              onPressed: () {
                HapticUtils.mediumImpact();
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DynamicClubPage()));
              },
            ),
            IconButton(
              icon: const Icon(Icons.email_outlined),
              tooltip: 'Abone Ol',
              color: theme.primaryColor,
              onPressed: () => _showSubscriptionDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: 'Tanıtım',
              color: theme.primaryColor,
              onPressed: () => _showOnboardingPreview(context),
            ),
          ]),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          SafeArea(child: DiscoverSwipeView()),
        ],
      ),
    );
  }

  void _showOnboardingPreview(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Kısa Tanıtım'),
            content: const SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Icon(Icons.explore),
                    title: Text('Keşfet'),
                    subtitle: Text('Etkinlikleri kaydırarak keşfedin.'),
                  ),
                  ListTile(
                    leading: Icon(Icons.account_balance_wallet),
                    title: Text('Cüzdan'),
                    subtitle: Text('UNV bakiyenizi inceleyin ve satın alın.'),
                  ),
                  ListTile(
                    leading: Icon(Icons.message),
                    title: Text('Sohbetler'),
                    subtitle: Text('Etkinlik sohbetlerine katılın.'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kapat')),
            ],
          );
        });
  }

  Future<void> _showSubscriptionDialog(BuildContext context) async {
    final controller = TextEditingController();
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('explore_subscribe_email');
    if (saved != null) controller.text = saved;

    if (!context.mounted) return;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('E-posta ile Abone Ol'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'email@ornek.com'),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal')),
              TextButton(
                  onPressed: () async {
                    final email = controller.text.trim();
                    if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}")
                        .hasMatch(email)) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Geçerli bir e-posta girin')));
                      return;
                    }
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    // Save locally as fallback
                    await prefs.setString('explore_subscribe_email', email);
                    // Attempt backend hook
                    try {
                      final resp = await http.post(
                          Uri.parse('https://example.com/api/subscribe'),
                          body: {'email': email});
                      if (!context.mounted) return;
                      if (resp.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Teşekkürler! Aboneliğiniz alındı')));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Abonelik kaydedildi (çevrimdışı)')));
                      }
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Abonelik kaydedildi (çevrimdışı)')));
                    }
                  },
                  child: const Text('Abone Ol'))
            ],
          );
        });
  }
}
