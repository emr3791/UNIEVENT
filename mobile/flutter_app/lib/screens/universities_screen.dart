import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/university_provider.dart';
import '../widgets/university_card.dart';
import '../widgets/app_drawer.dart';

class UniversitiesScreen extends StatefulWidget {
  const UniversitiesScreen({Key? key}) : super(key: key);

  @override
  State<UniversitiesScreen> createState() => _UniversitiesScreenState();
}

class _UniversitiesScreenState extends State<UniversitiesScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Üniversiteler'),
        centerTitle: true,
        backgroundColor: const Color(0xFF6366F1),
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Search and Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF6366F1).withAlpha(13),
            child: Column(
              children: [
                // Search Box
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Üniversite adı ara...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF6366F1)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 12),
                // Add University Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddUniversityDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Üniversite Ekle',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Universities List
          Expanded(
            child: Consumer<UniversityProvider>(
              builder: (context, universityProvider, _) {
                var universities = universityProvider.universities;

                // Filter by search
                if (_searchController.text.isNotEmpty) {
                  universities = universities
                      .where(
                        (uni) =>
                            uni.name.toLowerCase().contains(
                                  _searchController.text.toLowerCase(),
                                ) ||
                            uni.city.toLowerCase().contains(
                                  _searchController.text.toLowerCase(),
                                ),
                      )
                      .toList();
                }

                if (universities.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Hiç üniversite yok'
                              : 'Üniversite bulunamadı',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: universities.length,
                  itemBuilder: (context, index) {
                    final university = universities[index];
                    return UniversityCard(
                      university: university,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/university_detail',
                          arguments: university,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddUniversityDialog(BuildContext context) {
    final nameController = TextEditingController();
    final cityController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Üniversite Ekle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Üniversite Adı',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityController,
                decoration: InputDecoration(
                  hintText: 'Şehir',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: 'Açıklama',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  cityController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lütfen tüm alanları doldurun'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final universityProvider = Provider.of<UniversityProvider>(
                context,
                listen: false,
              );

              await universityProvider.addUniversity(
                name: nameController.text,
                city: cityController.text,
                description: descriptionController.text,
              );

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Üniversite başarıyla eklendi'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text(
              'Ekle',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
