import 'dart:developer';
import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_keys.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/entities/user_entity.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/database_service.dart';
import '../../../../core/services/notifications_service.dart'; // 🚀 NEW: Import Notifications Service
import '../../domain/repo/auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  final AuthService _authService;
  final DatabaseService _databaseService;
  final NotificationsService
  _notificationsService; // 🚀 NEW: Inject the service

  // 🚀 NEW: Added to constructor
  AuthRepoImpl(
    this._authService,
    this._databaseService,
    this._notificationsService,
  );

  @override
  Future<Either<Failure, UserEntity>> signInAnonymously() async {
    try {
      final userModel = await _authService.signInAnonymously();
      await _saveUserData(userModel);
      return Right(userModel);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithGoogle() async {
    try {
      final userModel = await _authService.signInWithGoogle();
      await _saveUserData(userModel);
      return Right(userModel);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithApple() async {
    try {
      final userModel = await _authService.signInWithApple();
      await _saveUserData(userModel);
      return Right(userModel);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithEmail(
    String email,
    String password,
  ) async {
    try {
      final userModel = await _authService.login(
        email: email,
        password: password,
      );
      await _saveUserData(userModel);
      return Right(userModel);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerWithEmail(
    String email,
    String password,
    String username,
    String? country,
    String? region,
  ) async {
    try {
      final user = await _authService.register(
        email: email,
        password: password,
        username: username,
        country: country,
        region: region,
      );

      // 🚀 Fix: Grab token for email registration too!
      final String? fcmToken = await _notificationsService.getDeviceToken();
      final List<String> initialTokens = fcmToken != null ? [fcmToken] : [];

      final userModel = user as UserModel;
      final Map<String, dynamic> userData = userModel.toMap();
      userData['pushTokens'] = initialTokens; // Inject token before saving

      await _databaseService.addData(
        path: 'users',
        documentId: user.id,
        data: userData,
      );

      await _authService.sendEmailVerification();
      return Right(user);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _authService.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  UserEntity? getCurrentUser() {
    return _authService.getCurrentUser();
  }

  @override
  Future<Either<Failure, void>> deleteAccountSocial() async {
    try {
      final originalUser = _authService.getCurrentUser();

      if (originalUser == null) {
        return const Left(AuthFailure(message: "No user found."));
      }

      final String originalEmail = originalUser.email;
      final providerId = await _authService.getCurrentAuthProvider();

      if (providerId == 'google.com') {
        await _authService.signInWithGoogle();
      } else if (providerId == 'apple.com') {
        await _authService.signInWithApple();
      } else {
        return const Left(AuthFailure(message: "Unknown login provider."));
      }

      final newUser = _authService.getCurrentUser();
      if (newUser == null || newUser.email != originalEmail) {
        return const Left(
          AuthFailure(message: "Verification failed: Wrong account selected."),
        );
      }

      // Note: Assuming AppCollections.users exists in your constants
      await _databaseService.deleteData(
        path: 'users',
        documentId: originalUser.id,
      );

      await _authService.deleteUser();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount({String? password}) async {
    try {
      final currentUser = _authService.getCurrentUser();

      if (currentUser != null) {
        if (password != null) {
          await _authService.reauthenticate(password: password);
        }

        await _databaseService.deleteData(
          path: 'users',
          documentId: currentUser.id,
        );

        await _authService.deleteUser();
      }
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _saveUserData(UserEntity user) async {
    try {
      final String uid = user.id;
      final String path = 'users';

      // 🚀 THE MAGIC: Fetch the token right here before we do anything!
      final String? fcmToken = await _notificationsService.getDeviceToken();
      final List<String> initialTokens = fcmToken != null ? [fcmToken] : [];

      final bool exists = await _databaseService.checkIfExists(
        path: path,
        documentId: uid,
      );

      if (exists) {
        await _databaseService.updateData(
          path: path,
          documentId: uid,
          data: {
            AppKeys.userLastLogin: DateTime.now().toIso8601String(),
            AppKeys.userIsGuest: user.isGuest,
            AppKeys.userEmail: user.email,
            AppKeys.userName: user.userName,
          },
        );
        log("✅ Existing user/guest updated: $uid | isGuest: ${user.isGuest}");
        // (Note: The UserCubit handles adding new tokens for existing users!)
      } else {
        final newUserModel = UserModel(
          id: uid,
          email: user.email,
          userName: user.userName,
          photoUrl: user.photoUrl,
          pushTokens: initialTokens, // 🚀 Saved instantly on creation!
          isGuest: user.isGuest,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        final Map<String, dynamic> userData = newUserModel.toMap();

        await _databaseService.addData(
          path: path,
          data: userData,
          documentId: uid,
        );
        log("🎉 New user saved to Firestore: $uid | Token included!");
      }
    } catch (e) {
      log("⚠️ Error in _saveUserData: $e");
    }
  }

  @override
  Future<Either<Failure, void>> resendVerificationEmail() async {
    try {
      await _authService.sendEmailVerification();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkVerificationStatus() async {
    try {
      final isVerified = await _authService.checkEmailVerified();
      return Right(isVerified);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAuthProfile({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
  }) async {
    try {
      await _authService.updateAuthProfile(
        displayName: displayName,
        photoUrl: photoUrl,
        phoneNumber: phoneNumber,
      );
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }
}
