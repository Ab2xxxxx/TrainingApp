import 'package:flutter/material.dart';
import '/models/workout.dart';
import '/models/workout_instance.dart';
import '/services/workout_instance_service.dart';
import '/models/exercise.dart';
import '/widgets/exercise_instance_widget.dart';
import '/widgets/timer_widget.dart';
import 'package:training/services/timer_service.dart';

class NewWorkoutInstancePage extends StatefulWidget {
  final Workout workout;

  const NewWorkoutInstancePage({Key? key, required this.workout}) : super(key: key);

  @override
  NewWorkoutInstancePageState createState() => NewWorkoutInstancePageState();
}

class NewWorkoutInstancePageState extends State<NewWorkoutInstancePage> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final List<ExerciseInstance> _exerciseInstances = [];
  WorkoutInstance? _lastWorkoutInstance;
  late Future<void> _loadDataFuture;
  int _currentExerciseRestPeriod = 0;
  final GlobalKey<TimerWidgetState> _timerKey = GlobalKey<TimerWidgetState>();
  int _lastUpdatedExerciseIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDataFuture = _loadLastWorkoutInstance();
    _currentExerciseRestPeriod = widget.workout.exercises.first.restPeriod;
    TimerService().startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    TimerService().dispose();
    super.dispose();
  }



  Future<void> _loadLastWorkoutInstance() async {
    _lastWorkoutInstance = await WorkoutInstanceService().getLastWorkoutInstance(widget.workout.name);

    for (var exercise in widget.workout.exercises) {
      final lastExerciseInstance = _lastWorkoutInstance?.exercises.firstWhere(
        (e) => e.name == exercise.name,
        orElse: () => ExerciseInstance(name: exercise.name, sets: []),
      );

      final sets = List.generate(
        exercise.sets,
        (index) {
          double weight = 0.0;
          int reps = 0;
          if (lastExerciseInstance != null && lastExerciseInstance.sets.length > index) {
            weight = lastExerciseInstance.sets[index].weight;
            reps = lastExerciseInstance.sets[index].reps;
          }
          return SetDetails(
            setNumber: index + 1,
            weight: weight,
            reps: reps,
          );
        },
      );
      _exerciseInstances.add(ExerciseInstance(name: exercise.name, sets: sets));
    }
  }

  void _saveWorkoutInstance() {
    if (_formKey.currentState!.validate()) {
      final workoutInstance = WorkoutInstance(
        name: widget.workout.name,
        exercises: _exerciseInstances,
        createdAt: DateTime.now(),
      );

      WorkoutInstanceService().addWorkoutInstance(workoutInstance).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Экземпляр тренировки успешно сохранен')),
        );
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения экземпляра тренировки: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, заполните все поля')),
      );
    }
  }

  void _moveExercise(int oldIndex, int newIndex) {
    setState(() {
      final exercise = _exerciseInstances.removeAt(oldIndex);
      _exerciseInstances.insert(newIndex, exercise);
    });
  }

  void _deleteExercise(int index) {
    setState(() {
      _exerciseInstances.removeAt(index);
    });
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      final exercise = _exerciseInstances[exerciseIndex];
      final newSet = SetDetails(setNumber: exercise.sets.length + 1, weight: 0.0, reps: 0);
      exercise.sets.add(newSet);
    });
    _updateLastExercise(exerciseIndex);
  }

  void _deleteSet(int exerciseIndex, int setIndex) {
    setState(() {
      _exerciseInstances[exerciseIndex].sets.removeAt(setIndex);
      _renumberSets(_exerciseInstances[exerciseIndex]);
    });
    _updateLastExercise(exerciseIndex);
  }

  void _renumberSets(ExerciseInstance exercise) {
    for (int i = 0; i < exercise.sets.length; i++) {
      exercise.sets[i].setNumber = i + 1;
    }
  }

  Future<String?> _showAddExerciseDialog() async {
    String? exerciseName;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Добавить новое упражнение'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Введите название упражнения'),
            onChanged: (value) {
              exerciseName = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Добавить'),
              onPressed: () {
                Navigator.of(context).pop(exerciseName);
              },
            ),
          ],
        );
      },
    );
  }

  void _addExercise() async {
    final exerciseName = await _showAddExerciseDialog();
    if (exerciseName != null && exerciseName.isNotEmpty) {
      setState(() {
        final newExercise = ExerciseInstance(name: exerciseName, sets: [
          SetDetails(setNumber: 1, weight: 0.0, reps: 0),
        ]);
        _exerciseInstances.add(newExercise);
      });
      _updateLastExercise(_exerciseInstances.length - 1);
    }
  }

  void _resetTimer(int restPeriod) {
    setState(() {
      _currentExerciseRestPeriod = restPeriod;
    });
    _timerKey.currentState?.resetTimer();
  }

  void _updateLastExercise(int exerciseIndex) {
    setState(() {
      _lastUpdatedExerciseIndex = exerciseIndex;
      _currentExerciseRestPeriod = widget.workout.exercises[exerciseIndex].restPeriod;
    });
    _timerKey.currentState?.resetTimer();
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.name),
        actions: [
          TextButton(
            onPressed: _saveWorkoutInstance,
            child: const Text('Заканчивать', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else {
            return _buildWorkoutForm();
          }
        },
      ),
    );
  }

  Widget _buildWorkoutForm() {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      ..._exerciseInstances.asMap().entries.map((entry) {
                        final index = entry.key;
                        final exercise = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ExerciseInstanceWidget(
                            exercise: exercise,
                            exerciseIndex: index,
                            templateExercise: widget.workout.exercises.firstWhere(
                              (e) => e.name == exercise.name,
                              orElse: () => Exercise(name: 'Неизвестный', sets: 0, restPeriod: 0),
                            ),
                            lastWorkoutInstance: _lastWorkoutInstance,
                            onMoveExercise: _moveExercise,
                            onDeleteExercise: _deleteExercise,
                            onAddSet: _addSet,
                            onDeleteSet: _deleteSet,
                            onSetChanged: () => _updateLastExercise(index),
                            onResetTimer: _resetTimer,
                            theme: theme,
                          ),
                        );
                      }).toList(),
                      // _buildAddExerciseButton(theme),
                    ],
                  ),
                ),
              ),
            ),
            // TimerWidget(
            //   key: _timerKey,
            //   currentExerciseRestPeriod: _currentExerciseRestPeriod,
            // ),
          ],
        ),
      ),
    );
  }

  // Widget _buildAddExerciseButton(ThemeData theme) {
  //   return ElevatedButton.icon(
  //     onPressed: _addExercise,
  //     icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
  //     label: Text('Добавить упражнение', style: TextStyle(color: theme.colorScheme.onPrimary)),
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: theme.colorScheme.primary,
  //       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //     ),
  //   );
  // }
}