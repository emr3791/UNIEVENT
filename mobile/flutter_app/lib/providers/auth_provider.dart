import 'package:flutter/material.dart';
import '../models/user.dart';

// This file has been optimized

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;

  // ── Internal helpers ──────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _performLogin(
      String email, String password, String userType) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      username: email.split('@')[0],
      fullName: userType == 'student' ? 'Öğrenci Adı' : 'Kullanıcı Adı',
      userType: userType,
      gender: 'neutral',
      avatarSkinTone: 'medium',
      avatarHairStyle: 'short',
      avatarFacialHair: 'none',
    );
    _isLoggedIn = true;
  }

  // ── Public methods ────────────────────────────────────────────────────────

  Future<void> loginWithStudentEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      if (!email.contains('@student.') && !email.endsWith('.edu.tr')) {
        throw Exception('Lütfen geçerli bir öğrenci e-postası girin');
      }
      await _performLogin(email, password, 'student');
    } catch (e) {
      _error = e.toString();
      _isLoggedIn = false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      if (!email.contains('@')) {
        throw Exception('Geçerli bir e-posta adresi girin');
      }
      if (password.length < 6) {
        throw Exception('Şifre en az 6 karakter olmalı');
      }
      await _performLogin(email, password, 'regular');
    } catch (e) {
      _error = e.toString();
      _isLoggedIn = false;
    } finally {
      _setLoading(false);
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
    _setLoading(true);
    _error = null;
    try {
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
      _setLoading(false);
    }
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    _error = null;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    _setLoading(true);
    _error = null;
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      _currentUser = null;
      _isLoggedIn = false;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

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
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }
}