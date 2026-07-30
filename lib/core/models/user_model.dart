import '../constants/app_keys.dart';
import '../entities/user_entity.dart';
// 🚀 Notice we don't need to import NewsModel here anymore either!

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.userName,
    super.photoUrl,
    super.pushTokens,
    super.isGuest,
    super.dailyRoutine, // 🚀 Replaced savedMixes
    required super.createdAt,
    super.lastLogin,
    super.country,
    super.region,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data[AppKeys.userId] ?? data['uid'] ?? '',
      email: data[AppKeys.userEmail] ?? '',
      userName: data[AppKeys.userName] ?? '',
      photoUrl: data[AppKeys.userPhotoUrl],
      country: data['country'],
      region: data['region'],
      pushTokens: List<String>.from(
        data[AppKeys.userPushTokens] ?? data['fcmTokens'] ?? [],
      ),
      isGuest: data['isGuest'] ?? false,

      // 🚀 THE MAGIC: Look how much simpler this is now!
      dailyRoutine: List<String>.from(data['dailyRoutine'] ?? []),

      createdAt: _parseDate(data[AppKeys.userCreatedAt]) ?? DateTime.now(),
      lastLogin: _parseDate(data[AppKeys.userLastLogin]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AppKeys.userId: id,
      AppKeys.userEmail: email,
      AppKeys.userName: userName,
      AppKeys.userPhotoUrl: photoUrl,
      AppKeys.userPushTokens: pushTokens,
      'isGuest': isGuest,
      'country': country,
      'region': region,
      'dailyRoutine': dailyRoutine, // 🚀 Replaced savedMixes
      AppKeys.userCreatedAt: createdAt,
      AppKeys.userLastLogin: lastLogin,
    };
  }

  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is DateTime) return date;
    if (date is String) return DateTime.tryParse(date);
    try {
      return (date as dynamic).toDate();
    } catch (e) {
      return null;
    }
  }
}
