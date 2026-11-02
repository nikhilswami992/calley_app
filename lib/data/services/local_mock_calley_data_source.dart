import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../models/app_user.dart';
import '../models/call_list.dart';
import 'api_client.dart';
import 'calley_data_source.dart';

/// Offline implementation that mirrors the example responses of the
/// "Mock API V2" Postman collection. Used only when the hosted server is
/// unreachable so the app flow can still be demonstrated end-to-end.
class LocalMockCalleyDataSource implements CalleyDataSource {
  LocalMockCalleyDataSource(this._prefs);

  final SharedPreferences _prefs;

  /// OTP codes accepted by the offline mock (`229166` is the Postman example).
  static const String demoOtp = '123456';
  static const String postmanOtp = '229166';
  static const String _demoListId = '68626fb697757cb741f449b9';

  Future<void> _latency() =>
      Future.delayed(const Duration(milliseconds: 450));

  Map<String, dynamic> _users() {
    final defaults = <String, dynamic>{
      'testing@yopmail.com': {
        '_id': '68626f9497757cb741f449b0',
        'username': 'Dhrubo',
        'email': 'dhrubo@yopmail.com',
        'password': '123',
      },
      'dhrubo@yopmail.com': {
        '_id': '68626f9497757cb741f449b0',
        'username': 'Dhrubo',
        'email': 'dhrubo@yopmail.com',
        'password': '123',
      },
      'swati@cstech.in': {
        '_id': '68626f9497757cb741f449b0',
        'username': 'Swati',
        'email': 'swati@cstech.in',
        'password': '123',
      },
    };
    final raw = _prefs.getString(StorageKeys.mockUsers);
    if (raw == null) return defaults;
    return {...defaults, ...Map<String, dynamic>.from(jsonDecode(raw))};
  }

  Future<void> _saveUsers(Map<String, dynamic> users) =>
      _prefs.setString(StorageKeys.mockUsers, jsonEncode(users));

  String _objectId() {
    final r = Random();
    return List.generate(24, (_) => r.nextInt(16).toRadixString(16)).join();
  }

  @override
  Future<String> register({
    required String username,
    required String email,
    required String password,
  }) async {
    await _latency();
    final users = _users();
    final key = email.toLowerCase();
    users[key] = {
      '_id': users[key]?['_id'] ?? _objectId(),
      'username': username,
      'email': email,
      'password': password,
    };
    await _saveUsers(users);
    return 'User registered';
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    await _latency();
    final user = _users()[email.toLowerCase()];
    if (user == null || user['password'] != password) {
      throw const ApiException('Invalid email or password', statusCode: 401);
    }
    return AppUser.fromJson(Map<String, dynamic>.from(user));
  }

  @override
  Future<String> sendOtp({required String email}) async {
    await _latency();
    return 'OTP sent';
  }

  @override
  Future<String> verifyOtp({
    required String email,
    required String otp,
  }) async {
    await _latency();
    if (otp.trim().length != 6) {
      throw const ApiException('Please enter a valid 6-digit OTP',
          statusCode: 400);
    }
    return 'OTP Verified';
  }

  @override
  Future<List<CallList>> getLists({required String userId}) async {
    await _latency();
    return [
      CallList(id: _demoListId, name: 'Test List', clientId: userId),
    ];
  }

  @override
  Future<CallListDetails> getListDetails({required String listId}) async {
    await _latency();
    final raw = await rootBundle.loadString('assets/mock/list_details.json');
    return CallListDetails.fromJson(jsonDecode(raw));
  }
}
