import '../../domain/entities/news_entity.dart';

class NewsModel extends NewsEntity {
  const NewsModel({
    required super.id,
    required super.categoryId,
    required super.title,
    required super.summaryText,
    required super.sourceName,
    required super.audioUrl,
    required super.sourceUrl,
    required super.durationSeconds,
    required super.fileSizeBytes,
    super.imageUrl,
    required super.tags,
    required super.priorityWeight,
    super.sentiment,
    required super.availableLanguages,
    required super.createdAt,
    required super.expiresAt,
    required super.listenCount,
    required super.likesCount,
    required super.dislikesCount,
    required super.shareCount,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json, String documentId) {
    Map<String, String> parseMap(dynamic jsonMap) {
      if (jsonMap == null) return {};
      return Map<String, String>.from(jsonMap as Map);
    }

    return NewsModel(
      id: documentId,
      categoryId: json['categoryId'] ?? '',
      title: parseMap(json['title']),
      summaryText: parseMap(json['summaryText']),
      sourceName: parseMap(json['sourceName']),
      audioUrl: parseMap(json['audioUrl']),
      sourceUrl: json['sourceUrl'] ?? '',
      durationSeconds: json['durationSeconds'] ?? 0,
      fileSizeBytes: json['fileSizeBytes'] ?? 0,
      imageUrl: json['imageUrl'],
      tags: List<String>.from(json['tags'] ?? []),
      priorityWeight: json['priorityWeight'] ?? 1,
      sentiment: json['sentiment'],
      availableLanguages: List<String>.from(
        json['availableLanguages'] ?? ['en', 'ar'],
      ),
      createdAt: json['createdAt']?.toDate() ?? DateTime.now(),
      expiresAt: json['expiresAt']?.toDate() ?? DateTime.now(),
      listenCount: json['listenCount'] ?? 0,
      likesCount: json['likesCount'] ?? 0,
      dislikesCount: json['dislikesCount'] ?? 0,
      shareCount: json['shareCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id':
          id, // 🚀 CRITICAL FIX: Save the ID so we don't lose it in nested lists
      'categoryId': categoryId,
      'title': title,
      'summaryText': summaryText,
      'sourceName': sourceName,
      'audioUrl': audioUrl,
      'sourceUrl': sourceUrl,
      'durationSeconds': durationSeconds,
      'fileSizeBytes': fileSizeBytes,
      'imageUrl': imageUrl,
      'tags': tags,
      'priorityWeight': priorityWeight,
      'sentiment': sentiment,
      'availableLanguages': availableLanguages,
      'createdAt': createdAt,
      'expiresAt': expiresAt,
      'listenCount': listenCount,
      'likesCount': likesCount,
      'dislikesCount': dislikesCount,
      'shareCount': shareCount,
    };
  }
}
