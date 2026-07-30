import 'package:news_app_frontend/features/news/domain/repositories/news_repo.dart';

import '../../../../core/services/database_service.dart';
import '../models/news_models.dart';

class NewsRepoImpl implements NewsRepo {
  // We inject the abstract DatabaseService, NOT Firebase!
  final DatabaseService databaseService;

  NewsRepoImpl({required this.databaseService});

  @override
  Future<List<NewsModel>> getDailyMixes() async {
    try {
      final rawDataList = await databaseService.getDailyMixesData();

      return rawDataList.map((data) {
        // 1. Extract the document ID we sneaked into the service layer
        final docId = data['temporary_document_id'] as String;

        // 2. Safely call your existing factory constructor with both arguments!
        return NewsModel.fromJson(data, docId);
      }).toList();
    } catch (e) {
      throw Exception("Repository Error: Failed to parse mixes: $e");
    }
  }
}
