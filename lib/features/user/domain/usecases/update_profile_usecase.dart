import 'package:dartz/dartz.dart';
import '../../../../core/entities/user_entity.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/repo/auth_repo.dart';
import '../../data/repositories/user_repo.dart';

class UpdateProfileParams {
  final UserEntity currentUser;
  final String? username; // 🚀 Updated for Audio News
  final String? country; // 🚀 Updated for Audio News
  final String? region; // 🚀 Updated for Audio News

  UpdateProfileParams({
    required this.currentUser,
    this.username,
    this.country,
    this.region,
  });
}

class UpdateProfileUseCase {
  final AuthRepo _authRepo;
  final UserRepo _userRepo;

  UpdateProfileUseCase(this._authRepo, this._userRepo);

  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) async {
    // 1. Prepare Firestore Updates
    final Map<String, dynamic> updates = {};
    if (params.username != null) updates['username'] = params.username;
    if (params.country != null) updates['country'] = params.country;
    if (params.region != null) updates['region'] = params.region;

    if (updates.isEmpty) return Right(params.currentUser);
    updates['updatedAt'] = DateTime.now().toIso8601String();

    // 2. UPDATE FIRESTORE (Database)
    final Either<Failure, Unit> result = await _userRepo.updateUserProfile(
      uid: params.currentUser.id,
      data: updates,
    );

    // 3. Handle Firestore result
    return result.fold((failure) => Left(failure), (_) async {
      // 4. UPDATE FIREBASE AUTH (Identity) ONLY if Firestore succeeded
      // Note: Firebase Auth standard profile only holds displayName,
      // so we map your 'username' to it!
      if (params.username != null) {
        await _authRepo.updateAuthProfile(displayName: params.username);
      }

      // 5. Create the newly updated UserEntity
      final updatedUser = params.currentUser.copyWith(
        userName: params.username ?? params.currentUser.userName,
        country: params.country ?? params.currentUser.country,
        region: params.region ?? params.currentUser.region,
      );

      // 6. Return the success result
      return Right(updatedUser);
    });
  }
}
