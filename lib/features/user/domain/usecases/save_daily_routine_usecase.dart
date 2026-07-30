import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/repositories/user_repo.dart';

class SaveDailyRoutineParams {
  final String uid;
  final List<String> categoryIds;
  final bool useRoutineDaily;

  SaveDailyRoutineParams({
    required this.uid,
    required this.categoryIds,
    required this.useRoutineDaily,
  });
}

class SaveDailyRoutineUseCase {
  final UserRepo _userRepo;

  SaveDailyRoutineUseCase(this._userRepo);

  Future<Either<Failure, Unit>> call(SaveDailyRoutineParams params) async {
    return await _userRepo.saveDailyRoutine(
      uid: params.uid,
      categoryIds: params.categoryIds,
      useRoutineDaily: params.useRoutineDaily,
    );
  }
}
