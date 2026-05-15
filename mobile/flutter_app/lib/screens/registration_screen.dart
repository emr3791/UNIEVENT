import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_logo.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const _kPrimary = Color(0xFF6366F1);

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _universityController = TextEditingController();

  String? _selectedGender;
  bool _isStudentType = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  // ── University list loaded from API ──────────────────────────────────────
  List<DropdownMenuItem<String>> _universityItems = [];
  bool _loadingUniversities = false;
  String? _universityError;

  static final List<DropdownMenuItem<String>> _genderItems =
  ['Kadın', 'Erkek']
      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
      .toList();

  @override
  void initState() {
    super.initState();
    _fetchUniversities();
  }

  // ── Fetch universities from backend ──────────────────────────────────────

  Future<void> _fetchUniversities() async {
    setState(() {
      _loadingUniversities = true;
      _universityError = null;
    });

    try {
      final url = Uri.parse(
          'https://unievent-backend-u3wn.onrender.com/api/universities');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> universities = jsonDecode(response.body);
        setState(() {
          _universityItems = universities
              .map((uni) => DropdownMenuItem<String>(
            value: uni['name'] as String,
            child: Text(
              uni['name'] as String,
              style: const TextStyle(color: Colors.black87),
            ),
          ))
              .toList();
          _loadingUniversities = false;
        });
      } else {
        setState(() {
          _universityError = 'Üniversiteler yüklenemedi';
          _loadingUniversities = false;
        });
      }
    } catch (e) {
      setState(() {
        _universityError = 'Bağlantı hatası';
        _loadingUniversities = false;
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _universityController.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────

  bool _validateInputs() {
    if (_fullNameController.text.trim().isEmpty) {
      _showError('Lütfen adınızı girin');
      return false;
    }
    if (_emailController.text.trim().isEmpty) {
      _showError('Lütfen e-posta adresinizi girin');
      return false;
    }
    if (!_emailController.text.contains('@')) {
      _showError('Geçerli bir e-posta adresi girin');
      return false;
    }
    if (_isStudentType &&
        !_emailController.text.endsWith('.edu.tr') &&
        !_emailController.text.contains('@student.')) {
      _showError('Lütfen geçerli bir öğrenci e-postası girin (.edu.tr)');
      return false;
    }
    if (_usernameController.text.trim().isEmpty) {
      _showError('Lütfen kullanıcı adı girin');
      return false;
    }
    if (_usernameController.text.trim().length < 3) {
      _showError('Kullanıcı adı en az 3 karakter olmalı');
      return false;
    }
    if (_selectedGender == null) {
      _showError('Lütfen cinsiyetinizi seçin');
      return false;
    }
    if (_passwordController.text.isEmpty) {
      _showError('Lütfen şifre girin');
      return false;
    }
    if (_passwordController.text.length < 6) {
      _showError('Şifre en az 6 karakter olmalı');
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Şifreler eşleşmiyor');
      return false;
    }
    if (_isStudentType && _universityController.text.isEmpty) {
      _showError('Lütfen üniversitenizi seçin');
      return false;
    }
    if (!_agreedToTerms) {
      _showError('Lütfen şartları kabul edin');
      return false;
    }
    return true;
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _handleRegister(AuthProvider authProvider) async {
    if (!_validateInputs()) return;

    await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      username: _usernameController.text.trim(),
      userType: _isStudentType ? 'student' : 'regular',
      gender: _selectedGender == 'Kadın' ? 'female' : 'male',
      university: _isStudentType ? _universityController.text : null,
    );

    if (!mounted) return;
    if (authProvider.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showError(authProvider.error ?? 'Kayıt başarısız');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_kPrimary, Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const AppLogo(size: 70),
                const SizedBox(height: 18),
                const Text(
                  'UniEvent AI',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Yeni Hesap Oluştur',
                  style:
                  TextStyle(fontSize: 16, color: Colors.white.withAlpha(204)),
                ),
                const SizedBox(height: 32),
                _UserTypeToggle(
                  isStudentType: _isStudentType,
                  onChanged: (val) => setState(() {
                    _isStudentType = val;
                    // Clear university when switching to non-student
                    if (!val) _universityController.clear();
                  }),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Ad Soyad',
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label:
                  _isStudentType ? 'Öğrenci E-postası' : 'E-posta Adresi',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _usernameController,
                  label: 'Kullanıcı Adı',
                  icon: Icons.account_circle,
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'Cinsiyet',
                  hint: 'Cinsiyet seçin',
                  value: _selectedGender,
                  items: _genderItems,
                  onChanged: (val) => setState(() => _selectedGender = val),
                ),
                const SizedBox(height: 16),

                // ── University dropdown (students only) ─────────────────────
                if (_isStudentType) ...[
                  if (_loadingUniversities)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text('Üniversiteler yükleniyor...',
                              style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    )
                  else if (_universityError != null)
                  // Retry button if fetch failed
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Text(_universityError!,
                              style: const TextStyle(color: Colors.white70)),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _fetchUniversities,
                            child: const Text(
                              'Tekrar Dene',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    _buildDropdownField(
                      label: 'Üniversite',
                      hint: 'Üniversite seçin',
                      value: _universityController.text.isNotEmpty
                          ? _universityController.text
                          : null,
                      items: _universityItems,
                      onChanged: (val) =>
                          setState(() => _universityController.text = val ?? ''),
                    ),
                  const SizedBox(height: 16),
                ],

                _buildPasswordField(
                  controller: _passwordController,
                  label: 'Şifre',
                  isObscure: _obscurePassword,
                  onToggle: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Şifre Onayı',
                  isObscure: _obscureConfirmPassword,
                  onToggle: () => setState(
                          () => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (val) =>
                          setState(() => _agreedToTerms = val ?? false),
                      fillColor: WidgetStateProperty.all(Colors.white),
                      checkColor: _kPrimary,
                    ),
                    Expanded(
                      child: Text(
                        'Şartları ve Koşulları Kabul Ediyorum',
                        style: TextStyle(
                          color: Colors.white.withAlpha(230),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () => _handleRegister(authProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _kPrimary,
                          disabledBackgroundColor:
                          Colors.white.withAlpha(128),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                            AlwaysStoppedAnimation(_kPrimary),
                          ),
                        )
                            : const Text(
                          'Hesap Oluştur',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _kPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Zaten bir hesabın var mı? ',
                      style: TextStyle(color: Colors.white.withAlpha(204)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Giriş Yap',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Reusable field builders ───────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: _fieldDecoration(label).copyWith(
        prefixIcon: Icon(icon, color: Colors.white.withAlpha(178)),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isObscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.white),
      decoration: _fieldDecoration(label).copyWith(
        prefixIcon: Icon(Icons.lock, color: Colors.white.withAlpha(178)),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            isObscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.white.withAlpha(178),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white.withAlpha(178), fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(38),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withAlpha(76), width: 1),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(border: InputBorder.none),
            dropdownColor: Colors.white,
            style: const TextStyle(color: Colors.black87),
            hint: Text(hint, style: const TextStyle(color: Colors.white70)),
            items: items,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withAlpha(178)),
      filled: true,
      fillColor: Colors.white.withAlpha(38),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withAlpha(76), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      ),
    );
  }
}

// ── Unchanged toggle widgets ──────────────────────────────────────────────────

class _UserTypeToggle extends StatelessWidget {
  final bool isStudentType;
  final ValueChanged<bool> onChanged;

  const _UserTypeToggle({required this.isStudentType, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(51),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(76), width: 1),
      ),
      child: Row(
        children: [
          _ToggleOption(
              label: 'Öğrenci',
              isSelected: isStudentType,
              onTap: () => onChanged(true)),
          _ToggleOption(
              label: 'Diğer Kullanıcı',
              isSelected: !isStudentType,
              onTap: () => onChanged(false)),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleOption(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF6366F1) : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}