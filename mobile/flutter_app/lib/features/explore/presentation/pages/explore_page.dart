import 'package:flutter/material.dart';
import '../widgets/discover_swipe_view.dart';
import '../widgets/campus_map_view.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../sdui/presentation/pages/dynamic_club_page.dart';
import 'ar_radar_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
            Tab(icon: Icon(Icons.map_outlined), text: 'Harita'),
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
                MaterialPageRoute(builder: (_) => const DynamicClubPage())
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.view_in_ar),
            tooltip: 'AR Radarı',
            color: theme.colorScheme.secondary,
            onPressed: () {
              HapticUtils.selectionClick();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ArRadarPage())
              );
            },
          ),
        ]
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe between tabs for GoogleMap
        children: const [
          SafeArea(child: DiscoverSwipeView()),
          CampusMapView(),
        ],
      ),
    );
  }
}

