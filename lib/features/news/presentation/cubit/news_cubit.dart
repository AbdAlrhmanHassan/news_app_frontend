import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_frontend/features/news/domain/repositories/news_repo.dart';
import 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  final NewsRepo repository;

  NewsCubit({required this.repository}) : super(NewsInitial());

  /// Fetches the latest bilingual news mixes from the backend
  Future<void> fetchNews() async {
    emit(NewsLoading());

    try {
      final mixes = await repository.getDailyMixes();
      emit(NewsLoaded(mixes));
    } catch (e) {
      emit(NewsError('Failed to load news: $e'));
    }
  }
}
