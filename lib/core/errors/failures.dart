import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode; // ✅ Added: critical for handling 401/403/500 logic

  const ServerFailure({required String message, this.statusCode})
    : super(message);

  @override
  List<Object?> get props => [message, statusCode];
}

class CacheFailure extends Failure {
  const CacheFailure([String message = "Cache Error"]) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    String message = "Please check your internet connection",
  ]) : super(message);
}

// ✅ Added: For local logic errors (e.g. Image Picker failed, Parsing failed)
class InternalFailure extends Failure {
  const InternalFailure(String message) : super(message);
}

class AuthFailure extends Failure {
  const AuthFailure({required String message}) : super(message);
}
