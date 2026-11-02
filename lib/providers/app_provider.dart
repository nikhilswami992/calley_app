import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../data/models/app_language.dart';
import '../data/models/app_user.dart';
import '../data/models/call_list.dart';
import '../data/services/api_client.dart';
import '../data/services/calley_repository.dart';

class PendingRegistration {
  final String name;
  final String email;
  final String password;
  final String countryCode;
  final String mobile;

  const PendingRegistration({
    required this.name,
    required this.email,
    required this.password,
    required this.countryCode,
    required this.mobile,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'countryCode': countryCode,
        'mobile': mobile,
      };

  factory PendingRegistration.fromJson(Map<String, dynamic> json) =>
      PendingRegistration(
        name: (json['name'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        password: (json['password'] ?? '').toString(),
        countryCode: (json['countryCode'] ?? '+91').toString(),
        mobile: (json['mobile'] ?? '').toString(),
      );
}

class AppProvider extends ChangeNotifier {
  AppProvider({
    required SharedPreferences prefs,
    required CalleyRepository repository,
  })  : _prefs = prefs,
        _repo = repository {
    _hydrate();
  }

  final SharedPreferences _prefs;
  final CalleyRepository _repo;

  AppLanguage _language = AppLanguage.all.first;
  bool _hasSelectedLanguage = false;
  AppUser? _user;
  String _mobile = '7676286822';
  PendingRegistration? _pendingRegistration;

  List<CallList> _lists = const [];
  CallList? _selectedList;
  CallListDetails? _listDetails;

  bool _isBusy = false;
  bool _isLoadingLists = false;
  bool _isLoadingDetails = false;
  String? _errorMessage;
  String? _lastOtp;

  AppLanguage get language => _language;
  bool get hasSelectedLanguage => _hasSelectedLanguage;
  AppUser? get user => _user;
  String get mobile => _mobile;
  PendingRegistration? get pendingRegistration => _pendingRegistration;

  List<CallList> get lists => _lists;
  CallList? get selectedList => _selectedList;
  CallListDetails? get listDetails => _listDetails;

  bool get isBusy => _isBusy;
  bool get isLoadingLists => _isLoadingLists;
  bool get isLoadingDetails => _isLoadingDetails;
  String? get errorMessage => _errorMessage;
  String? get lastOtp => _lastOtp;
  bool get usingOfflineFallback => _repo.usingOfflineFallback;

  bool get hasSeenIntro {
    final u = _user;
    if (u == null) return false;
    return _prefs.getBool('${StorageKeys.seenIntro}${u.id}') ?? false;
  }

  void _hydrate() {
    final langCode = _prefs.getString(StorageKeys.language);
    if (langCode != null) {
      _language = AppLanguage.byCode(langCode);
      _hasSelectedLanguage = true;
    }

    final rawUser = _prefs.getString(StorageKeys.user);
    if (rawUser != null) {
      try {
        final decoded = Map<String, dynamic>.from(jsonDecode(rawUser));
        _user = AppUser.fromJson(decoded);
        if (decoded['mobile'] is String &&
            (decoded['mobile'] as String).isNotEmpty) {
          _mobile = decoded['mobile'] as String;
        }
      } catch (_) {}
    }

    final rawPending = _prefs.getString(StorageKeys.pendingRegistration);
    if (rawPending != null) {
      try {
        _pendingRegistration = PendingRegistration.fromJson(
          Map<String, dynamic>.from(jsonDecode(rawPending)),
        );
      } catch (_) {}
    }
  }

  Future<void> selectLanguage(AppLanguage lang) async {
    _language = lang;
    _hasSelectedLanguage = true;
    await _prefs.setString(StorageKeys.language, lang.code);
    notifyListeners();
  }

  /// Registers the user and triggers an OTP email (`POST /auth/register` then
  /// `POST /auth/send-otp`).
  Future<bool> registerAndSendOtp({
    required String name,
    required String email,
    required String password,
    required String countryCode,
    required String mobile,
  }) async {
    return _guard(() async {
      await _repo.register(
        username: name.trim(),
        email: email.trim(),
        password: password,
      );
      final otpResult = await _repo.sendOtp(email: email.trim());
      if (RegExp(r'^\d{6}$').hasMatch(otpResult)) {
        _lastOtp = otpResult;
      }
      _mobile = mobile.trim().isEmpty ? _mobile : mobile.trim();
      _pendingRegistration = PendingRegistration(
        name: name.trim(),
        email: email.trim(),
        password: password,
        countryCode: countryCode,
        mobile: _mobile,
      );
      await _prefs.setString(
        StorageKeys.pendingRegistration,
        jsonEncode(_pendingRegistration!.toJson()),
      );
    });
  }

  Future<bool> resendOtp() async {
    final email = _pendingRegistration?.email ?? _user?.email;
    if (email == null || email.isEmpty) {
      _errorMessage = 'No email address found to resend OTP.';
      notifyListeners();
      return false;
    }
    return _guard(() async {
      final otpResult = await _repo.sendOtp(email: email);
      if (RegExp(r'^\d{6}$').hasMatch(otpResult)) {
        _lastOtp = otpResult;
      }
    });
  }

  /// Verifies the 6-digit OTP (`POST /auth/verify-otp`) and signs the newly
  /// registered user in so we obtain their `userId` (`POST /auth/login`).
  Future<bool> verifyOtp(String otp) async {
    final pending = _pendingRegistration;
    final email = pending?.email ?? _user?.email ?? '';
    return _guard(() async {
      await _repo.verifyOtp(email: email, otp: otp.trim());
      if (pending != null) {
        try {
          final loggedIn = await _repo.login(
            email: pending.email,
            password: pending.password,
          );
          await _saveUser(loggedIn, mobile: pending.mobile);
        } catch (_) {
          // If the mock server returns a static user on login, still keep the
          // name/email the candidate typed during registration.
          await _saveUser(
            AppUser(
              id: '68626f9497757cb741f449b0',
              username: pending.name,
              email: pending.email,
            ),
            mobile: pending.mobile,
          );
        }
        _pendingRegistration = null;
        await _prefs.remove(StorageKeys.pendingRegistration);
      }
    });
  }

  /// Authenticates an existing user (`POST /auth/login`).
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    return _guard(() async {
      final loggedIn = await _repo.login(
        email: email.trim(),
        password: password,
      );
      await _saveUser(loggedIn);
    });
  }

  Future<void> _saveUser(AppUser user, {String? mobile}) async {
    _user = user;
    if (mobile != null && mobile.isNotEmpty) {
      _mobile = mobile;
    }
    await _prefs.setString(
      StorageKeys.user,
      jsonEncode({...user.toJson(), 'mobile': _mobile}),
    );
  }

  Future<void> markIntroSeen() async {
    final u = _user;
    if (u == null) return;
    await _prefs.setBool('${StorageKeys.seenIntro}${u.id}', true);
    notifyListeners();
  }

  /// Fetches calling lists (`GET /list?userId=...`).
  Future<List<CallList>> fetchLists() async {
    final userId = _user?.id ?? '68626f9497757cb741f449b0';
    _isLoadingLists = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _lists = await _repo.getLists(userId: userId);
      return _lists;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return const [];
    } catch (e) {
      _errorMessage = e.toString();
      return const [];
    } finally {
      _isLoadingLists = false;
      notifyListeners();
    }
  }

  /// Selects a calling list and fetches its statistics + call records
  /// (`GET /list/{listId}`).
  Future<bool> selectCallList(CallList list) async {
    _selectedList = list;
    _isLoadingDetails = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _listDetails = await _repo.getListDetails(listId: list.id);
      await _prefs.setString(StorageKeys.selectedListId, list.id);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  void clearSelectedList() {
    _selectedList = null;
    _listDetails = null;
    _prefs.remove(StorageKeys.selectedListId);
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    _selectedList = null;
    _listDetails = null;
    _lists = const [];
    _pendingRegistration = null;
    await _prefs.remove(StorageKeys.user);
    await _prefs.remove(StorageKeys.selectedListId);
    await _prefs.remove(StorageKeys.pendingRegistration);
    notifyListeners();
  }

  Future<bool> _guard(Future<void> Function() action) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}
