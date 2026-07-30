import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_widgets_state.dart';

class HomeWidgetsCubit extends Cubit<HomeWidgetsState> {
  HomeWidgetsCubit() : super(HomeWidgetsInitial());
}
