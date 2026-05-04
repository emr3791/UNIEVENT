import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/avatar_widget.dart';
import '../models/user.dart';

class AvatarEditScreen extends StatefulWidget {
  const AvatarEditScreen({super.key});

  @override
  State<AvatarEditScreen> createState() => _AvatarEditScreenState();
}

class _AvatarEditScreenState extends State<AvatarEditScreen> {
  bool _isEditing = false;
  late String _selectedSkinTone;
  late String _selectedHairStyle;
  late String _selectedFacialHair;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _selectedSkinTone = user?.avatarSkinTone ?? 'medium';
    _selectedHairStyle = user?.avatarHairStyle == 'curly' ||
            user?.avatarHairStyle == 'bald' ||
            user?.avatarHairStyle == 'white'
        ? (user?.avatarHairStyle ?? 'default')
        : 'default';
    _selectedFacialHair = user?.avatarFacialHair ?? 'none';
  }

  void _saveAvatar() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.updateProfile(
      avatarSkinTone: _selectedSkinTone,
      avatarHairStyle: _selectedHairStyle,
      avatarFacialHair: _selectedFacialHair,
    );
    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avatar kaydedildi!')),
    );
  }

  Widget _buildEmojiSelector({
    required String title,
    required List<Map<String, String>> options,
    required String currentValue,
    required Function(String) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options.map((option) {
            final isSelected = currentValue == option['value'];
            return GestureDetector(
              onTap: _isEditing ? () => onSelect(option['value']!) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF6366F1).withAlpha(26)
                      : Colors.grey.shade100,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6366F1)
                        : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(option['emoji']!,
                        style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 4),
                    Text(
                      option['label']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? const Color(0xFF6366F1)
                            : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authUser = Provider.of<AuthProvider>(context).currentUser;
    final user = authUser ??
        User(
          id: 'guest',
          email: '',
          username: '',
          fullName: 'Misafir Kullanıcı',
          userType: 'regular',
          gender: 'male',
        );

    final isFemale = user.gender == 'female';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar Oluştur'),
        backgroundColor: const Color(0xFF6366F1),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveAvatar,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'avatar_preview',
              child: AvatarWidget(
                user: user.copyWith(
                  avatarSkinTone: _selectedSkinTone,
                  avatarHairStyle: _selectedHairStyle,
                  avatarFacialHair: _selectedFacialHair,
                ),
                size: 140,
                showBorder: true,
              ),
            ),
            const SizedBox(height: 24),
            if (!_isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text(
                    'Düzenle',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            if (_isEditing) ...[
              const Divider(height: 48),
              _buildEmojiSelector(
                title: 'Ten Rengi',
                options: [
                  {'value': 'light', 'emoji': '👋🏻', 'label': 'Açık'},
                  {'value': 'medium', 'emoji': '👋🏽', 'label': 'Buğday'},
                  {'value': 'dark', 'emoji': '👋🏿', 'label': 'Esmer'},
                ],
                currentValue: _selectedSkinTone,
                onSelect: (v) => setState(() => _selectedSkinTone = v),
              ),
              const SizedBox(height: 24),
              _buildEmojiSelector(
                title: 'Saç Stili',
                options: [
                  {'value': 'default', 'emoji': '👦', 'label': 'Normal'},
                  {'value': 'curly', 'emoji': '🧑‍🦱', 'label': 'Kıvırcık'},
                  {'value': 'white', 'emoji': '🧑‍🦳', 'label': 'Beyaz/Gri'},
                  {'value': 'bald', 'emoji': '🦲', 'label': 'Kel'},
                ],
                currentValue: _selectedHairStyle,
                onSelect: (v) => setState(() => _selectedHairStyle = v),
              ),
              if (!isFemale) ...[
                const SizedBox(height: 24),
                _buildEmojiSelector(
                  title: 'Sakal',
                  options: [
                    {'value': 'none', 'emoji': '👨', 'label': 'Yok'},
                    {'value': 'beard', 'emoji': '🧔', 'label': 'Sakallı'},
                  ],
                  currentValue: _selectedFacialHair,
                  onSelect: (v) => setState(() => _selectedFacialHair = v),
                ),
              ],
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAvatar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Değişiklikleri Kaydet',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
