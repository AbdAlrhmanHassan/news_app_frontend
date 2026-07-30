import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../models/user_model.dart';
import '../entities/user_entity.dart';
import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    _initGoogle();
  }

  Future<void> _initGoogle() async {
    final bool isNativeAndroid =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

    await GoogleSignIn.instance.initialize(
      serverClientId: isNativeAndroid
          ? '338878188661-mdq5no1kdnlq11clvq47e4lmbjh984pl.apps.googleusercontent.com'
          : null,
    );
  }

  @override
  bool isLoggedIn() => _firebaseAuth.currentUser != null;

  // ===========================================================================
  // 🚀 ANONYMOUS / GUEST SIGN-IN
  // ===========================================================================
  @override
  Future<UserModel> signInAnonymously() async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      return _mapFirebaseUser(userCredential.user!);
    } catch (e) {
      throw Exception('Guest Sign-In failed: $e');
    }
  }

  // ===========================================================================
  // 🚀 GOOGLE SIGN-IN (WITH SEAMLESS GUEST UPGRADE)
  // ===========================================================================
  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await GoogleSignIn.instance
          .authenticate(scopeHint: const ['email', 'profile']);

      if (account == null) throw Exception('Google Sign-In aborted.');

      final googleAuth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final currentUser = _firebaseAuth.currentUser;
      UserCredential userCredential;

      // 🛡️ THE MAGIC BLOCK: Try to link, fallback to normal login if needed
      try {
        if (currentUser != null && currentUser.isAnonymous) {
          userCredential = await currentUser.linkWithCredential(credential);
        } else {
          userCredential = await _firebaseAuth.signInWithCredential(credential);
        }
      } on FirebaseAuthException catch (e) {
        // If the email is already in use by an older account, just log into it!
        if (e.code == 'email-already-in-use' ||
            e.code == 'credential-already-in-use') {
          userCredential = await _firebaseAuth.signInWithCredential(credential);
        } else {
          rethrow;
        }
      }

      return _mapFirebaseUser(userCredential.user!);
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  // ===========================================================================
  // 🚀 APPLE SIGN-IN (WITH SEAMLESS GUEST UPGRADE)
  // ===========================================================================
  @override
  Future<UserModel> signInWithApple() async {
    final bool isNativeAndroid =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

    if (isNativeAndroid) {
      throw Exception(
        'Apple login on Android requires a paid Apple Developer account.',
      );
    }

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final provider = OAuthProvider('apple.com');
    final credential = provider.credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final currentUser = _firebaseAuth.currentUser;
    UserCredential userCredential;

    // 🛡️ THE MAGIC BLOCK: Try to link, fallback to normal login if needed
    try {
      if (currentUser != null && currentUser.isAnonymous) {
        userCredential = await currentUser.linkWithCredential(credential);
      } else {
        userCredential = await _firebaseAuth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      // If the email is already in use by an older account, just log into it!
      if (e.code == 'email-already-in-use' ||
          e.code == 'credential-already-in-use') {
        userCredential = await _firebaseAuth.signInWithCredential(credential);
      } else {
        rethrow;
      }
    }

    return _mapFirebaseUser(userCredential.user!);
  }

  // ===========================================================================
  // EMAIL / PASSWORD
  // ===========================================================================
  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String username,
    String? country,
    String? region,
  }) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final newUser = UserModel(
      id: userCredential.user!.uid,
      email: email,
      userName: username,
      createdAt: DateTime.now(),
      country: country,
      region: region,
      isGuest: false,
    );

    return newUser;
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;
    if (!user.emailVerified) {
      throw FirebaseAuthException(
        code: 'email-not-verified',
        message: 'Account exists but is not verified.',
      );
    }

    return _mapFirebaseUser(user);
  }

  // ===========================================================================
  // COMMON
  // ===========================================================================
  @override
  UserEntity? getCurrentUser() {
    final user = _firebaseAuth.currentUser;
    return user == null ? null : _mapFirebaseUser(user);
  }

  @override
  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _firebaseAuth.signOut();
  }

  UserModel _mapFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      userName: user.displayName ?? 'Guest User',
      photoUrl: user.photoURL,
      isGuest: user.isAnonymous,
      pushTokens: const [],
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
      country: null,
      region: null,
    );
  }

  // ===========================================================================
  // REMAINING METHODS
  // ===========================================================================
  @override
  Future<void> updateAuthProfile({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    if (displayName != null) await user.updateDisplayName(displayName);
    if (photoUrl != null) await user.updatePhotoURL(photoUrl);
    await user.reload();
  }

  @override
  Future<void> reauthenticate({required String password}) async {
    final user = _firebaseAuth.currentUser;
    if (user?.email == null) return;
    final credential = EmailAuthProvider.credential(
      email: user!.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  @override
  Future<void> deleteUser() async {
    await _firebaseAuth.currentUser?.delete();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  @override
  Future<bool> checkEmailVerified() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _firebaseAuth.currentUser?.emailVerified ?? false;
  }

  @override
  Future<String?> getCurrentAuthProvider() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && user.providerData.isNotEmpty) {
      return user.providerData.first.providerId;
    }
    return null;
  }
}
