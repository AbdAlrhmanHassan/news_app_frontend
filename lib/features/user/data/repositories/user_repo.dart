import 'package:dartz/dartz.dart';
import '../../../../core/entities/user_entity.dart';
import '../../../../core/errors/failures.dart';

abstract class UserRepo {
  /// Fetches the complete user profile from Firestore
  Future<Either<Failure, UserEntity>> getUserData({required String uid});

  /// Updates general profile fields like displayName, country, etc.
  Future<Either<Failure, Unit>> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  });

  /// 🚀 NEW: Saves the user's preferred daily news routine
  Future<Either<Failure, Unit>> saveDailyRoutine({
    required String uid,
    required List<String> categoryIds,
    required bool useRoutineDaily,
  });

  /// Saves FCM token for push notifications
  Future<Either<Failure, Unit>> savePushToken({
    required String uid,
    required String token,
  });

  /// Removes FCM token on logout to prevent ghost notifications
  Future<Either<Failure, Unit>> removePushToken({
    required String uid,
    required String token,
  });
}
