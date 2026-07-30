abstract class NotificationsService {
  /// Fetches the unique ID for the current device
  Future<String?> getDeviceToken();

  /// A stream that emits a new string whenever the device token changes
  Stream<String> get onTokenRefresh;

  /// Optional: Handle permission requests
  Future<bool> requestPermission();

  Future<Map<String, dynamic>?> getInitialMessageData();

  /// A stream of data payloads when the user clicks a notification in the background
  Stream<Map<String, dynamic>> get onNotificationClick;

  Stream<Map<String, dynamic>> get onForegroundMessage;

  // 🚀 NEW: Topic Broadcasting
  Future<void> subscribeToTopic(String topic);
  Future<void> unsubscribeFromTopic(String topic);
}
