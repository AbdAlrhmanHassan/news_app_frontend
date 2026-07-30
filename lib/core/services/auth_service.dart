import '../models/user_model.dart';
import '../entities/user_entity.dart';

abstract class AuthService {
  // 🚀 NEW: Guest Login
  Future<UserModel> signInAnonymously();

  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithApple();
  Future<UserModel> login({required String email, required String password});

  bool isLoggedIn();
  Future<void> signOut();
  UserEntity? getCurrentUser();

  Future<UserModel> register({
    required String email,
    required String password,
    required String username,
    String? country, // 🚀 NEW
    String? region, // 🚀 NEW
  });

  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  Future<bool> checkEmailVerified();

  /// ✅ New method to abstract re-auth logic
  Future<void> reauthenticate({required String password});
  Future<void> deleteUser();

  Future<void> updateAuthProfile({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
  });

  // ✅ New: Ask "Is this Google, Apple, or Password?"
  Future<String?> getCurrentAuthProvider();
}
