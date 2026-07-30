// Standard Exception for Server/Firebase errors
class ServerException implements Exception {
  final String message;
  const ServerException({required this.message});
}

// Exception for Local Data / Cache errors
class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});
}
