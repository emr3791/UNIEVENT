import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _error;
  String? _token;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get error => _error;
  String? get token => _token;

  static const _baseUrl = 'https://unievent-backend-u3wn.onrender.com/api';

  // ── Internal helpers ──────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

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

  // ── Token persistence ─────────────────────────────────────────────────────

  // Call this in main.dart before runApp() to restore session on app restart
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('jwt_token');
    if (savedToken == null) return;

    _token = savedToken;
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> _saveToken(String token, String? userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    if (userType != null) await prefs.setString('userType', userType);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('userType');
  }

  // ── Shared login request ──────────────────────────────────────────────────

  Future<void> _loginRequest({
    required String email,
    required String password,
    String fallbackUserType = 'regular',
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
        // Save token
        final token = body['token'] as String?;
        if (token != null) {
          _token = token;
          final userJson = body['user'] as Map<String, dynamic>?;
          await _saveToken(token, userJson?['userType'] as String?);
        }

        // Build user — prefer data from backend, fall back to what we know
        final userJson = body['user'] as Map<String, dynamic>? ?? body;
        _currentUser = _userFromJson(
          userJson,
          email: email,
          username: userJson['username'] as String? ?? email.split('@')[0],
          fullName: userJson['fullName'] as String? ?? '',
          userType: userJson['userType'] as String? ?? fallbackUserType,
          gender: userJson['gender'] as String? ?? 'neutral',
          university: userJson['university'] as String?,
        );
        _isLoggedIn = true;
      } else {
        _error = body['error'] as String? ??
            body['message'] as String? ??
            'Giriş başarısız (${response.statusCode})';
        _isLoggedIn = false;
      }
    } on http.ClientException {
      _error = 'Sunucuya ulaşılamadı. İnternet bağlantınızı kontrol edin.';
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
    await _loginRequest(email: email, password: password, fallbackUserType: 'student');
  }

  // ── Login (regular) ───────────────────────────────────────────────────────

  Future<void> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    await _loginRequest(email: email, password: password, fallbackUserType: 'regular');
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
        // Some backends return a token on register too — save it if present
        final token = body['token'] as String?;
        if (token != null) {
          _token = token;
          await _saveToken(token, userType);
        }

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
        _error = body['error'] as String? ??
            body['message'] as String? ??
            'Kayıt başarısız (${response.statusCode})';
        _isLoggedIn = false;
      }
    } on http.ClientException {
      _error = 'Sunucuya ulaşılamadı. İnternet bağlantınızı kontrol edin.';
      _isLoggedIn = false;
    } catch (e) {
      _error = 'Beklenmedik hata: $e';
      _isLoggedIn = false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _clearToken();
    _currentUser = null;
    _token = null;
    _isLoggedIn = false;
    _error = null;
    notifyListeners();
  }

  // ── Delete account ────────────────────────────────────────────────────────

  Future<void> deleteAccount() async {
    _setLoading(true);
    _error = null;
    try {
      // TODO: call DELETE /api/auth/account when backend supports it
      await _clearToken();
      _currentUser = null;
      _token = null;
      _isLoggedIn = false;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ── Update profile ────────────────────────────────────────────────────────

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