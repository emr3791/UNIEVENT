import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import '../data/turkey_cities.dart';
import '../widgets/avatar_widget.dart';
import '../models/user.dart';
import 'avatar_edit_screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({Key? key}) : super(key: key);

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

// Simple input formatter that inserts a space every 4 digits for readability
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final index = i + 1;
      if (index % 4 == 0 && index != digits.length) buffer.write(' ');
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Formats expiry as MM/YY while user types (expects digits only formatter before this)
class ExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll('/', '');
    if (digits.length > 4) digits = digits.substring(0, 4);
    String result = digits;
    if (digits.length >= 3) {
      result = '${digits.substring(0, 2)}/${digits.substring(2)}';
    } else if (digits.length >= 2) {
      result = digits.substring(0, 2);
    }
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _fullNameController = TextEditingController();
  String? _selectedCity;  bool _useProfilePhoto = true;
  bool _isSaving = false;
  bool _isDeletingAccount = false;
  bool _initialized = false;
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  bool _saveCard = false;

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    if (!mounted) return;

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
      _selectedCity = user?.city ?? turkeyCities.first;      _useProfilePhoto =
          (user?.profileImage != null && user!.profileImage!.isNotEmpty);
      _initialized = true;
      // Try loading saved card info (if any) from secure storage
      const storage = FlutterSecureStorage();
      storage.read(key: 'saved_card_number').then((card) {
        storage.read(key: 'saved_card_expiry').then((exp) {
          storage.read(key: 'saved_card_cvv').then((cvv) {
            if (card != null || exp != null || cvv != null) {
              setState(() {
                _cardNumberController.text = card ?? '';
                _expiryController.text = exp ?? '';
                _cvvController.text = cvv ?? '';
                _saveCard = true;
              });
            }
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kişisel Bilgilerim'),
          backgroundColor: const Color(0xFF6366F1),
          bottom: TabBar(
            labelColor: isDark ? Colors.white : theme.colorScheme.primary,
            unselectedLabelColor: isDark
                ? Colors.white70
                : theme.colorScheme.onSurface.withAlpha(153),
            indicatorColor: isDark ? Colors.white : theme.colorScheme.primary,
            tabs: const [Tab(text: 'Genel'), Tab(text: 'Kart Bilgilerim')],
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
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
                  const Text('Ad Soyad',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('E-posta',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: user?.email ?? '',
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Bulunduğun Şehir',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCity,
                    items: turkeyCities
                        .map((city) =>
                            DropdownMenuItem(value: city, child: Text(city)))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedCity = value);
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12))),
                  ),
                  const SizedBox(height: 16),
                  const Text('Cinsiyet (Kayıtlı)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: user?.gender == 'female' ? 'Kadın' : 'Erkek',
                    readOnly: true,
                    style: TextStyle(color: Colors.grey[600]),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
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
                                builder: (context) =>
                                    const AvatarEditScreen())).then((_) {
                          setState(() {});
                        });
                      },
                      icon: const Icon(Icons.face),
                      label: const Text('Avatar Oluştur / Düzenle'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
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
                              final authProvider = Provider.of<AuthProvider>(
                                  context,
                                  listen: false);
                              authProvider.updateProfile(
                                  fullName: _fullNameController.text.trim(),
                                  city: _selectedCity,
                                  profileImage: _useProfilePhoto
                                      ? user?.profileImage
                                      : '');
                              setState(() {
                                _isSaving = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Bilgiler kaydedildi')));
                            },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: _isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Bilgileri Kaydet',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Güvenlik',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text('Şifre değiştirme henüz desteklenmiyor')));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple),
                    child: const Text('Şifre Değiştir',
                        style: TextStyle(color: Colors.white)),
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
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('İptal')),
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Sil'))
                                        ]));
                            if (confirmed != true) return;
                            setState(() {
                              _isDeletingAccount = true;
                            });
                            await authProvider.deleteAccount();
                            setState(() {
                              _isDeletingAccount = false;
                            });
                            if (!context.mounted) return;
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/login', (route) => false);
                          },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: _isDeletingAccount
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Hesabı Sil',
                            style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),

            // Card Info Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Kart Bilgilerim',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),
                      const Text('1 UNV = 1 TL',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                              fontSize: 16)),
                      const SizedBox(height: 16),
                      TextFormField(
                          controller: _cardNumberController,
                          decoration: InputDecoration(
                              labelText: 'Kart Numarası',
                              hintText: 'xxxx xxxx xxxx xxxx',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(16),
                            CardNumberInputFormatter(),
                          ]),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: TextFormField(
                                  controller: _expiryController,
                                  decoration: InputDecoration(
                                      labelText: 'SKT (AA/YY)',
                                      hintText: 'MM/YY',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12))),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                                ExpiryInputFormatter(),
                              ])),
                          const SizedBox(width: 12),
                          Expanded(
                              child: TextFormField(
                                  controller: _cvvController,
                                  decoration: InputDecoration(
                                      labelText: 'CVV',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12))),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ])),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Checkbox(
                              value: _saveCard,
                              onChanged: (v) {
                                setState(() {
                                  _saveCard = v ?? false;
                                });
                              }),
                          const SizedBox(width: 8),
                          const Expanded(
                              child: Text(
                                  'Kart bilgilerini kaydet (şifreli olarak saklanacaktır)'))
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                          'Bilgiler yalnızca test amaçlıdır. Gerçek ödeme entegrasyonu yoktur.',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            // Simulate purchasing UNV (opens dialog to choose amount)
                            showDialog(
                                context: context,
                                builder: (context) {
                                  final amountController =
                                      TextEditingController(text: '1000');
                                  return AlertDialog(
                                    title: const Text('UNV Satın Al'),
                                    content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                              'Kaç UNV satın almak istiyorsunuz?'),
                                          const SizedBox(height: 8),
                                          TextField(
                                              controller: amountController,
                                              keyboardType:
                                                  TextInputType.number)
                                        ]),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('İptal')),
                                      TextButton(
                                          onPressed: () async {
                                            final amt = double.tryParse(
                                                    amountController.text) ??
                                                0;
                                            if (amt <= 0) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'Geçerli bir miktar girin')));
                                              return;
                                            }
                                            Navigator.pop(context);
                                            // Add to wallet provider if exists
                                            try {
                                              final wallet =
                                                  Provider.of<WalletProvider>(
                                                      context,
                                                      listen: false);
                                              wallet.addBalance(amt);
                                              // Save card info if requested
                                              if (_saveCard) {
                                                try {
                                                  const storage =
                                                      FlutterSecureStorage();
                                                  await storage.write(
                                                      key: 'saved_card_number',
                                                      value:
                                                          _cardNumberController
                                                              .text);
                                                  await storage.write(
                                                      key: 'saved_card_expiry',
                                                      value: _expiryController
                                                          .text);
                                                  await storage.write(
                                                      key: 'saved_card_cvv',
                                                      value:
                                                          _cvvController.text);
                                                } catch (e) {
                                                  // ignore storage errors
                                                }
                                              }
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          '${amt.toStringAsFixed(0)} UNV satın alındı')));
                                            } catch (e) {
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'Cüzdan hizmeti bulunamadı')));
                                            }
                                          },
                                          child: const Text('Satın Al'))
                                    ],
                                  );
                                });
                          },
                          child: const Text('Kart ile UNV Satın Al'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
