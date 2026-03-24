import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../models/event.dart';
import '../widgets/event_card.dart';
import '../utils/animation_utils.dart';
import 'event_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'all';
  bool _showFilters = false;
  bool _onlyFree = false;
  RangeValues _priceRange = const RangeValues(0, 1000);
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    List<Event> allEvents = eventProvider.events;

    List<Event> filteredEvents = allEvents.where((event) {
      bool matchesQuery = event.title
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          event.description.toLowerCase().contains(_searchQuery.toLowerCase());

      String normalizedCategory = _normaliseCategory(event.category);
      bool matchesCategory =
          _selectedCategory == 'all' || normalizedCategory == _selectedCategory;

      bool matchesPrice;
      if (_onlyFree) {
        matchesPrice = event.price == null || event.price == 0;
      } else {
        matchesPrice = (event.price == null) ||
            (event.price! >= _priceRange.start &&
                event.price! <= _priceRange.end);
      }

      bool matchesDate = (_startDate == null && _endDate == null) ||
          (event.date.isAfter(_startDate ?? DateTime(2020)) &&
              event.date.isBefore(
                  _endDate?.add(const Duration(days: 1)) ?? DateTime(2099)));
      return matchesQuery && matchesCategory && matchesPrice && matchesDate;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Etkinlik ara...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: _showFilters
                      ? const Color(0xFF6366F1)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.tune,
                    color: _showFilters ? Colors.white : Colors.grey.shade700,
                  ),
                  onPressed: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _showFilters
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Kategori',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        {'id': 'all', 'label': 'Tüm'},
                        {'id': 'news', 'label': 'Haberler'},
                        {'id': 'concerts', 'label': 'Konserler'},
                        {'id': 'seminars', 'label': 'Seminerler'}
                      ].map((cat) {
                        final isSelected = _selectedCategory == cat['id'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(cat['label']!),
                            selected: isSelected,
                            selectedColor: const Color(0xFF6366F1),
                            backgroundColor: Colors.grey.shade100,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF6366F1)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            onSelected: (bool selected) {
                              setState(() {
                                _selectedCategory =
                                    selected ? cat['id']! : 'all';
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.money_off, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Sadece Ücretsiz Etkinlikler',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Switch(
                        value: _onlyFree,
                        activeThumbColor: const Color(0xFF6366F1),
                        onChanged: (value) {
                          setState(() {
                            _onlyFree = value;
                          });
                        },
                      ),
                    ],
                  ),
                  if (!_onlyFree) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Fiyat Aralığı',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        Text(
                          '₺${_priceRange.start.toInt()} - ₺${_priceRange.end.toInt()}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6366F1)),
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 1000,
                      divisions: 20,
                      activeColor: const Color(0xFF6366F1),
                      inactiveColor: const Color(0xFF6366F1).withOpacity(0.2),
                      labels: RangeLabels('₺${_priceRange.start.toInt()}',
                          '₺${_priceRange.end.toInt()}'),
                      onChanged: (values) {
                        setState(() => _priceRange = values);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        // Date Range Filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2099),
                    );
                    if (date != null) setState(() => _startDate = date);
                  },
                  icon: const Icon(Icons.date_range,
                      size: 16, color: Colors.white),
                  label: Text(
                    _startDate == null
                        ? 'Başlangıç'
                        : '${_startDate!.day}/${_startDate!.month}',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate ??
                          DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2099),
                    );
                    if (date != null) setState(() => _endDate = date);
                  },
                  icon: const Icon(Icons.date_range,
                      size: 16, color: Colors.white),
                  label: Text(
                    _endDate == null
                        ? 'Bitiş'
                        : '${_endDate!.day}/${_endDate!.month}',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              if (_startDate != null || _endDate != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() {
                      _startDate = null;
                      _endDate = null;
                    }),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filteredEvents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Etkinlik bulunamadı',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredEvents.length,
                  itemBuilder: (context, index) {
                    final event = filteredEvents[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: EventCard(
                        event: event,
                        participantCount:
                            eventProvider.getParticipantCount(event.id),
                        onTap: () {
                          Navigator.of(context).push(
                            AnimationUtils.slideLeftTransition(
                              EventDetailScreen(event: event),
                            ),
                          );
                        },
                        onBuyTap: () {
                          Navigator.pushNamed(
                            context,
                            '/payment',
                            arguments: event,
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _normaliseCategory(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('konser')) return 'concerts';
    if (lower.contains('semin')) return 'seminars';
    if (lower.contains('haber')) return 'news';
    if (lower.contains('etkinlik')) return 'events';
    return lower;
  }
}
