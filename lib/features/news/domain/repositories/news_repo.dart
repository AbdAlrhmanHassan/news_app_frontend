import '../../data/models/news_models.dart';

abstract class NewsRepo {
  /// Fetches all available 3-minute news blocks for today
  Future<List<NewsModel>> getDailyMixes();
}
