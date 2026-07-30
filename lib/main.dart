import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_links/app_links.dart';
import 'package:news_app_frontend/core/services/bloc_observer_service.dart';
import 'package:news_app_frontend/core/services/shared_prefs_service.dart';

import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/news/presentation/cubit/news_cubit.dart';
import 'features/news/presentation/pages/main_feed_screen.dart';
import 'features/user/presentation/cubit/user_cubit.dart';

import 'firebase_options.dart';
import 'features/onboarding/presentation/pages/welcome_screen.dart';
import 'core/services/get_it_service.dart';

import 'features/news/presentation/pages/daily_setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SharedPrefsService.init();

  await setupGetit();
  Bloc.observer = BlocObserverService();
  runApp(const AudioNewsApp());
}

class AudioNewsApp extends StatefulWidget {
  const AudioNewsApp({super.key});

  @override
  State<AudioNewsApp> createState() => _AudioNewsAppState();
}

class _AudioNewsAppState extends State<AudioNewsApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      debugPrint("Failed to get initial deep link: $e");
    }

    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        debugPrint("Deep link error: $err");
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'newsapp' && uri.host == 'play') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = _navigatorKey.currentContext;
        if (context == null) return;

        final currentUser = context.read<AuthCubit>().getCurrentUser();

        if (currentUser == null) {
          debugPrint('🔒 User is NULL. Redirecting to Auth Welcome Page.');
          _navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            (route) => false,
          );
        } else {
          debugPrint('▶️ User Authenticated. Launching Splash Router.');

          // 🚀 THE FIX: Push the new animated Splash Screen instead of a basic loading spinner!
          _navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => SplashRouterScreen(userId: currentUser.id),
            ),
            (route) => false,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NewsCubit>(create: (_) => getIt<NewsCubit>()),
        BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
        BlocProvider<UserCubit>(create: (_) => getIt<UserCubit>()),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Audio News App',
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFF0F0F13),
          brightness: Brightness.dark,
        ),
        home: Builder(
          builder: (context) {
            final user = context.read<AuthCubit>().getCurrentUser();
            final bool isFirstOpen =
                SharedPrefsService.getBool('is_first_open') ?? true;

            if (user != null) {
              // 🚀 Standard App Launch -> Opens the Splash Router
              return SplashRouterScreen(userId: user.id);
            } else if (!isFirstOpen) {
              return const DailySetupScreen();
            } else {
              return const WelcomeScreen();
            }
          },
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 🚀 NEW: Animated Splash Screen & Background Router
// -----------------------------------------------------------------------------
class SplashRouterScreen extends StatefulWidget {
  final String userId;

  const SplashRouterScreen({super.key, required this.userId});

  @override
  State<SplashRouterScreen> createState() => _SplashRouterScreenState();
}

class _SplashRouterScreenState extends State<SplashRouterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Setup the beautiful "breathing" animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 2. Fire the fetch instantly when the animation starts
    context.read<UserCubit>().getUserData(uid: widget.userId);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, // Keeps the transition to the player seamless
      body: BlocListener<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserLoaded) {
            if (state.user.dailyRoutine.isNotEmpty) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  // 🚀 UX FIX: A smooth fade transition into the player screen!
                  transitionDuration: const Duration(milliseconds: 600),
                  pageBuilder: (_, __, ___) => DailyMixPlayerScreen(
                    languageCode: 'en',
                    orderedCategoryIds: List<String>.from(
                      state.user.dailyRoutine,
                    ),
                  ),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const DailySetupScreen(),
                ),
              );
            }
          } else if (state is UserError) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DailySetupScreen()),
            );
          }
        },
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF95271D).withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.graphic_eq_rounded,
                      color: Color(0xFF95271D), // Your primary color
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "DAILY MIX",
                    style: TextStyle(
                      color: Color(0xFF95271D),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
