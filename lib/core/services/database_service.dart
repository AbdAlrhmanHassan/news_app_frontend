abstract class DatabaseService {
  // 🚀 Your specific method for the audio news feed
  Future<List<Map<String, dynamic>>> getDailyMixesData();

  // 🚀 The generic methods for Clean Architecture (UserRepo, etc.)
  Future<List<Map<String, dynamic>>> getData({
    required String path,
    Map<String, dynamic>? query,
    String? orderBy,
    bool descending = false,
  });

  Future<Map<String, dynamic>?> getDocument({
    required String path,
    required String documentId,
  });

  Future<void> addData({
    required String path,
    required Map<String, dynamic> data,
    String?
    documentId, // Note: Optional so Firebase can auto-generate if needed
  });

  Future<bool> checkIfExists({
    required String path,
    required String documentId,
  });

  Future<void> updateData({
    required String path,
    required String documentId,
    required Map<String, dynamic> data,
  });

  Future<void> deleteData({required String path, required String documentId});

  String generateId();

  Future<void> deleteCollection({required String path});
}
