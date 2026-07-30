import 'dart:developer';
import 'package:flutter/foundation.dart'; // ✅ ADD THIS FOR kIsWeb
import 'package:firebase_messaging/firebase_messaging.dart';

import 'notifications_service.dart';

class FirebaseNotificationsService implements NotificationsService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  @override
  Future<String?> getDeviceToken() async {
    try {
      // 🚀 Works instantly on Android, and will attempt on physical iOS devices!
      return await _fcm.getToken();
    } catch (e) {
      // 🛡️ THE EXCEPTION: If it fails (like on an iOS simulator), catch the crash,
      // log it, and return null so the login flow continues without breaking!
      log("⚠️ Failed to get push token, continuing without it: $e");
      return null;
    }
  }

  @override
  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;

  @override
  Future<bool> requestPermission() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  @override
  Future<Map<String, dynamic>?> getInitialMessageData() async {
    final message = await _fcm.getInitialMessage();
    return message?.data;
  }

  @override
  Stream<Map<String, dynamic>> get onNotificationClick {
    return FirebaseMessaging.onMessageOpenedApp.map((message) => message.data);
  }

  @override
  Stream<Map<String, dynamic>> get onForegroundMessage {
    return FirebaseMessaging.onMessage.map((message) {
      return {
        'title': message.notification?.title ?? 'New Notification',
        'body': message.notification?.body ?? '',
        'data': message.data,
      };
    });
  }

  // ===========================================================================
  // 🚀 FIXED: SAFELY BYPASS TOPICS ON WEB
  // ===========================================================================
  @override
  Future<void> subscribeToTopic(String topic) async {
    if (kIsWeb) {
      log("⚠️ Topic subscription is not supported on Web. Skipping...");
      return; // Stop the function here so it doesn't crash
    }
    await _fcm.subscribeToTopic(topic);
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    if (kIsWeb) {
      log("⚠️ Topic unsubscription is not supported on Web. Skipping...");
      return; // Stop the function here so it doesn't crash
    }
    await _fcm.unsubscribeFromTopic(topic);
  }
}
