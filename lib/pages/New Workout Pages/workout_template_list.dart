import 'package:flutter/material.dart';
import '/models/workout.dart';
import '/services/workout_service.dart';
import 'new_workout_instance_page.dart';

class WorkoutTemplateList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ваши тренировки'),
      ),
      body: StreamBuilder<List<Workout>>(
        stream: WorkoutService().getWorkouts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.map((workout) => ListTile(
              title: Text(workout.name),
              subtitle: Text('${workout.exercises.length} упражнения'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewWorkoutInstancePage(workout: workout),
                  ),
                );
              },
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Color.fromARGB(255, 114, 105, 104)),
                onPressed: () async {
                  final shouldDelete = await _confirmDelete(context);
                  if (shouldDelete) {
                    await WorkoutService().deleteWorkout(workout.name);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Тренировка удалена')),
                    );
                  }
                },
              ),
            )).toList(),
          );
        },
      ),
    );
  }

Future<bool> _confirmDelete(BuildContext context) async {
  final theme = Theme.of(context);

  return await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Подтвердите удаление',
          style: theme.textTheme.headlineMedium,
        ),
        content: Text(
          'Вы уверены, что хотите удалить эту тренировку?',
          style: theme.textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(
              'Отмена',
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(
              'Удалить',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
        backgroundColor: theme.cardTheme.color,
      );
    },
  ) ?? false;
}
}
