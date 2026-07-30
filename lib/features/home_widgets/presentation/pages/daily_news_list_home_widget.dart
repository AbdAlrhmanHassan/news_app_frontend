import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart'; // Don't forget the import!

class DailyNewsList extends StatefulWidget {
  const DailyNewsList({super.key});

  @override
  State<DailyNewsList> createState() => _DailyNewsListState();
}

class _DailyNewsListState extends State<DailyNewsList> {
  // ✅ Your perfectly formatted native variables
  final String appGroupId = 'group.com.abdalrhman.newsapp';
  final String iosWidgetName = 'DailyNewsWidget';
  final String androidWidgetName = 'DailyNewsWidget';
  final String dataKey = 'daily_news_data';

  @override
  void initState() {
    super.initState();
    // 1. Tell home_widget to use your secure iOS App Group folder!
    HomeWidget.setAppGroupId(appGroupId);
  }

  // 2. The magic function that sends data to the device
  Future<void> sendDataToWidget() async {
    try {
      // Save the raw text to the device's native storage
      await HomeWidget.saveWidgetData<String>(
        dataKey,
        'Your 15-minute summary is ready!', // The test data we are sending
      );

      // Tell iOS/Android to refresh the home screen widget
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: iosWidgetName,
      );

      // Show a quick success message in the app
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data sent to widget! 🎉')),
        );
      }
    } catch (e) {
      debugPrint('Error updating widget: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Setup')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: sendDataToWidget,
          icon: const Icon(Icons.send_to_mobile),
          label: const Text(
            'Send Data to Widget',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
      ),
    );
  }
}
