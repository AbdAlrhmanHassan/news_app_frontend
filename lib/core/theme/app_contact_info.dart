class AppContactInfo {
  // Private constructor
  const AppContactInfo._();

  // ✅ DISPLAY TEXT
  static const String supportEmail = "aalrhman675@gmail.com";
  static const String supportPhoneDisplay =
      "+962 79 236 6968"; // Professional format

  // ✅ ACTION LINKS (Technical)
  // WhatsApp requires country code WITHOUT plus sign
  static const String whatsappNumber = "962792366968";

  // Dialer requires country code WITH plus sign
  static const String phoneDialer = "+962792366968";
}
