import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/entities/user_entity.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/database_service.dart';
import '../../data/repositories/user_repo.dart';

class UserRepoImpl implements UserRepo {
  final DatabaseService _databaseService;

  UserRepoImpl(this._databaseService);

  // ===========================================================================
  // 🚀 GET USER DATA
  // ===========================================================================
  @override
  Future<Either<Failure, UserEntity>> getUserData({required String uid}) async {
    try {
      // Note: Make sure your DatabaseService has a 'getDocument' method!
      final data = await _databaseService.getDocument(
        path: 'users',
        documentId: uid,
      );

      if (data == null || data.isEmpty) {
        return const Left(ServerFailure(message: 'User data not found.'));
      }

      log('User model fetched successfully: $data');
      final userModel = UserModel.fromMap(data);
      return Right(userModel);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ===========================================================================
  // 👤 UPDATE PROFILE
  // ===========================================================================
  @override
  Future<Either<Failure, Unit>> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Protect sensitive fields from being accidentally overwritten
      if (data.containsKey('uid') ||
          data.containsKey('email') ||
          data.containsKey('isGuest')) {
        return const Left(
          ServerFailure(
            message: "Cannot update restricted fields (uid, email, isGuest).",
          ),
        );
      }

      await _databaseService.updateData(
        path: 'users',
        documentId: uid,
        data: data,
      );

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ===========================================================================
  // 🎧 SAVE DAILY ROUTINE (NEW FOR AUDIO NEWS)
  // ===========================================================================
  @override
  Future<Either<Failure, Unit>> saveDailyRoutine({
    required String uid,
    required List<String> categoryIds,
    required bool useRoutineDaily,
  }) async {
    try {
      await _databaseService.updateData(
        path: 'users',
        documentId: uid,
        data: {'dailyRoutine': categoryIds, 'useRoutineDaily': useRoutineDaily},
      );
      log('✅ Daily routine saved for user: $uid');
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ===========================================================================
  // 📱 SAVE PUSH TOKEN
  // ===========================================================================
  @override
  Future<Either<Failure, Unit>> savePushToken({
    required String uid,
    required String token,
  }) async {
    try {
      await _databaseService.updateData(
        path: 'users',
        documentId: uid,
        data: {
          'pushTokens': FieldValue.arrayUnion([token]),
        },
      );
      log('✅ Push token saved: $token');
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ===========================================================================
  // 🗑️ REMOVE PUSH TOKEN
  // ===========================================================================
  @override
  Future<Either<Failure, Unit>> removePushToken({
    required String uid,
    required String token,
  }) async {
    try {
      await _databaseService.updateData(
        path: 'users',
        documentId: uid,
        data: {
          'pushTokens': FieldValue.arrayRemove([token]),
        },
      );
      log('🗑️ Push token removed: $token');
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
