import 'package:equatable/equatable.dart';
// 🚀 Notice we don't even need to import NewsEntity here anymore! So clean.

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String userName;
  final String? photoUrl;
  final List<String> pushTokens;
  final bool isGuest;
  final List<String> dailyRoutine; // 🚀 NEW: Simple list of strings
  final DateTime createdAt;
  final DateTime? lastLogin;
  final String? country;
  final String? region;

  const UserEntity({
    required this.id,
    required this.email,
    required this.userName,
    this.photoUrl,
    this.pushTokens = const [],
    this.isGuest = false,
    this.dailyRoutine = const [], // 🚀 Replaced savedMixes
    required this.createdAt,
    this.lastLogin,
    this.country,
    this.region,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? userName,
    String? photoUrl,
    List<String>? pushTokens,
    bool? isGuest,
    List<String>? dailyRoutine, // 🚀 Replaced savedMixes
    DateTime? createdAt,
    DateTime? lastLogin,
    String? country,
    String? region,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      userName: userName ?? this.userName,
      photoUrl: photoUrl ?? this.photoUrl,
      pushTokens: pushTokens ?? this.pushTokens,
      isGuest: isGuest ?? this.isGuest,
      dailyRoutine: dailyRoutine ?? this.dailyRoutine, // 🚀 Replaced savedMixes
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      country: country ?? this.country,
      region: region ?? this.region,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    userName,
    photoUrl,
    pushTokens,
    isGuest,
    dailyRoutine, // 🚀 Replaced savedMixes
    createdAt,
    lastLogin,
    country,
    region,
  ];
}
