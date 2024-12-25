import 'package:flutter/material.dart';
import '/models/exercise.dart';
import '/models/workout_instance.dart';

class SetRowWidget extends StatelessWidget {
  final SetDetails set;
  final int exerciseIndex;
  final Exercise templateExercise;
  final Function(int, int) onDeleteSet;
  final VoidCallback onSetChanged;
  final ThemeData theme;

  const SetRowWidget({
    Key? key,
    required this.set,
    required this.exerciseIndex,
    required this.templateExercise,
    required this.onDeleteSet,
    required this.onSetChanged,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = theme.brightness == Brightness.dark 
        ? Colors.grey[800] 
        : theme.colorScheme.primary; 

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Сет ${set.setNumber} - кг',
                    labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: set.weight.toString(),
                  style: theme.textTheme.bodyMedium,
                  onChanged: (value) {
                    set.weight = double.tryParse(value) ?? 0.0;
                    onSetChanged();
                  },
                  validator: (value) => (value == null || value.isEmpty) ? 'Введите вес' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Повторения',
                    labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: set.reps.toString(),
                  style: theme.textTheme.bodyMedium,
                  onChanged: (value) {
                    set.reps = int.tryParse(value) ?? 0;
                    onSetChanged();
                  },
                  validator: (value) => (value == null || value.isEmpty) ? 'Ввод повторений' : null,
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: theme.colorScheme.error),
                onPressed: () => onDeleteSet(exerciseIndex, set.setNumber - 1),
              ),
            ],
          ),
          if (set.setNumber < templateExercise.sets)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Отдых: ${templateExercise.restPeriod} секунд',
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}