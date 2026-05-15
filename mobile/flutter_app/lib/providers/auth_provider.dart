import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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

  static const _baseUrl = 'https://unievent-backend-u3wn.onrender.com/api';

  // ── Internal helpers ──────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Builds a User from the backend's JSON response.
  // Adjust field names here if your backend returns different keys.
  User _userFromJson(Map<String, dynamic> json, {
    required String email,
    required String username,
    required String fullName,
    required String userType,
    required String gender,
    String? university,
  }) {
    return User(
      id: json['userId']?.toString() ?? json['id']?.toString() ?? '',
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
  }

  // ── Register ──────────────────────────────────────────────────────────────

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
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'fullName': fullName,
          'username': username,
          'userType': userType,
          'gender': gender,
          'university': university,
        }),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        _currentUser = _userFromJson(
          body,
          email: email,
          username: username,
          fullName: fullName,
          userType: userType,
          gender: gender,
          university: university,
        );
        _isLoggedIn = true;
      } else {
        // Backend sends { "error": "..." } or { "message": "..." } on failure
        _error = body['error'] as String? ??
            body['message'] as String? ??
            'Kayıt başarısız (${response.statusCode})';
        _isLoggedIn = false;
      }
    } on http.ClientException catch (e) {
      _error = 'Bağlantı hatası: ${e.message}';
      _isLoggedIn = false;
    } catch (e) {
      _error = 'Beklenmedik hata: $e';
      _isLoggedIn = false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Login (student) ───────────────────────────────────────────────────────

  Future<void> loginWithStudentEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        _currentUser = _userFromJson(
          body,
          email: email,
          username: body['username'] as String? ?? email.split('@')[0],
          fullName: body['fullName'] as String? ?? '',
          userType: 'student',
          gender: body['gender'] as String? ?? 'neutral',
          university: body['university'] as String?,
        );
        _isLoggedIn = true;
      } else {
        _error = body['error'] as String? ??
            body['message'] as String? ??
            'Giriş başarısız (${response.statusCode})';
        _isLoggedIn = false;
      }
    } on http.ClientException catch (e) {
      _error = 'Bağlantı hatası: ${e.message}';
      _isLoggedIn = false;
    } catch (e) {
      _error = 'Beklenmedik hata: $e';
      _isLoggedIn = false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Login (regular) ───────────────────────────────────────────────────────

  Future<void> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        _currentUser = _userFromJson(
          body,
          email: email,
          username: body['username'] as String? ?? email.split('@')[0],
          fullName: body['fullName'] as String? ?? '',
          userType: body['userType'] as String? ?? 'regular',
          gender: body['gender'] as String? ?? 'neutral',
          university: body['university'] as String?,
        );
        _isLoggedIn = true;
      } else {
        _error = body['error'] as String? ??
            body['message'] as String? ??
            'Giriş başarısız (${response.statusCode})';
        _isLoggedIn = false;
      }
    } on http.ClientException catch (e) {
      _error = 'Bağlantı hatası: ${e.message}';
      _isLoggedIn = false;
    } catch (e) {
      _error = 'Beklenmedik hata: $e';
      _isLoggedIn = false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Logout / Delete / Profile ─────────────────────────────────────────────

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
      // TODO: call DELETE /api/auth/account when backend supports it
      _currentUser = null;
      _isLoggedIn = false;
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