import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../data/istanbul_universities.dart';
import '../widgets/app_logo.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

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

  bool _validateInputs() {
    if (_fullNameController.text.isEmpty) {
      _showError('Lütfen adınızı girin');
      return false;
    }
    if (_emailController.text.isEmpty) {
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
    if (_usernameController.text.isEmpty) {
      _showError('Lütfen kullanıcı adı girin');
      return false;
    }
    if (_usernameController.text.length < 3) {
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

  void _handleRegister(AuthProvider authProvider) async {
    if (!_validateInputs()) {
      return;
    }

    await authProvider.register(
      email: _emailController.text,
      password: _passwordController.text,
      fullName: _fullNameController.text,
      username: _usernameController.text,
      userType: _isStudentType ? 'student' : 'regular',
      gender: _selectedGender == 'Kadın' ? 'female' : 'male',
      university: _isStudentType ? _universityController.text : null,
    );

    if (mounted) {
      if (authProvider.isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showError(authProvider.error ?? 'Kayıt başarısız');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
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
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // User Type Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _isStudentType = true);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isStudentType
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  'Öğrenci',
                                  style: TextStyle(
                                    color: _isStudentType
                                        ? const Color(0xFF6366F1)
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _isStudentType = false);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isStudentType
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  'Diğer Kullanıcı',
                                  style: TextStyle(
                                    color: !_isStudentType
                                        ? const Color(0xFF6366F1)
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Full Name Field
                  _buildTextField(
                    controller: _fullNameController,
                    label: 'Ad Soyad',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  _buildTextField(
                    controller: _emailController,
                    label:
                        _isStudentType ? 'Öğrenci E-postası' : 'E-posta Adresi',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Username Field
                  _buildTextField(
                    controller: _usernameController,
                    label: 'Kullanıcı Adı',
                    icon: Icons.account_circle,
                  ),
                  const SizedBox(height: 16),

                  // Gender Field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cinsiyet',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedGender,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: Colors.black87),
                          hint: const Text(
                            'Cinsiyet seçin',
                            style: TextStyle(color: Colors.white70),
                          ),
                          items: ['Kadın', 'Erkek'].map((gender) {
                            return DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                  // University Field (only for students)
                  if (_isStudentType)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Üniversite',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: DropdownButtonFormField<String>(
                            initialValue: _universityController.text.isNotEmpty
                                ? _universityController.text
                                : null,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            dropdownColor: Colors.white,
                            style: const TextStyle(color: Colors.black87),
                            hint: const Text(
                              'Üniversite seçin',
                              style: TextStyle(color: Colors.white70),
                            ),
                            items: istanbulUniversities
                                .map(
                                  (uni) => DropdownMenuItem(
                                    value: uni.name,
                                    child: Text(
                                      uni.name,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _universityController.text = value ?? '';
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  // Password Field
                  _buildPasswordField(
                    controller: _passwordController,
                    label: 'Şifre',
                    isObscure: _obscurePassword,
                    onToggle: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password Field
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: 'Şifre Onayı',
                    isObscure: _obscureConfirmPassword,
                    onToggle: () {
                      setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Terms Agreement
                  Row(
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() => _agreedToTerms = value ?? false);
                        },
                        fillColor: WidgetStateProperty.all(Colors.white),
                        checkColor: const Color(0xFF6366F1),
                      ),
                      Expanded(
                        child: Text(
                          'Şartları ve Koşulları Kabul Ediyorum',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Register Button
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
                            foregroundColor: const Color(0xFF6366F1),
                            disabledBackgroundColor:
                                Colors.white.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                        Color(0xFF6366F1)),
                                  ),
                                )
                              : const Text(
                                  'Hesap Oluştur',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Zaten bir hesabın var mı? ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
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
      ),
    );
  }

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
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.white,
            width: 2,
          ),
        ),
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
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(Icons.lock, color: Colors.white.withOpacity(0.7)),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            isObscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.white,
            width: 2,
          ),
        ),
      ),
    );
  }
}
