import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../data/models/event_model.dart';
import 'event_card.dart';
import '../../../../core/utils/haptic_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';

// This file has been optimised

class CampusMapView extends StatefulWidget {
  const CampusMapView({super.key});

  @override
  State<CampusMapView> createState() => _CampusMapViewState();
}

class _CampusMapViewState extends State<CampusMapView> {
  GoogleMapController? _mapController;
  bool _mapError = false;
  String _mapStyle = '';
  final Set<Marker> _markers = {};
  final Set<Circle> _heatmapCircles = {};
  EventModel? _selectedEvent;
  EventModel? _cachedEvent; // For smooth dismissal animation

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(41.0152, 28.9780), // Center of campus mock
    zoom: 14.5,
  );

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buildMarkersAndHeatmap();
    });
  }

  Future<void> _loadMapStyle() async {
    final style = await rootBundle.loadString('assets/map_style/dark_neon_style.json');
    if (mounted) {
      setState(() {
        _mapStyle = style;
      });
    }
  }

  void _buildMarkersAndHeatmap() {
    _markers.clear();
    _heatmapCircles.clear();
    for (var event in mockEvents) {
      // Create Pin Marker
      _markers.add(
        Marker(
          markerId: MarkerId(event.id),
          position: LatLng(event.latitude, event.longitude),
          onTap: () {
            HapticUtils.mediumImpact();
            // Use a SnackBar-style approach to avoid SurfaceView composition crash
            if (mounted) {
              setState(() {
                _selectedEvent = event;
                _cachedEvent = event;
              });
            }
          },
        ),
      );

      // Create Mock Heatmap Node
      _heatmapCircles.add(Circle(
        circleId: CircleId('heat_${event.id}'),
        center: LatLng(event.latitude, event.longitude),
        radius: event.isPublic ? 800 : 400, // Vary radius based on event mock
        fillColor: Colors.deepOrangeAccent.withAlpha(76),
        strokeColor: Colors.orangeAccent.withAlpha(25),
        strokeWidth: 40,
      ));

      // Add inner hotter core
      _heatmapCircles.add(Circle(
        circleId: CircleId('core_${event.id}'),
        center: LatLng(event.latitude, event.longitude),
        radius: event.isPublic ? 300 : 150,
        fillColor: Colors.redAccent.withAlpha(128),
        strokeWidth: 0,
      ));
    }
  }

  Widget _buildCustomBottomSheet() {
    final event = _selectedEvent ?? _cachedEvent;
    if (event == null) return const SizedBox(height: 500);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withAlpha(250),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border(
          top: BorderSide(
            color: theme.primaryColor.withAlpha(76),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(128),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedEvent = null;
              });
            },
            child: Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(128),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(
            height: 400, // Fixed height for ticket inside sheet
            child: EventCard(event: event),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _mapError
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      'Harita yüklenemiyor. Google Maps izinlerini veya bağlantınızı kontrol edin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _mapError = false;
                        });
                      },
                      child: const Text('Tekrar dene'),
                    )
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                RepaintBoundary(
                  child: Builder(builder: (context) {
                    try {
                      return GoogleMap(
                        initialCameraPosition: _initialPosition,
                        markers: _markers,
                        circles: _heatmapCircles,
                        style: _mapStyle.isNotEmpty ? _mapStyle : null,  // ← add this
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        compassEnabled: false,
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;  // ← removed setMapStyle from here
                        },
                        onTap: (_) {
                          if (_selectedEvent != null) {
                            setState(() => _selectedEvent = null);
                          }
                        },
                      );
                    } catch (error, stackTrace) {
                      setState(() {
                        _mapError = true;
                      });
                      debugPrint('Map render error: $error\n$stackTrace');
                      return const SizedBox.shrink();
                    }
                  }),
                ),

                // Stories Overlay at the top
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: _buildStoriesList(),
                ),

                // Invisible dismiss layer when open
                if (_selectedEvent != null)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedEvent = null),
                      child: Container(color: Colors.transparent),
                    ),
                  ),

                // Animated Bottom Sheet Panel
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.fastOutSlowIn,
                  bottom: _selectedEvent != null ? 0 : -MediaQuery.of(context).size.height,
                  left: 0,
                  right: 0,
                  child: _buildCustomBottomSheet(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticUtils.lightImpact();
          _mapController
              ?.animateCamera(CameraUpdate.newCameraPosition(_initialPosition));
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  Widget _buildStoriesList() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: mockEvents.length + 1, // 1 for Add New Story
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAddStoryAvatar();
          }
          final event = mockEvents[index - 1];
          return _buildStoryAvatar(event.imageUrl, event.title);
        },
      ),
    );
  }

  Widget _buildAddStoryAvatar() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: theme.colorScheme.surface,
                backgroundImage: const CachedNetworkImageProvider(
                    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200&auto=format&fit=crop'),
              ),
              CircleAvatar(
                radius: 12,
                backgroundColor: theme.primaryColor,
                child: const Icon(Icons.add, size: 16, color: Colors.white),
              )
            ],
          ),
          const SizedBox(height: 6),
          const Text('Sen',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStoryAvatar(String imageUrl, String label) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor,
                  Colors.orangeAccent,
                  Colors.pinkAccent
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.scaffoldBackgroundColor,
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: CachedNetworkImageProvider(imageUrl),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
