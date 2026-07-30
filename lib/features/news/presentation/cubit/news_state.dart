import '../../data/models/news_models.dart';

abstract class NewsState {}

/// The initial state when the app first boots up
class NewsInitial extends NewsState {}

/// The state when we are waiting for Firebase to return the documents
class NewsLoading extends NewsState {}

/// The state when Firebase successfully returns the news blocks
class NewsLoaded extends NewsState {
  final List<NewsModel> mixes;

  NewsLoaded(this.mixes);
}

/// The state if something goes wrong
class NewsError extends NewsState {
  final String message;

  NewsError(this.message);
}
