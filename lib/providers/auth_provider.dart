import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mtag_queue_skipper/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  static const String _usersKey = 'users_v1';
  static const String _currentUserEmailKey = 'current_user_email';
  User? _user;

  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  String _emailKey(String email) => email.trim().toLowerCase();

  Future<Map<String, dynamic>> _loadUsers(SharedPreferences prefs) async {
    final raw = prefs.getString(_usersKey);
    if (raw != null && raw.trim().isNotEmpty) {
      try {
        return Map<String, dynamic>.from(json.decode(raw) as Map);
      } catch (_) {}
    }

    // Backward compatibility with previous single-user storage.
    final legacyUserData = prefs.getString('user');
    if (legacyUserData != null && legacyUserData.trim().isNotEmpty) {
      try {
        final legacyUser = User.fromJson(legacyUserData);
        return {_emailKey(legacyUser.email): legacyUser.toMap()};
      } catch (_) {}
    }

    return <String, dynamic>{};
  }

  Future<bool> register(User user) async {
    _user = user;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final users = await _loadUsers(prefs);
      final emailKey = _emailKey(user.email);
      users[emailKey] = user.toMap();

      final usersSaved = await prefs.setString(_usersKey, json.encode(users));
      final sessionSaved = await prefs.setString(_currentUserEmailKey, emailKey);
      return usersSaved && sessionSaved;
    } catch (_) {
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _loadUsers(prefs);
    final userMap = users[_emailKey(email)];
    if (userMap == null || userMap is! Map) {
      return false;
    }

    User savedUser;
    try {
      savedUser = User.fromMap(Map<String, dynamic>.from(userMap));
    } catch (_) {
      return false;
    }

    if (savedUser.email == email && savedUser.password == password) {
      _user = savedUser;
      await prefs.setString(_currentUserEmailKey, _emailKey(savedUser.email));
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _loadUsers(prefs);
    final currentEmail = prefs.getString(_currentUserEmailKey);
    if (currentEmail == null || currentEmail.trim().isEmpty) return;

    final userMap = users[currentEmail];
    if (userMap == null || userMap is! Map) return;

    try {
      _user = User.fromMap(Map<String, dynamic>.from(userMap));
      notifyListeners();
    } catch (_) {
      _user = null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserEmailKey);
    _user = null;
    notifyListeners();
  }
}
