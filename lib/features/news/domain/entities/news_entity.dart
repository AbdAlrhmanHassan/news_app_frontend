class NewsEntity {
  // Core
  final String id;
  final String categoryId;

  // Bilingual Maps: {'en': 'English Text', 'ar': 'Arabic Text'}
  final Map<String, String> title;
  final Map<String, String> summaryText;
  final Map<String, String> sourceName;

  // Media
  final Map<String, String> audioUrl; // Different MP3s for different languages!
  final String sourceUrl;
  final int durationSeconds;
  final int fileSizeBytes;
  final String? imageUrl; // Nullable, used for Lock Screen media player

  // AI & Algorithm
  final List<String> tags; // e.g., ['tech', 'AI'] for personalization
  final int priorityWeight; // e.g., 10 for Breaking News, 1 for normal
  final String? sentiment; // Nullable (positive, negative, neutral)

  // Replaced 'language' with this to track which languages are available
  final List<String> availableLanguages; // e.g., ['ar', 'en']

  // Timestamps (Removed publishedAt as requested)
  final DateTime createdAt;
  final DateTime expiresAt;

  // Metrics
  final int listenCount;
  final int likesCount;
  final int dislikesCount;
  final int shareCount;

  const NewsEntity({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.summaryText,
    required this.sourceName,
    required this.audioUrl,
    required this.sourceUrl,
    required this.durationSeconds,
    required this.fileSizeBytes,
    this.imageUrl,
    required this.tags,
    required this.priorityWeight,
    this.sentiment,
    required this.availableLanguages,
    required this.createdAt,
    required this.expiresAt,
    required this.listenCount,
    required this.likesCount,
    required this.dislikesCount,
    required this.shareCount,
  });

  // --- BUSINESS LOGIC ---
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  // Helper to quickly grab the right text based on the app's current language
  String getTitle(String langCode) =>
      title[langCode] ?? title['en'] ?? 'Unknown Title';
  String getAudio(String langCode) =>
      audioUrl[langCode] ?? audioUrl['en'] ?? '';
}
