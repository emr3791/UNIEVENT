import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;

  Future<void> loginWithStudentEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Email must be a student email
      if (!email.contains('@student.') && !email.endsWith('.edu.tr')) {
        throw Exception('Lütfen geçerli bir öğrenci e-postası girin');
      }

      // Simulated login
      await Future.delayed(const Duration(milliseconds: 500));

      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        username: email.split('@')[0],
        fullName: 'Öğrenci Adı', // örnek isim
        userType: 'student', gender: 'neutral',
        avatarSkinTone: 'medium',
        avatarHairStyle: 'short',
        avatarFacialHair: 'none',
      );
      _isLoggedIn = true;
    } catch (e) {
      _error = e.toString();
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!email.contains('@')) {
        throw Exception('Geçerli bir e-posta adresi girin');
      }
      if (password.length < 6) {
        throw Exception('Şifre en az 6 karakter olmalı');
      }

      // Simulated login
      await Future.delayed(const Duration(milliseconds: 500));

      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        username: email.split('@')[0],
        fullName: 'Kullanıcı Adı', // örnek isim
        userType: 'regular', gender: 'neutral',
        avatarSkinTone: 'medium',
        avatarHairStyle: 'short',
        avatarFacialHair: 'none',
      );
      _isLoggedIn = true;
    } catch (e) {
      _error = e.toString();
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String username,
    required String userType,
    required String gender,
    String? university,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validation
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Lütfen tüm alanları doldurun');
      }

      if (userType == 'student') {
        if (!email.contains('@student.') && !email.endsWith('.edu.tr')) {
          throw Exception(
              'Lütfen geçerli bir öğrenci e-postası girin (.edu.tr)');
        }
        if (university == null || university.isEmpty) {
          throw Exception('Üniversite bilgisi zorunludur');
        }
      }

      if (password.length < 6) {
        throw Exception('Şifre en az 6 karakter olmalı');
      }

      // Simulated registration
      await Future.delayed(const Duration(milliseconds: 800));

      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        username: username,
        fullName: fullName,
        userType: userType,
        university: university,
        gender: gender,
        avatarSkinTone: 'medium',
        avatarHairStyle: gender == 'female' ? 'longHair' : 'shortHair',
        avatarFacialHair: 'none',
      );
      _isLoggedIn = true;
    } catch (e) {
      _error = e.toString();
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;
    _error = null;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulated account deletion
      await Future.delayed(const Duration(milliseconds: 800));

      _currentUser = null;
      _isLoggedIn = false;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile information locally.
  void updateProfile({
    String? fullName,
    String? profileImage,
    String? university,
    String? city,
    String? gender,
    String? avatarSkinTone,
    String? avatarHairStyle,
    String? avatarFacialHair,
  }) {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      fullName: fullName,
      profileImage: profileImage,
      university: university,
      city: city,
      gender: gender,
      avatarSkinTone: avatarSkinTone,
      avatarHairStyle: avatarHairStyle,
      avatarFacialHair: avatarFacialHair,
    );
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
