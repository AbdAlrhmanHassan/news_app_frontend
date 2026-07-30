import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_keys.dart';
import '../../../../core/entities/user_entity.dart';
import '../../../../core/services/notifications_service.dart';
import '../../../../core/services/shared_prefs_service.dart';
import '../../data/repositories/user_repo.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/save_daily_routine_usecase.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepo _userRepo;
  final UpdateProfileUseCase _updateProfileUseCase;
  final SaveDailyRoutineUseCase _saveDailyRoutineUseCase;
  final NotificationsService _notificationsService;

  UserCubit(
    this._userRepo,
    this._updateProfileUseCase,
    this._saveDailyRoutineUseCase,
    this._notificationsService,
  ) : super(UserInitial());

  // ===========================================================================
  // 🔄 LOAD DATA
  // ===========================================================================


 
  // 🚀 RENAMED: Matches the exact call we used in AuthWelcomePage!
  Future<void> getUserData({required String uid}) async {
    emit(UserLoading());
    final result = await _userRepo.getUserData(uid: uid);

    result.fold((failure) => emit(UserError(failure.message)), (user) async {
      log('User data loaded successfully: ${user.email}');
      emit(UserLoaded(user));

      // Automatically setup push notifications on successful load
      await _setupPushNotification(user.id);
    });
  }

  // ===========================================================================
  // 📱 PUSH TOKEN LOGIC (DECOUPLED)
  // ===========================================================================
  Future<void> _setupPushNotification(String uid) async {
    try {
      final String? token = await _notificationsService.getDeviceToken();
      if (token != null) {
        _saveTokenToDb(uid, token);
      }

      _notificationsService.onTokenRefresh.listen((newToken) {
        log("🔄 Push Token refreshed!");
        _saveTokenToDb(uid, newToken);
      });
    } catch (e) {
      log("❌ Error setting up push notifications: $e");
    }
  }

  void _saveTokenToDb(String uid, String token) async {
    await _userRepo.savePushToken(uid: uid, token: token);

    if (state is UserLoaded) {
      final currentUser = (state as UserLoaded).user;

      if (!currentUser.pushTokens.contains(token)) {
        final updatedTokens = List<String>.from(currentUser.pushTokens)
          ..add(token);
        emit(UserLoaded(currentUser.copyWith(pushTokens: updatedTokens)));
      }
    }
  }

  Future<void> removeDeviceToken() async {
    final currentState = state;
    if (currentState is! UserLoaded) return;

    try {
      final String? token = await _notificationsService.getDeviceToken();
      if (token != null) {
        await _userRepo.removePushToken(
          uid: currentState.user.id,
          token: token,
        );
        log("🗑️ Push token removed successfully before logout.");
      }
    } catch (e) {
      log("❌ Failed to remove push token: $e");
    }
  }

  // ===========================================================================
  // 📢 BROADCAST NOTIFICATIONS (TOPICS)
  // ===========================================================================
  Future<void> toggleBroadcastNotifications(bool enable) async {
    const String broadcastTopic = AppKeys.allUsersTopic;

    try {
      if (enable) {
        await _notificationsService.subscribeToTopic(broadcastTopic);
        log("✅ Subscribed to $broadcastTopic");
      } else {
        await _notificationsService.unsubscribeFromTopic(broadcastTopic);
        log("❌ Unsubscribed from $broadcastTopic");
      }

      // 🚀 THE MAGIC: Save the choice locally so the UI remembers it!
      await SharedPrefsService.saveBool('notifications_enabled', enable);
    } catch (e) {
      log("⚠️ Failed to toggle broadcast topic: $e");
    }
  }
  // ===========================================================================
  // 👤 PROFILE & ROUTINE LOGIC (AUDIO NEWS SPECIFIC)
  // ===========================================================================

  UserEntity? get fullUserData {
    if (state is UserLoaded) return (state as UserLoaded).user;
    return null;
  }

  Future<void> updateProfile({
    String? username,
    String? country,
    String? region,
  }) async {
    final currentState = state;
    if (currentState is! UserLoaded) return;

    emit(UserLoading());
    final result = await _updateProfileUseCase.call(
      UpdateProfileParams(
        currentUser: currentState.user,
        username: username,
        country: country,
        region: region,
      ),
    );

    result.fold((failure) {
      emit(UserError(failure.message));
      emit(UserLoaded(currentState.user));
    }, (updatedUser) => emit(UserLoaded(updatedUser)));
  }

  // ===========================================================================
  // 🎵 SAVED ROUTINE LOGIC (WITH OPTIMISTIC UPDATES)
  // ===========================================================================
  Future<void> saveUserRoutine(
    String uid,
    List<String> routineIds, {
    bool useRoutineDaily = true,
  }) async {
    final currentState = state;

    // 1. 🚀 OPTIMISTIC UPDATE: Instantly change the UI so the user doesn't wait!
    if (currentState is UserLoaded) {
      final currentUser = currentState.user;
      emit(UserLoaded(currentUser.copyWith(dailyRoutine: routineIds)));
    }

    // 2. 🌩️ BACKGROUND UPDATE: Send to Firebase quietly
    final result = await _saveDailyRoutineUseCase.call(
      SaveDailyRoutineParams(
        uid: uid,
        categoryIds: routineIds,
        useRoutineDaily: useRoutineDaily,
      ),
    );

    result.fold((failure) {
      log("❌ Failed to save routine: ${failure.message}");
      // Optional: If it fails, you could emit the old state here to revert the UI
    }, (_) => log("✅ Routine successfully saved to Firebase via UseCase!"));
  }

  void clearUserData() => emit(UserInitial());
}
