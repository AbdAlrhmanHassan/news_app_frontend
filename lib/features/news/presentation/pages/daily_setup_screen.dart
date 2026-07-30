import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';  

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_categories.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import 'main_feed_screen.dart'; // Ensure this points to DailyMixPlayerScreen

class DailySetupScreen extends StatefulWidget {
  const DailySetupScreen({super.key});

  @override
  State<DailySetupScreen> createState() => _DailySetupScreenState();
}

class _DailySetupScreenState extends State<DailySetupScreen> {
  final String _selectedLanguage = 'en';

  // State variables
  late List<NewsCategory> _activeCategories;
  bool _useRoutineDaily = true;

  @override
  void initState() {
    super.initState();
    // Default to 5 categories (15 minutes) as seen in your screenshot!
    _activeCategories = AppCategories.allCategories.take(5).toList();
  }

  int get _selectedMinutes => _activeCategories.length * 3;
  int get _maxMinutes => AppCategories.allCategories.length * 3;

  // --- LOGIC HELPERS ---

  void _updateCategoriesFromSlider(double value) {
    HapticFeedback.selectionClick();
    final targetCount = value.toInt() ~/ 3;
    final currentCount = _activeCategories.length;

    setState(() {
      if (targetCount > currentCount) {
        final available = AppCategories.allCategories
            .where((c) => !_activeCategories.contains(c))
            .toList();
        _activeCategories.addAll(available.take(targetCount - currentCount));
      } else if (targetCount < currentCount) {
        _activeCategories.removeRange(targetCount, currentCount);
      }
    });
  }

  void _removeCategory(int index) {
    HapticFeedback.mediumImpact();
    setState(() {
      _activeCategories.removeAt(index);
    });
  }

  void _toggleDailyRoutine() {
    HapticFeedback.lightImpact();
    setState(() {
      _useRoutineDaily = !_useRoutineDaily;
    });

    if (!_useRoutineDaily) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedLanguage == 'ar'
                ? 'حسناً، سنسألك مجدداً غداً!'
                : "Got it, we'll ask you again tomorrow!",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.textDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _translateCategory(String englishTitle) {
    if (_selectedLanguage == 'en') return englishTitle;
    switch (englishTitle) {
      case 'Top News':
        return 'أهم الأخبار';
      case 'World Politics':
        return 'السياسة العالمية';
      case 'Sports':
        return 'الرياضة';
      case 'Business':
        return 'الأعمال';
      case 'Weather':
        return 'الطقس';
      case 'Tech':
        return 'التكنولوجيا';
      case 'Technology':
        return 'التكنولوجيا';
      case 'Health':
        return 'الصحة';
      case 'Entertainment':
        return 'الترفيه';
      default:
        return englishTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = _selectedLanguage == 'ar';

    final String headerTitle = isAr
        ? 'كم من الوقت لديك؟'
        : 'How much time\ndo you have?';
    final String subText = isAr
        ? 'سنقوم بإعداد المزيج المثالي لك.'
        : 'We’ll build the perfect mix for you.';
    final String btnText = isAr ? 'تشغيل الأخبار' : 'Play My News';
    final String routineText = isAr
        ? 'استخدم هذا الترتيب يومياً'
        : 'Use this routine daily';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -60,
              child: Icon(
                Icons.schedule_rounded,
                size: 350,
                color: AppColors.primary.withOpacity(0.04),
              ),
            ),
            SafeArea(
              child: Directionality(
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      Text(
                        headerTitle,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subText,
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // --- MASSIVE TIME DISPLAY ---
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$_selectedMinutes',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 96,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -4.0,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isAr ? 'دقيقة' : 'mins',
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // --- CUSTOM APPLE-STYLE SLIDER ---
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.primary.withOpacity(
                            0.1,
                          ),
                          thumbColor: AppColors.primary,
                          overlayColor: AppColors.primary.withOpacity(0.2),
                          trackHeight: 8.0,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 14.0,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 28.0,
                          ),
                        ),
                        child: Slider(
                          value: _selectedMinutes.toDouble(),
                          min: 0,
                          max: _maxMinutes.toDouble(),
                          divisions: AppCategories.allCategories.length,
                          onChanged: _updateCategoriesFromSlider,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --- 🚀 NEW: VERTICAL EXPANDED LIST ---
                      Text(
                        isAr
                            ? 'يتضمن (اسحب للترتيب):'
                            : 'Includes (Hold to drag):',
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 🚀 Expanded perfectly fills the "blank white" at the bottom!
                      Expanded(
                        child: Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(canvasColor: Colors.transparent),
                          child: _activeCategories.isEmpty
                              ? Center(
                                  child: Text(
                                    isAr
                                        ? 'لا توجد مواضيع محددة.'
                                        : 'No topics selected.',
                                    style: TextStyle(
                                      color: AppColors.textGrey.withOpacity(
                                        0.5,
                                      ),
                                    ),
                                  ),
                                )
                              : ReorderableListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  buildDefaultDragHandles: false,
                                  itemCount: _activeCategories.length,
                                  onReorder: (oldIndex, newIndex) {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      if (newIndex > oldIndex) newIndex -= 1;
                                      final item = _activeCategories.removeAt(
                                        oldIndex,
                                      );
                                      _activeCategories.insert(newIndex, item);
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    final category = _activeCategories[index];
                                    return _buildDraggableRow(
                                      category,
                                      index,
                                      isAr,
                                    );
                                  },
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // --- SAVE ROUTINE CHECKBOX ---
                      GestureDetector(
                        onTap: _toggleDailyRoutine,
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 24,
                              width: 24,
                              decoration: BoxDecoration(
                                color: _useRoutineDaily
                                    ? AppColors.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _useRoutineDaily
                                      ? AppColors.primary
                                      : AppColors.textGrey.withOpacity(0.4),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _useRoutineDaily
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              routineText,
                              style: TextStyle(
                                color: _useRoutineDaily
                                    ? AppColors.textDark
                                    : AppColors.textGrey,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // --- BUTTON ---
                      CustomButton(
                        text: btnText,
                        textColor: Colors.white,
                        backgroundColor: AppColors.primary,
                        hasShadow: true,
                        trailingIcon: Icons.play_arrow_rounded,
                        onPressed: _activeCategories.isNotEmpty
                            ? () {
                                HapticFeedback.heavyImpact();

                                // 1. Extract just the IDs from your active categories list
                                final orderedIds = _activeCategories
                                    .map((c) => c.id)
                                    .toList();

                                // 2. 🚀 NEW: ENCAPSULATED LOGIC! Save to Firebase if checked
                                if (_useRoutineDaily) {
                                  // First, get the current Auth state safely
                                  final authState = context
                                      .read<AuthCubit>()
                                      .state;

                                  // If they are logged in (or a guest), grab their ID and tell UserCubit to save!
                                  if (authState is AuthAuthenticated) {
                                    context.read<UserCubit>().saveUserRoutine(
                                      authState.user.id,
                                      orderedIds,
                                      useRoutineDaily: _useRoutineDaily,
                                    );
                                  }
                                }

                                // 3. Navigate and pass the data!
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DailyMixPlayerScreen(
                                      languageCode: _selectedLanguage,
                                      orderedCategoryIds: orderedIds,
                                    ),
                                  ),
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 🚀 NEW: VERTICAL FULL-WIDTH ROWS ---
  Widget _buildDraggableRow(NewsCategory category, int index, bool isAr) {
    return Container(
      key: ValueKey(category.id),
      margin: const EdgeInsets.only(bottom: 10), // Spaces items vertically
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textGrey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: EdgeInsets.only(
                right: isAr ? 0 : 12.0,
                left: isAr ? 12.0 : 0,
              ),
              child: Icon(
                Icons.drag_indicator,
                color: AppColors.textGrey.withOpacity(0.4),
                size: 20,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(category.icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),

          // Using Expanded forces the 'X' button to the far right!
          Expanded(
            child: Text(
              _translateCategory(category.title),
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),

          GestureDetector(
            onTap: () => _removeCategory(index),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.textGrey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: AppColors.textGrey.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
