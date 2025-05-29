import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackntrain/utils/split_exercises.dart';

class WorkoutFilter {
  final String muscleGroup;
  final bool selected;
  final String type;

  WorkoutFilter({
    required this.muscleGroup,
    required this.selected,
    required this.type,
  });

  WorkoutFilter copyWith({
    String? muscleGroup,
    bool? selected,
    String? type,
  }) {
    return WorkoutFilter(
      muscleGroup: muscleGroup ?? this.muscleGroup,
      selected: selected ?? this.selected,
      type: type ?? this.type,
    );
  }
}

class WorkoutState {
  final Map<String, bool> selectedExercises;
  final List<Map<String, dynamic>> selectedExercisesList;
  final Map<String, List<Map<String, dynamic>>> filteredExercises;
  final List<WorkoutFilter> filters;
  final bool filtersApplied;

  WorkoutState({
    required this.selectedExercises,
    required this.selectedExercisesList,
    required this.filteredExercises,
    required this.filters,
    required this.filtersApplied,
  });

  WorkoutState copyWith({
    Map<String, bool>? selectedExercises,
    List<Map<String, dynamic>>? selectedExercisesList,
    Map<String, List<Map<String, dynamic>>>? filteredExercises,
    List<WorkoutFilter>? filters,
    bool? filtersApplied,
  }) {
    return WorkoutState(
      selectedExercises: selectedExercises ?? this.selectedExercises,
      selectedExercisesList: selectedExercisesList ?? this.selectedExercisesList,
      filteredExercises: filteredExercises ?? this.filteredExercises,
      filters: filters ?? this.filters,
      filtersApplied: filtersApplied ?? this.filtersApplied,
    );
  }
}

class WorkoutNotifier extends StateNotifier<WorkoutState> {
  final Map<String, List<Map<String, dynamic>>> _localMuscleSpecificExercises = muscleSpecificExercises;

  WorkoutNotifier() : super(_initialState()) {
    _initializeState();
  }

  static WorkoutState _initialState() {
    return WorkoutState(
      selectedExercises: {},
      selectedExercisesList: [],
      filteredExercises: {},
      filters: [],
      filtersApplied: false,
    );
  }

  void _initializeState() {
    final Map<String, bool> selectedExercises = {};
    final List<WorkoutFilter> filters = [];

    for (var muscleGroup in _localMuscleSpecificExercises.values) {
      for (var exercise in muscleGroup) {
        selectedExercises[exercise['exerciseName']] = false;
      }
    }

    for (var muscleGroup in _localMuscleSpecificExercises.entries) {
      filters.add(WorkoutFilter(
        muscleGroup: muscleGroup.key,
        selected: false,
        type: 'muscle',
      ));
    }
    filters.add(WorkoutFilter(
      muscleGroup: 'No Equipment',
      selected: false,
      type: 'equipment',
    ));

    state = state.copyWith(
      selectedExercises: selectedExercises,
      filters: filters,
      filteredExercises: _localMuscleSpecificExercises,
    );
  }

  void toggleExercise(Map<String, dynamic> exercise, bool isSelected) {
    final exerciseName = exercise['exerciseName'];
    final updatedSelectedExercises = Map<String, bool>.from(state.selectedExercises);
    final updatedSelectedExercisesList = List<Map<String, dynamic>>.from(state.selectedExercisesList);

    updatedSelectedExercises[exerciseName] = isSelected;

    if (isSelected) {
      if (!updatedSelectedExercisesList.any((e) => e['exerciseName'] == exerciseName)) {
        updatedSelectedExercisesList.add({
          'exerciseName': exerciseName,
          'primaryMuscleGroup': exercise['primaryMuscleTargeted'],
          'secondaryMuscleGroup': exercise['secondaryMusclesTargeted'],
          'howToPerform': exercise['howToPerform'],
          'specialConsiderations': exercise['specialConsiderations'],
        });
      }
    } else {
      updatedSelectedExercisesList.removeWhere((e) => e['exerciseName'] == exerciseName);
    }

    state = state.copyWith(
      selectedExercises: updatedSelectedExercises,
      selectedExercisesList: updatedSelectedExercisesList,
    );
  }

  void toggleFilter(String muscleGroup, bool value) {
    final updatedFilters = state.filters.map((filter) {
      if (filter.muscleGroup == muscleGroup) {
        return filter.copyWith(selected: value);
      }
      return filter;
    }).toList();

    state = state.copyWith(filters: updatedFilters);
  }

  void applyFilters() {
    final selectedMuscles = state.filters
        .where((f) => f.type == 'muscle' && f.selected == true)
        .map((f) => f.muscleGroup)
        .toList();

    final noEquipmentSelected = state.filters
        .firstWhere((f) => f.muscleGroup == 'No Equipment')
        .selected;

    final Map<String, List<Map<String, dynamic>>> filteredExercises = {};

    for (var entry in _localMuscleSpecificExercises.entries) {
      if (selectedMuscles.isNotEmpty && !selectedMuscles.contains(entry.key)) {
        continue;
      }

      final filteredExercisesInGroup = entry.value.where((exercise) {
        if (noEquipmentSelected) {
          final equipment = exercise['equipmentRequired'] ?? '';
          if (equipment.isNotEmpty) return false;
        }
        return true;
      }).toList();

      if (filteredExercisesInGroup.isNotEmpty) {
        filteredExercises[entry.key] = filteredExercisesInGroup;
      }
    }

    final filtersApplied = selectedMuscles.isNotEmpty || noEquipmentSelected;

    state = state.copyWith(
      filteredExercises: filteredExercises,
      filtersApplied: filtersApplied,
    );
  }

  void reorderExercises(int oldIndex, int newIndex) {
    final updatedList = List<Map<String, dynamic>>.from(state.selectedExercisesList);
    
    if (newIndex > oldIndex) {
      newIndex--;
    }
    final item = updatedList.removeAt(oldIndex);
    updatedList.insert(newIndex, item);

    state = state.copyWith(selectedExercisesList: updatedList);
  }

  void clearSelection() {
    final clearedSelectedExercises = Map<String, bool>.from(state.selectedExercises);
    for (var key in clearedSelectedExercises.keys) {
      clearedSelectedExercises[key] = false;
    }

    state = state.copyWith(
      selectedExercises: clearedSelectedExercises,
      selectedExercisesList: [],
    );
  }
}

final workoutProvider = StateNotifierProvider<WorkoutNotifier, WorkoutState>((ref) {
  return WorkoutNotifier();
});

final selectedExercisesProvider = Provider<Map<String, bool>>((ref) {
  return ref.watch(workoutProvider).selectedExercises;
});

final selectedExercisesListProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(workoutProvider).selectedExercisesList;
});

final filteredExercisesProvider = Provider<Map<String, List<Map<String, dynamic>>>>((ref) {
  final state = ref.watch(workoutProvider);
  return state.filteredExercises.isEmpty ? muscleSpecificExercises : state.filteredExercises;
});

final filtersProvider = Provider<List<WorkoutFilter>>((ref) {
  return ref.watch(workoutProvider).filters;
});

final filtersAppliedProvider = Provider<bool>((ref) {
  return ref.watch(workoutProvider).filtersApplied;
});

final selectedExercisesCountProvider = Provider<int>((ref) {
  return ref.watch(workoutProvider).selectedExercisesList.length;
});