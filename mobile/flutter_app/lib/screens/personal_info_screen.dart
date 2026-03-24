
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../data/turkey_cities.dart';
import '../widgets/avatar_widget.dart';
import '../models/user.dart';
import 'avatar_edit_screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({Key? key}) : super(key: key);

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _fullNameController = TextEditingController();
  String? _selectedCity;
  String? _selectedGender;
  bool _useProfilePhoto = true;
  bool _isSaving = false;
  bool _isDeletingAccount = false;
  bool _initialized = false;

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.updateProfile(profileImage: picked.path);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil fotoğrafı güncellendi')),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final authProvider = Provider.of<AuthProvider>(context);
      final user = authProvider.currentUser;
      _fullNameController.text = user?.fullName ?? '';
      _selectedCity = user?.city ?? turkeyCities.first;
      _selectedGender = user?.gender ?? 'neutral';
      _useProfilePhoto = (user?.profileImage != null && user!.profileImage!.isNotEmpty);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kişisel Bilgilerim'),
        backgroundColor: const Color(0xFF6366F1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AvatarWidget(
                    user: user ??
                        User(
                          id: 'guest',
                          email: '',
                          username: '',
                          fullName: 'Kullanıcı',
                          userType: 'regular',
                        ),
                    size: 100,
                    showBorder: true,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: _pickImage,
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFF6366F1),
                        child: Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _useProfilePhoto = !_useProfilePhoto;
                  });
                },
                child: Text(_useProfilePhoto
                    ? 'Avatarı Kullan'
                    : 'Profil Fotoğrafı Kullan'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ad Soyad',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'E-posta',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: user?.email ?? '',
              readOnly: true,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bulunduğun Şehir',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedCity,
              items: turkeyCities
                  .map(
                    (city) => DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCity = value;
                });
              },
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cinsiyet (Kayıtlı)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: user?.gender == 'female' ? 'Kadın' : 'Erkek',
              readOnly: true,
              style: TextStyle(color: Colors.grey[600]),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                fillColor: Colors.grey[100],
                filled: true,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AvatarEditScreen(),
                    ),
                  ).then((_) {
                    setState(() {}); // refresh on return
                  });
                },
                icon: const Icon(Icons.face),
                label: const Text('Avatar Oluştur / Düzenle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () {
                        setState(() {
                          _isSaving = true;
                        });
                        final authProvider =
                            Provider.of<AuthProvider>(context, listen: false);
                        authProvider.updateProfile(
                          fullName: _fullNameController.text.trim(),
                          city: _selectedCity,
                          profileImage: _useProfilePhoto ? user?.profileImage : '',
                        );
                        setState(() {
                          _isSaving = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bilgiler kaydedildi')),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Bilgileri Kaydet',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Güvenlik',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Placeholder for password change
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Şifre değiştirme henüz desteklenmiyor')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text('Şifre Değiştir', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isDeletingAccount
                  ? null
                  : () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Hesabı Sil'),
                          content: const Text(
                              'Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('İptal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Sil'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed != true) return;

                      setState(() {
                        _isDeletingAccount = true;
                      });

                      await authProvider.deleteAccount();

                      setState(() {
                        _isDeletingAccount = false;
                      });

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: _isDeletingAccount
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Hesabı Sil', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
