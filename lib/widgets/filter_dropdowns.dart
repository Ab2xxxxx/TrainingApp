import 'package:flutter/material.dart';
import '../enums.dart';


Widget buildFilterDropdowns(
  ViewType selectedViewType,
  TimeFrame selectedTimeFrame,
  GroupBy selectedGroupBy,
  Function(ViewType?) onViewTypeChanged,
  Function(TimeFrame?) onTimeFrameChanged,
  Function(GroupBy?) onGroupByChanged,
  BuildContext context,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      DropdownButton<ViewType>(
        value: selectedViewType,
        onChanged: onViewTypeChanged,
        items: [
          DropdownMenuItem(
            value: ViewType.volume,
            child: Text(
              'Объем',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
          DropdownMenuItem(
            value: ViewType.sets,
            child: Text(
              'Сеты',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
          DropdownMenuItem(
            value: ViewType.oneRepMax,
            child: Text(
              'Макс. за 1 раз',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
      DropdownButton<TimeFrame>(
        value: selectedTimeFrame,
        onChanged: onTimeFrameChanged,
        items: [
          DropdownMenuItem(
            value: TimeFrame.last7Days,
            child: Text(
              'Последние 7 дней',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
          DropdownMenuItem(
            value: TimeFrame.lastMonth,
            child: Text(
              'Прошлый месяц',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
          DropdownMenuItem(
            value: TimeFrame.lastYear,
            child: Text(
              'Прошлый год',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
      // SizedBox(height: 8),
      // DropdownButton<GroupBy>(
      //   value: selectedGroupBy,
      //   onChanged: onGroupByChanged,
      //   items: [
      //     DropdownMenuItem(
      //       value: GroupBy.muscleGroup,
      //       child: Text(
      //         'По группам мышц',
      //         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
      //               color: Theme.of(context).colorScheme.onSurface,
      //             ),
      //       ),
      //     ),
      //     DropdownMenuItem(
      //       value: GroupBy.exercise,
      //       child: Text(
      //         'С помощью упражнений',
      //         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
      //               color: Theme.of(context).colorScheme.onSurface,
      //             ),
      //       ),
      //     ),
      //   ],
      // ),
    ],
  );
}