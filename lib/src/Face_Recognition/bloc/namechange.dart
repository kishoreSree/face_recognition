import 'package:flutter_bloc/flutter_bloc.dart';

class SelectedNameCubit extends Cubit<String> {
  SelectedNameCubit() : super("");

  void updateSelectedName(String newName) {
    emit(newName);
  }
}
