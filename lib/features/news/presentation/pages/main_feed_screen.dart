import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:http/http.dart' as http;
import 'package:news_app_frontend/features/auth/presentation/pages/auth_welcome_page.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/services/get_it_service.dart';
import '../../../../core/services/audio_handler_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_categories.dart';
import '../../data/models/news_models.dart';
import '../cubit/news_cubit.dart';
import '../cubit/news_state.dart';
import 'daily_setup_screen.dart';

// 🚀 NEW: Import Auth files and your Welcome screen!
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../onboarding/presentation/pages/welcome_screen.dart'; // Update path if needed

class DailyMixPlayerScreen extends StatefulWidget {
  final String languageCode;
  final List<String> orderedCategoryIds;

  const DailyMixPlayerScreen({
    super.key,
    required this.languageCode,
    required this.orderedCategoryIds,
  });

  @override
  State<DailyMixPlayerScreen> createState() => _DailyMixPlayerScreenState();
}

class _DailyMixPlayerScreenState extends State<DailyMixPlayerScreen> {
  bool _isPlaying = false;
  bool _isPreparingAudio = false;

  int _maxDuration = 0;
  double _dragValue = -1.0;

  final PlayerController _playerController = getIt<PlayerController>();
  final MixAudioHandler _audioHandler = getIt<MixAudioHandler>();

  List<NewsModel> _currentMixes = [];
  List<NewsModel> _playedMixes = [];

  @override
  void initState() {
    super.initState();

    context.read<NewsCubit>().fetchNews();

    _playerController.onCompletion.listen((_) {
      _moveToNextTrack();
    });

    _audioHandler.customState.listen((event) async {
      if (event == 'skipNext_triggered') {
        await _playerController.stopPlayer();
        _moveToNextTrack();
      }
    });
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  void _moveToNextTrack() {
    setState(() {
      if (_currentMixes.isNotEmpty) {
        _playedMixes.insert(0, _currentMixes.first);
        _currentMixes.removeAt(0);
      }
    });

    if (_currentMixes.isNotEmpty) {
      _playNewTrack(_currentMixes.first);
    } else {
      setState(() => _isPlaying = false);
    }
  }

  void _requeueTrack(NewsModel item) {
    HapticFeedback.mediumImpact();
    setState(() {
      _playedMixes.remove(item);
      _currentMixes.add(item);

      if (_currentMixes.length == 1 && !_isPlaying) {
        _playNewTrack(_currentMixes.first);
      }
    });
  }

  String _formatDuration(int milliseconds) {
    if (milliseconds < 0) return '00:00';
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _playNewTrack(NewsModel activeMix, {bool autoPlay = true}) {
    final audioUrl =
        activeMix.audioUrl[widget.languageCode] ??
        activeMix.audioUrl['en'] ??
        activeMix.audioUrl.values.firstOrNull ??
        '';

    final title =
        activeMix.title[widget.languageCode] ?? activeMix.title['en'] ?? 'News';

    _audioHandler.updateMetadata(trackTitle: title);
    _loadAndPrepareAudio(audioUrl, autoPlay: autoPlay);
  }

  Future<void> _loadAndPrepareAudio(String url, {bool autoPlay = true}) async {
    if (url.isEmpty) return;

    setState(() {
      _isPreparingAudio = true;
      _maxDuration = 0;
      // Note: We don't set _isPlaying here yet, we wait until it's ready!
    });

    try {
      // 1. Download the file
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/active_track.mp3';
      final file = File(filePath);

      final response = await http.get(Uri.parse(url));
      await file.writeAsBytes(response.bodyBytes);

      // 2. Prepare the player with the downloaded file
      await _playerController.preparePlayer(
        path: file.path,
        shouldExtractWaveform: false,
      );

      final maxDuration = await _playerController.getDuration(DurationType.max);

      // 3. Update the UI state now that it is fully ready
      setState(() {
        _maxDuration = maxDuration;
        _isPreparingAudio = false;
        // 🚀 THE FIX: We only set the UI to "playing" if autoPlay is true
        _isPlaying = autoPlay;
      });

      // 🚀 THE FIX: We only actually start the audio engine if autoPlay is true
      if (autoPlay) {
        await _playerController.startPlayer();
      }
    } catch (e) {
      debugPrint("Failed to download or prepare audio: $e");
      setState(() => _isPreparingAudio = false);
    }
  }

  void _togglePlay() async {
    HapticFeedback.lightImpact();
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      await _playerController.startPlayer();
    } else {
      await _playerController.pausePlayer();
    }
  }

  IconData _getCategoryIcon(String categoryId) {
    return AppCategories.allCategories
        .firstWhere(
          (cat) => cat.id == categoryId,
          orElse: () => AppCategories.allCategories.first,
        )
        .icon;
  }

  void _showTranscriptSheet(
    BuildContext context,
    NewsModel activeMix,
    bool isAr,
  ) {
    HapticFeedback.mediumImpact();

    final String articleTitle =
        activeMix.title[widget.languageCode] ??
        activeMix.title['en'] ??
        'News Update';
    final String articleText =
        activeMix.summaryText[widget.languageCode] ??
        activeMix.summaryText['en'] ??
        "This is where your beautifully formatted news text will go. It uses a high line-height to make reading effortless while the user is commuting or working out. \n\nBy keeping them on this page, the audio never stops, and they can easily swipe this sheet down to return to the media controls.";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Directionality(
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.textGrey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          bottom: 40,
                        ),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          Text(
                            articleTitle,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            articleText,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              height: 1.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 🚀 NEW: Sleek, premium settings menu!
  void _showSettingsSheet(BuildContext context, bool isAr) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(
            top: 12,
            bottom: 40,
            left: 16,
            right: 16,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Directionality(
            textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.textGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 24),

                // Button 1: Edit Routine
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    isAr ? 'تعديل الروتين اليومي' : 'Edit Daily Routine',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Close the sheet
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DailySetupScreen(),
                      ),
                    );
                  },
                ),

                Divider(color: AppColors.textGrey.withOpacity(0.1), height: 32),

                // Button 2: Dynamic Auth Button (Guest aware!)
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    bool isGuest = false;
                    if (state is AuthAuthenticated) {
                      isGuest = state.user.isGuest;
                    }

                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isGuest
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.redAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isGuest
                              ? Icons.person_add_rounded
                              : Icons.logout_rounded,
                          color: isGuest ? AppColors.primary : Colors.redAccent,
                        ),
                      ),
                      title: Text(
                        isGuest
                            ? (isAr
                                  ? 'إنشاء حساب (لحفظ روتينك)'
                                  : 'Create Account (Save Routine)')
                            : (isAr ? 'تسجيل الخروج' : 'Sign Out'),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isGuest ? AppColors.primary : Colors.redAccent,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        Navigator.pop(context); // Close the sheet

                        if (isGuest) {
                          // 🚀 THE FIX: Send them to the Welcome screen to upgrade!
                          // We DO NOT sign them out here, so their guest data is saved.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AuthWelcomePage(),
                            ),
                          );
                        } else {
                          // 🚀 THE FIX: Added the missing () so the function actually runs!
                          context.read<AuthCubit>().signOut();
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonBlock({
    double? width,
    double? height,
    BoxShape shape = BoxShape.rectangle,
    double borderRadius = 8,
    Color? color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? AppColors.textGrey.withOpacity(0.1),
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(borderRadius)
            : null,
      ),
    );
  }

  Widget _buildSkeletonUI(bool isAr) {
    final Color cardSkeletonColor = Colors.white.withOpacity(0.2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSkeletonBlock(width: 110, height: 16),
                const SizedBox(height: 2),
                _buildSkeletonBlock(width: 190, height: 48),
              ],
            ),
            _buildSkeletonBlock(width: 32, height: 32, shape: BoxShape.circle),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(top: 0, bottom: 40),
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        _buildSkeletonBlock(
                          width: 96,
                          height: 96,
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                        ),
                        const SizedBox(height: 24),
                        _buildSkeletonBlock(
                          width: 220,
                          height: 24,
                          color: cardSkeletonColor,
                        ),
                        const SizedBox(height: 6),
                        _buildSkeletonBlock(
                          width: 160,
                          height: 24,
                          color: cardSkeletonColor,
                        ),
                        const SizedBox(height: 14),
                        _buildSkeletonBlock(
                          width: 140,
                          height: 14,
                          color: cardSkeletonColor,
                        ),
                        const SizedBox(height: 32),
                        Column(
                          children: [
                            _buildSkeletonBlock(
                              width: double.infinity,
                              height: 4,
                              color: cardSkeletonColor,
                            ),
                            const SizedBox(height: 14),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildSkeletonBlock(
                                    width: 35,
                                    height: 12,
                                    color: cardSkeletonColor,
                                  ),
                                  _buildSkeletonBlock(
                                    width: 35,
                                    height: 12,
                                    color: cardSkeletonColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildSkeletonBlock(
                              width: 32,
                              height: 32,
                              shape: BoxShape.circle,
                              color: cardSkeletonColor,
                            ),
                            _buildSkeletonBlock(
                              width: 72,
                              height: 72,
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.4),
                            ),
                            _buildSkeletonBlock(
                              width: 32,
                              height: 32,
                              shape: BoxShape.circle,
                              color: cardSkeletonColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: isAr ? null : 0,
                      left: isAr ? 0 : null,
                      child: _buildSkeletonBlock(
                        width: 36,
                        height: 36,
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSkeletonBlock(width: 90, height: 18),
              const SizedBox(height: 12),
              ...List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.textGrey.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          right: isAr ? 0 : 16.0,
                          left: isAr ? 16.0 : 0,
                        ),
                        child: _buildSkeletonBlock(width: 20, height: 20),
                      ),
                      _buildSkeletonBlock(
                        width: 40,
                        height: 40,
                        shape: BoxShape.circle,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSkeletonBlock(width: 160, height: 16),
                            const SizedBox(height: 6),
                            _buildSkeletonBlock(width: 65, height: 13),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = widget.languageCode == 'ar';
    final int currentHour = DateTime.now().hour;
    String timeGreeting;
    if (currentHour >= 0 && currentHour < 12) {
      timeGreeting = isAr ? 'صباح الخير' : 'Good Morning';
    } else if (currentHour >= 12 && currentHour < 17) {
      timeGreeting = isAr ? 'طاب مساؤك' : 'Good Afternoon';
    } else {
      timeGreeting = isAr ? 'مساء الخير' : 'Good Evening';
    }

    final String headerTitle = isAr ? 'مزيجك اليومي' : 'Your Daily Mix';
    final String emptyStateText = isAr
        ? 'لا توجد أخبار متاحة اليوم.'
        : 'No news available today.';
    final String downloadingText = isAr
        ? 'جاري التحميل...'
        : 'Loading audio...';
    final String queueTitle = isAr ? 'التالي في القائمة' : 'Up Next';
    final String historyTitle = isAr ? 'تم الاستماع مؤخراً' : 'Recently Played';
    final String minTag = isAr ? '~٣ دقائق' : '~3 mins';

    return Scaffold(
      backgroundColor: Colors.white,

      // 🚀 NEW: Safely handles what happens when they click Sign Out
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            // Instantly stop audio to prevent it from continuing in the background
            _playerController.stopPlayer();

            // Route them back to the Welcome Screen!
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const WelcomeScreen()),
              (route) => false,
            );
          }
        },
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -80,
              child: Icon(
                Icons.graphic_eq_rounded,
                size: 350,
                color: AppColors.primary.withOpacity(0.07),
              ),
            ),
            SafeArea(
              child: Directionality(
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: BlocConsumer<NewsCubit, NewsState>(
                    listener: (context, state) {
                      if (state is NewsLoaded) {
                        setState(() {
                          _currentMixes = [];
                          _playedMixes = [];
                          for (var id in widget.orderedCategoryIds) {
                            final mix = state.mixes
                                .where((m) => m.categoryId == id)
                                .firstOrNull;
                            if (mix != null) _currentMixes.add(mix);
                          }
                        });
                        if (_currentMixes.isNotEmpty) {
                          _playNewTrack(_currentMixes[0], autoPlay: false);
                        }
                      }
                    },
                    builder: (context, state) {
                      if (state is NewsLoading || state is NewsInitial) {
                        return _buildSkeletonUI(isAr);
                      }

                      if (state is NewsError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        );
                      }

                      if (_currentMixes.isEmpty && _playedMixes.isEmpty) {
                        return Center(
                          child: Text(
                            emptyStateText,
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      final activeMix = _currentMixes.isNotEmpty
                          ? _currentMixes[0]
                          : null;
                      final queueMixes = _currentMixes.length > 1
                          ? _currentMixes.sublist(1)
                          : [];
                      final int totalTracks =
                          _currentMixes.length + _playedMixes.length;
                      final int currentTrackIndex = _playedMixes.length + 1;

                      final String trackCounter = isAr
                          ? 'المقطع $currentTrackIndex من $totalTracks • $minTag'
                          : 'Track $currentTrackIndex of $totalTracks • $minTag';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    timeGreeting,
                                    style: const TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    headerTitle,
                                    style: const TextStyle(
                                      color: AppColors.textDark,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.settings_outlined,
                                  color: AppColors.textDark,
                                ),
                                // 🚀 NEW: Opens our premium Settings Menu!
                                onPressed: () =>
                                    _showSettingsSheet(context, isAr),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Expanded(
                            child: Theme(
                              data: Theme.of(
                                context,
                              ).copyWith(canvasColor: Colors.transparent),
                              child: ReorderableListView.builder(
                                padding: const EdgeInsets.only(
                                  top: 0,
                                  bottom: 40,
                                ),
                                physics: const BouncingScrollPhysics(),
                                header: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (activeMix != null) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 32,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppColors.primary,
                                              AppColors.primary.withOpacity(
                                                0.85,
                                              ),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            32,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withOpacity(0.12),
                                              blurRadius: 24,
                                              offset: const Offset(0, 12),
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          children: [
                                            Column(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    24,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.15),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    _getCategoryIcon(
                                                      activeMix.categoryId,
                                                    ),
                                                    color: Colors.white,
                                                    size: 48,
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                Text(
                                                  activeMix.title[widget
                                                          .languageCode] ??
                                                      activeMix.title['en'] ??
                                                      'News Update',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w800,
                                                    height: 1.2,
                                                    letterSpacing: -0.5,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  trackCounter,
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(0.8),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 32),

                                                _isPreparingAudio
                                                    ? SizedBox(
                                                        height: 60,
                                                        child: Center(
                                                          child: Text(
                                                            downloadingText,
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                    0.8,
                                                                  ),
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : StreamBuilder<int>(
                                                        stream: _playerController
                                                            .onCurrentDurationChanged,
                                                        builder: (context, snapshot) {
                                                          final current =
                                                              snapshot.data ??
                                                              0;
                                                          final progress =
                                                              _maxDuration > 0
                                                              ? (current /
                                                                        _maxDuration)
                                                                    .clamp(
                                                                      0.0,
                                                                      1.0,
                                                                    )
                                                              : 0.0;

                                                          final displayProgress =
                                                              _dragValue >= 0
                                                              ? _dragValue
                                                              : progress;
                                                          final displayTime =
                                                              _dragValue >= 0
                                                              ? (_dragValue *
                                                                        _maxDuration)
                                                                    .toInt()
                                                              : current;
                                                          final timeRemaining =
                                                              _maxDuration -
                                                              displayTime;

                                                          return Column(
                                                            children: [
                                                              SliderTheme(
                                                                data: SliderTheme.of(context).copyWith(
                                                                  activeTrackColor:
                                                                      Colors
                                                                          .white,
                                                                  inactiveTrackColor:
                                                                      Colors
                                                                          .white
                                                                          .withOpacity(
                                                                            0.3,
                                                                          ),
                                                                  thumbColor:
                                                                      Colors
                                                                          .white,
                                                                  trackHeight:
                                                                      4.0,
                                                                  trackShape:
                                                                      const RoundedRectSliderTrackShape(),
                                                                  overlayColor:
                                                                      Colors
                                                                          .white
                                                                          .withOpacity(
                                                                            0.1,
                                                                          ),
                                                                  thumbShape:
                                                                      const RoundSliderThumbShape(
                                                                        enabledThumbRadius:
                                                                            6.0,
                                                                      ),
                                                                  overlayShape:
                                                                      const RoundSliderOverlayShape(
                                                                        overlayRadius:
                                                                            16.0,
                                                                      ),
                                                                ),
                                                                child: Slider(
                                                                  value:
                                                                      displayProgress,
                                                                  onChangeStart:
                                                                      (
                                                                        value,
                                                                      ) => setState(
                                                                        () => _dragValue =
                                                                            value,
                                                                      ),
                                                                  onChanged:
                                                                      (
                                                                        value,
                                                                      ) => setState(
                                                                        () => _dragValue =
                                                                            value,
                                                                      ),
                                                                  onChangeEnd: (value) async {
                                                                    final seekPosition =
                                                                        (value *
                                                                                _maxDuration)
                                                                            .toInt();
                                                                    await _playerController
                                                                        .seekTo(
                                                                          seekPosition,
                                                                        );
                                                                    setState(
                                                                      () => _dragValue =
                                                                          -1.0,
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          18.0,
                                                                    ),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      _formatDuration(
                                                                        displayTime,
                                                                      ),
                                                                      style: TextStyle(
                                                                        color: Colors
                                                                            .white
                                                                            .withOpacity(
                                                                              0.7,
                                                                            ),
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontFeatures:
                                                                            const [
                                                                              FontFeature.tabularFigures(),
                                                                            ],
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      '-${_formatDuration(timeRemaining > 0 ? timeRemaining : 0)}',
                                                                      style: TextStyle(
                                                                        color: Colors
                                                                            .white
                                                                            .withOpacity(
                                                                              0.7,
                                                                            ),
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        fontFeatures:
                                                                            const [
                                                                              FontFeature.tabularFigures(),
                                                                            ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                const SizedBox(height: 24),

                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(
                                                        isAr
                                                            ? Icons
                                                                  .forward_10_rounded
                                                            : Icons
                                                                  .replay_10_rounded,
                                                        color: Colors.white
                                                            .withOpacity(0.9),
                                                        size: 32,
                                                      ),
                                                      onPressed: () {
                                                        HapticFeedback.lightImpact();
                                                        _playerController
                                                            .seekTo(0);
                                                      },
                                                    ),
                                                    _isPreparingAudio
                                                        ? SizedBox(
                                                            height: 62,
                                                            width: 62,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    20.0,
                                                                  ),
                                                              child: CircularProgressIndicator(
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                      0.8,
                                                                    ),
                                                                strokeWidth: 3,
                                                              ),
                                                            ),
                                                          )
                                                        : GestureDetector(
                                                            onTap: _togglePlay,
                                                            child: Container(
                                                              height: 72,
                                                              width: 72,
                                                              decoration: BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                shape: BoxShape
                                                                    .circle,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                          0.15,
                                                                        ),
                                                                    blurRadius:
                                                                        16,
                                                                    offset:
                                                                        const Offset(
                                                                          0,
                                                                          8,
                                                                        ),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: Icon(
                                                                _isPlaying
                                                                    ? Icons
                                                                          .pause_rounded
                                                                    : Icons
                                                                          .play_arrow_rounded,
                                                                color: AppColors
                                                                    .primary,
                                                                size: 40,
                                                              ),
                                                            ),
                                                          ),
                                                    IconButton(
                                                      icon: Icon(
                                                        isAr
                                                            ? Icons
                                                                  .skip_previous_rounded
                                                            : Icons
                                                                  .skip_next_rounded,
                                                        color: Colors.white,
                                                        size: 32,
                                                      ),
                                                      onPressed: () async {
                                                        HapticFeedback.mediumImpact();
                                                        await _playerController
                                                            .stopPlayer();
                                                        _moveToNextTrack();
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: isAr ? null : 0,
                                              left: isAr ? 0 : null,
                                              child: GestureDetector(
                                                onTap: () =>
                                                    _showTranscriptSheet(
                                                      context,
                                                      activeMix,
                                                      isAr,
                                                    ),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.15),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.notes_rounded,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                    ],

                                    if (queueMixes.isNotEmpty) ...[
                                      Text(
                                        queueTitle,
                                        style: const TextStyle(
                                          color: AppColors.textDark,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ],
                                ),
                                footer: _playedMixes.isEmpty
                                    ? null
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 16),
                                          Text(
                                            historyTitle,
                                            style: const TextStyle(
                                              color: AppColors.textGrey,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          ..._playedMixes.map(
                                            (playedItem) => _buildPlayedCard(
                                              playedItem.title[widget
                                                      .languageCode] ??
                                                  playedItem.title['en'] ??
                                                  'News Block',
                                              _getCategoryIcon(
                                                playedItem.categoryId,
                                              ),
                                              isAr,
                                              () => _requeueTrack(playedItem),
                                            ),
                                          ),
                                        ],
                                      ),
                                itemCount: queueMixes.length,
                                onReorder: (oldIndex, newIndex) {
                                  HapticFeedback.lightImpact();
                                  setState(() {
                                    if (newIndex > oldIndex) newIndex -= 1;
                                    final item = _currentMixes.removeAt(
                                      oldIndex + 1,
                                    );
                                    _currentMixes.insert(newIndex + 1, item);
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final queueItem = queueMixes[index];
                                  return Container(
                                    key: ValueKey(queueItem.id),
                                    child: _buildQueueCard(
                                      queueItem.title[widget.languageCode] ??
                                          queueItem.title['en'] ??
                                          'News Block',
                                      minTag,
                                      _getCategoryIcon(queueItem.categoryId),
                                      index,
                                      isAr,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueCard(
    String title,
    String duration,
    IconData icon,
    int index,
    bool isAr,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textGrey.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: EdgeInsets.only(
                right: isAr ? 0 : 16.0,
                left: isAr ? 16.0 : 0,
              ),
              child: Icon(
                Icons.drag_indicator,
                color: AppColors.textGrey.withOpacity(0.4),
                size: 20,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayedCard(
    String title,
    IconData icon,
    bool isAr,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: 0.6,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.textGrey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.textGrey.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  right: isAr ? 0 : 16.0,
                  left: isAr ? 16.0 : 0,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.textGrey.withOpacity(0.6),
                  size: 20,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.textGrey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.textGrey, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAr
                          ? 'اضغط للإضافة للقائمة مجدداً'
                          : 'Tap to add to list again',
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
