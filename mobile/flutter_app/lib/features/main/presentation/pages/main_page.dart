import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../widgets/onboarding_overlay.dart';
import 'package:line_icons/line_icons.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../screens/home_screen.dart';
import '../../../../screens/search_screen.dart';
import '../../../../screens/messaging_screen.dart';
import '../../../../widgets/app_drawer.dart';
import '../../../explore/presentation/pages/explore_page.dart';
import '../../../wallet/presentation/pages/wallet_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  final List<Widget> _pages = [
    const SafeArea(child: HomeContent()),
    const SafeArea(child: SearchScreen()),
    const MessagingScreen(),
    const ExplorePage(),
    const WalletPage(),
    const ProfilePage(),
  ];

  final List<Map<String, dynamic>> _navItems = [
    {'icon': LineIcons.home, 'label': 'Anasayfa'},
    {'icon': LineIcons.search, 'label': 'Arama'},
    {'icon': LineIcons.comment, 'label': 'Mesajlar'},
    {'icon': LineIcons.compass, 'label': 'Keşfet'},
    {'icon': LineIcons.wallet, 'label': 'Cüzdan'},
    {'icon': LineIcons.user, 'label': 'Profil'},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    // Show onboarding overlay on first run
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final seen = prefs.getBool('seen_onboarding') ?? false;
      if (!seen) {
        await showDialog(
            context: context, builder: (ctx) => const OnboardingOverlay());
        await prefs.setBool('seen_onboarding', true);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    HapticUtils.selectionClick();
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: _pages,
          ),
          Positioned(
            left: 0,
            top: MediaQuery.of(context).size.height / 2 - 30,
            child: Builder(
              builder: (ctx) => GestureDetector(
                onTap: () {
                  HapticUtils.lightImpact();
                  Scaffold.of(ctx).openDrawer();
                },
                child: Container(
                  width: 24,
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withAlpha(102),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 5,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 14),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        height: 82,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor.withAlpha(242),
          border: Border(top: BorderSide(color: theme.dividerColor)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 58,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _navItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = index == _selectedIndex;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _onTap(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.primaryColor.withAlpha(38)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item['icon'] as IconData,
                                size: 20,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface
                                        .withAlpha(178),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['label'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface
                                          .withAlpha(191),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment(-1.0 + (_selectedIndex / 2.5), 0),
              child: Container(
                width: 48,
                height: 3,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
