import '../models/app_user.dart';
import '../models/call_list.dart';

/// Contract of the "Mock API V2" Postman collection.
abstract class CalleyDataSource {
  Future<String> register({
    required String username,
    required String email,
    required String password,
  });

  Future<AppUser> login({required String email, required String password});

  Future<String> sendOtp({required String email});

  Future<String> verifyOtp({required String email, required String otp});

  Future<List<CallList>> getLists({required String userId});

  Future<CallListDetails> getListDetails({required String listId});
}
