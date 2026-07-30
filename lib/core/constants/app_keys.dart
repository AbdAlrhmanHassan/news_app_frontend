class AppCollections {
  AppCollections._();

  // 🚀 UPDATED FOR NEWS PROJECT
  static const String news = 'news';
  static const String banners = 'banners';
  static const String users = 'users';
  static const String appAssets = 'app_assets';
}

class AppKeys {
  AppKeys._();

  // 🔔 Notifications
  static const String allUsersTopic = 'all_users';

  // 🌍 Language & Map Keys
  static const String langDefault = 'default';
  static const String langAr = 'ar';
  static const String langEn = 'en';

  // 🖼️ Storage Folders
  static const String newsAudio =
      'news_audio'; // 🚀 Swapped places_images for audio
  static const String bannersImages = 'banners_images';

  // 📱 App Assets Document Keys
  static const String headerImages = 'header_images';
  static const String promoImages = 'promo_images';

  // 👤 User Document Keys (🚀 REFINED FOR NEWS APP)
  static const String userId = 'id';
  static const String userEmail = 'email';
  static const String userName = 'userName';
  static const String userPhotoUrl = 'photoUrl';
  static const String userPushTokens = 'pushTokens';

  // 🚀 NEW KEYS FOR OUR UNIFIED USER MODEL
  static const String userIsGuest = 'isGuest';
  static const String userSavedMixes = 'savedMixes';

  static const String userCreatedAt = 'createdAt';
  static const String userLastLogin = 'lastLogin';
}
