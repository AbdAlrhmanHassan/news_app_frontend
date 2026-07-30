import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import '../../../news/data/models/news_models.dart';

// Import your models so the manager knows how to read the mixes

class HomeWidgetManager {
  // Singleton pattern so we use the exact same manager everywhere
  static final HomeWidgetManager _instance = HomeWidgetManager._internal();
  factory HomeWidgetManager() => _instance;
  HomeWidgetManager._internal();

  final String appGroupId = 'group.com.abdalrhman.newsapp';
  final String iosWidgetName = 'DailyNewsWidget';
  final String androidWidgetName = 'DailyNewsWidget';

  // 1. Initialize the secure App Group
  Future<void> initialize() async {
    await HomeWidget.setAppGroupId(appGroupId);
  }

  // 2. The core logic extracted from your UI page
  Future<void> updateWidgetFromNews(
    List<NewsModel> mixes,
    String languageCode,
  ) async {
    try {
      final bool isAr = languageCode == 'ar';
      String title = isAr ? 'مزيجك اليومي' : 'Your Daily Mix';
      String summary = isAr ? 'جاهز للتشغيل' : 'Ready to play';

      if (mixes.isNotEmpty) {
        // We have active mixes! Calculate total time or total tracks
        title = isAr ? 'أخبارك جاهزة' : 'News is Ready';
        summary = isAr
            ? '${mixes.length} مقاطع متوفرة'
            : '${mixes.length} tracks available';
      } else {
        // Mix queue is null/empty, we should prompt them to listen to all categories
        title = isAr ? 'اكتشف الأخبار' : 'Discover News';
        summary = isAr ? 'تشغيل كل الفئات' : 'Play all categories';
      }

      // Save the computed logic directly to the native OS
      await HomeWidget.saveWidgetData<String>('news_title', title);
      await HomeWidget.saveWidgetData<String>('news_summary', summary);

      // Force the iOS/Android home screen to redraw
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: iosWidgetName,
      );

      debugPrint('✅ Widget successfully updated in background!');
    } catch (e) {
      debugPrint('❌ Error updating widget: $e');
    }
  }
}
