import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/level_entity.dart';
import '../../data/datasources/levels_data.dart';

abstract class MapState {}

class MapInitial extends MapState {}

class MapLoaded extends MapState {
  final List<LevelEntity> levels;
  MapLoaded(this.levels);
}

class MapCubit extends Cubit<MapState> {
  MapCubit() : super(MapInitial());

  void loadLevels() {
    emit(MapLoaded(LevelsData.levels));
  }
}
