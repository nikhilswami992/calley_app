import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../models/app_user.dart';
import '../models/call_list.dart';
import 'api_client.dart';
import 'calley_data_source.dart';

/// Coordinates the remote API and the offline fallback data source.
///
/// Every call goes to `https://mock-api.calleyacd.com/api` first. If the live
/// server is unreachable (DNS/TLS error, timeout, 5xx, or 404 HTML when the
/// mock host is offline) and [ApiConstants.enableOfflineFallback] is enabled,
/// the call transparently falls back to the local Postman-spec mock and flips
/// [usingOfflineFallback] so the UI can inform the user.
class CalleyRepository {
  CalleyRepository({
    required CalleyDataSource remote,
    required CalleyDataSource local,
  })  : _remote = remote,
        _local = local;

  final CalleyDataSource _remote;
  final CalleyDataSource _local;

  bool _usingOfflineFallback = false;
  bool get usingOfflineFallback => _usingOfflineFallback;

  Future<T> _run<T>(
    Future<T> Function(CalleyDataSource ds) action, {
    Future<void> Function()? mirrorToLocal,
  }) async {
    try {
      final result = await action(_remote);
      _usingOfflineFallback = false;
      if (mirrorToLocal != null) {
        try {
          await mirrorToLocal();
        } catch (_) {}
      }
      return result;
    } on ApiException catch (e) {
      if (ApiConstants.enableOfflineFallback && e.isUnreachable) {
        debugPrint('[CalleyRepository] Live API unreachable ($e); '
            'falling back to local Postman mock.');
        _usingOfflineFallback = true;
        return action(_local);
      }
      rethrow;
    }
  }

  Future<String> register({
    required String username,
    required String email,
    required String password,
  }) {
    return _run(
      (ds) => ds.register(username: username, email: email, password: password),
      mirrorToLocal: () => _local.register(
        username: username,
        email: email,
        password: password,
      ),
    );
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) {
    return _run((ds) => ds.login(email: email, password: password));
  }

  Future<String> sendOtp({required String email}) {
    return _run((ds) => ds.sendOtp(email: email));
  }

  Future<String> verifyOtp({
    required String email,
    required String otp,
  }) {
    return _run((ds) => ds.verifyOtp(email: email, otp: otp));
  }

  Future<List<CallList>> getLists({required String userId}) {
    return _run((ds) => ds.getLists(userId: userId));
  }

  Future<CallListDetails> getListDetails({required String listId}) {
    return _run((ds) => ds.getListDetails(listId: listId));
  }
}
