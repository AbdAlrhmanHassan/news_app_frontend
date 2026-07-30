import 'package:audio_service/audio_service.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';

import 'package:news_app_frontend/core/services/auth_service.dart';
import 'package:news_app_frontend/core/services/firebase_auth_service.dart';
import 'package:news_app_frontend/core/services/audio_handler_service.dart';
import 'package:news_app_frontend/core/services/firebase_database_service.dart';
import 'package:news_app_frontend/core/services/notifications_service.dart';

import 'package:news_app_frontend/features/auth/domain/repo/auth_repo.dart';
import 'package:news_app_frontend/features/auth/data/repo/auth_repo_impl.dart';
import 'package:news_app_frontend/features/auth/presentation/cubit/auth_cubit.dart';

import 'package:news_app_frontend/features/news/domain/repositories/news_repo.dart';
import 'package:news_app_frontend/features/news/data/repositories/news_repo_impl.dart';
import 'package:news_app_frontend/features/news/presentation/cubit/news_cubit.dart';

import 'package:news_app_frontend/features/user/domain/usecases/update_profile_usecase.dart';
import 'package:news_app_frontend/features/user/domain/usecases/save_daily_routine_usecase.dart';
import 'package:news_app_frontend/features/user/presentation/cubit/user_cubit.dart';

import '../../features/user/data/repositories/user_repo.dart';
import '../../features/user/domain/repositories/user_repo_impl.dart';
import 'database_service.dart';
import 'firebase_notifications_service.dart';

final getIt = GetIt.instance;

Future<void> setupGetit() async {
  // ===========================================================================
  // 🔗 FIREBASE INSTANCES
  // ===========================================================================
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // ===========================================================================
  // 🛠️ SERVICES
  // ===========================================================================
  getIt.registerLazySingleton<DatabaseService>(
    () => FirebaseDatabaseService(firestore: getIt<FirebaseFirestore>()),
  );

  getIt.registerLazySingleton<AuthService>(
    () => FirebaseAuthService(firebaseAuth: getIt<FirebaseAuth>()),
  );

  getIt.registerLazySingleton<NotificationsService>(
    () => FirebaseNotificationsService(),
  );

  // ===========================================================================
  // 📦 REPOSITORIES
  // ===========================================================================
  getIt.registerLazySingleton<NewsRepo>(
    () => NewsRepoImpl(databaseService: getIt<DatabaseService>()),
  );

  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(
      getIt<AuthService>(),
      getIt<DatabaseService>(),
      getIt<NotificationsService>(),
    ),
  );

  getIt.registerLazySingleton<UserRepo>(
    () => UserRepoImpl(getIt<DatabaseService>()),
  );

  // ===========================================================================
  // ⚙️ USE CASES
  // ===========================================================================
  getIt.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(getIt<AuthRepo>(), getIt<UserRepo>()),
  );

  getIt.registerLazySingleton<SaveDailyRoutineUseCase>(
    () => SaveDailyRoutineUseCase(getIt<UserRepo>()),
  );

  // ===========================================================================
  // 🧠 STATE MANAGEMENT (CUBITS / BLOCS)
  // ===========================================================================
  getIt.registerFactory<NewsCubit>(
    () => NewsCubit(repository: getIt<NewsRepo>()),
  );

  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepo>()));

  getIt.registerFactory<UserCubit>(
    () => UserCubit(
      getIt<UserRepo>(),
      getIt<UpdateProfileUseCase>(),
      getIt<SaveDailyRoutineUseCase>(),
      getIt<NotificationsService>(),
    ),
  );

  // ===========================================================================
  // 🎵 AUDIO SETUP
  // ===========================================================================
  getIt.registerLazySingleton<PlayerController>(() => PlayerController());

  final audioHandler = await AudioService.init(
    builder: () => MixAudioHandler(getIt<PlayerController>()),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.yourname.audionews.audio',
      androidNotificationChannelName: 'Audio Playback',
      androidNotificationOngoing: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
    ),
  );

  getIt.registerSingleton<MixAudioHandler>(audioHandler);
}
