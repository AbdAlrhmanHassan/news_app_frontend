import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/entities/user_entity.dart';

abstract class AuthRepo {
  // 🚀 NEW: Guest Login
  Future<Either<Failure, UserEntity>> signInAnonymously();

  Future<Either<Failure, UserEntity>> loginWithGoogle();
  Future<Either<Failure, UserEntity>> loginWithApple();
  Future<Either<Failure, UserEntity>> loginWithEmail(
    String email,
    String password,
  );
  Future<Either<Failure, UserEntity>> registerWithEmail(
    String email,
    String password,
    String username,
    String? country, // 🚀 NEW
    String? region, // 🚀 NEW
  );

  Future<Either<Failure, void>> signOut();
  UserEntity? getCurrentUser();

  Future<Either<Failure, void>> deleteAccountSocial();
  Future<Either<Failure, void>> deleteAccount({String? password});

  Future<Either<Failure, void>> resendVerificationEmail();
  Future<Either<Failure, bool>> checkVerificationStatus();
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  Future<Either<Failure, void>> updateAuthProfile({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
  });
}
