import '../../core/constants/app_constants.dart';
import '../models/app_user.dart';
import '../models/call_list.dart';
import 'api_client.dart';
import 'calley_data_source.dart';

/// Talks to the hosted mock server documented in Postman.
class RemoteCalleyDataSource implements CalleyDataSource {
  RemoteCalleyDataSource(this._api);

  final ApiClient _api;

  String _message(dynamic json, String fallback) =>
      json is Map && json['message'] is String ? json['message'] : fallback;

  @override
  Future<String> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final json = await _api.post(ApiConstants.register, {
      'username': username,
      'email': email,
      'password': password,
    });
    return _message(json, 'User registered');
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final json = await _api.post(ApiConstants.login, {
      'email': email,
      'password': password,
    });
    if (json is Map && json['user'] is Map) {
      return AppUser.fromJson(Map<String, dynamic>.from(json['user']));
    }
    throw ApiException(_message(json, 'Login failed'));
  }

  @override
  Future<String> sendOtp({required String email}) async {
    final json = await _api.post(ApiConstants.sendOtp, {'email': email});
    return _message(json, 'OTP sent');
  }

  @override
  Future<String> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final json = await _api.post(ApiConstants.verifyOtp, {
      'email': email,
      'otp': otp,
    });
    return _message(json, 'OTP Verified');
  }

  @override
  Future<List<CallList>> getLists({required String userId}) async {
    final json = await _api.get(ApiConstants.lists, query: {'userId': userId});
    // The documented response is a single object, but accept arrays and
    // `{ lists: [...] }` / `{ data: [...] }` envelopes as well.
    Iterable raw;
    if (json is List) {
      raw = json;
    } else if (json is Map && json['lists'] is List) {
      raw = json['lists'];
    } else if (json is Map && json['data'] is List) {
      raw = json['data'];
    } else if (json is Map && json.containsKey('_id')) {
      raw = [json];
    } else {
      raw = const [];
    }
    return raw
        .whereType<Map>()
        .map((e) => CallList.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<CallListDetails> getListDetails({required String listId}) async {
    final json = await _api.get(ApiConstants.listDetails(listId));
    if (json is Map) {
      return CallListDetails.fromJson(Map<String, dynamic>.from(json));
    }
    throw const ApiException('Invalid list details response');
  }
}
