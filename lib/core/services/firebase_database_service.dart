import 'package:cloud_firestore/cloud_firestore.dart';

import 'database_service.dart';

class FirebaseDatabaseService implements DatabaseService {
  final FirebaseFirestore firestore;

  FirebaseDatabaseService({required this.firestore});

  // ===========================================================================
  // 🎵 AUDIO NEWS SPECIFIC METHODS
  // ===========================================================================

  @override
  Future<List<Map<String, dynamic>>> getDailyMixesData() async {
    try {
      final snapshot = await firestore.collection('daily_mixes').get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Inject the document ID directly into the raw map under a temporary key
        data['temporary_document_id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception("Database Error: $e");
    }
  }

  // ===========================================================================
  // 🏗️ GENERIC CLEAN ARCHITECTURE METHODS
  // ===========================================================================

  @override
  Future<List<Map<String, dynamic>>> getData({
    required String path,
    Map<String, dynamic>? query,
    String? orderBy,
    bool descending = false,
  }) async {
    Query<Map<String, dynamic>> ref = firestore.collection(path);

    if (query != null) {
      query.forEach((key, value) {
        ref = ref.where(key, isEqualTo: value);
      });
    }

    if (orderBy != null) {
      ref = ref.orderBy(orderBy, descending: descending);
    }

    final snapshot = await ref.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  @override
  Future<Map<String, dynamic>?> getDocument({
    required String path,
    required String documentId,
  }) async {
    final doc = await firestore.collection(path).doc(documentId).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    }
    return null;
  }

  @override
  Future<bool> checkIfExists({
    required String path,
    required String documentId,
  }) async {
    final doc = await firestore.collection(path).doc(documentId).get();
    return doc.exists;
  }

  @override
  Future<void> addData({
    required String path,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    if (documentId != null) {
      await firestore.collection(path).doc(documentId).set(data);
    } else {
      await firestore.collection(path).add(data);
    }
  }

  @override
  Future<void> updateData({
    required String path,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await firestore.collection(path).doc(documentId).update(data);
  }

  @override
  Future<void> deleteData({
    required String path,
    required String documentId,
  }) async {
    await firestore.collection(path).doc(documentId).delete();
  }

  @override
  String generateId() {
    return firestore.collection('temp_id_generator').doc().id;
  }

  @override
  Future<void> deleteCollection({required String path}) async {
    final collection = firestore.collection(path);
    final snapshots = await collection.get();

    WriteBatch batch = firestore.batch();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
