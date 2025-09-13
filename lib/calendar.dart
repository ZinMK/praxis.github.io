import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meditation_scheduler/HiveDb.dart';
import 'package:meditation_scheduler/SettingsHive.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:hive_flutter/hive_flutter.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

// A simple widget to display a progress bar with a label

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Widget buildProgressBar({
    required String label,
    required double progress,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Get all completed days from Hive
  Set<DateTime> getCompletedDays() {
    final completedDays = <DateTime>{};

    for (var key in MeditationDayHiveDB.meditationDays.keys) {
      // Skip non-date keys (like 'lastAppDate')
      if (key is! String || !key.contains('T')) continue;

      final entry = MeditationDayHiveDB.meditationDays.get(
        key,
        defaultValue: {'morningCompleted': false, 'eveningCompleted': false},
      );

      // Skip non-map entries
      if (entry is! Map) continue;

      try {
        if (entry['morningCompleted'] == true &&
            entry['eveningCompleted'] == true) {
          final parsedDate = DateTime.parse(key);
          completedDays.add(
            DateTime(parsedDate.year, parsedDate.month, parsedDate.day),
          );
        }
      } catch (e) {
        // Skip entries that can't be parsed as dates
        continue;
      }
    }

    return completedDays;
  }

  TimeOfDay intToTimeOfDay(int time) {
    // Pad with zeros so "930" becomes "0930"
    String timeStr = time.toString().padLeft(4, '0');

    int hour = int.parse(timeStr.substring(0, 2));
    int minute = int.parse(timeStr.substring(2, 4));

    return TimeOfDay(hour: hour, minute: minute);
  }

  // Get meditation data for a specific day
  Map<dynamic, dynamic> getDayMeditationData(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day).toIso8601String();

    return MeditationDayHiveDB.meditationDays.get(
      dateKey,
      defaultValue: {
        'morningCompleted': false,
        'eveningCompleted': false,
        'morningDuration': 0,
        'eveningDuration': 0,
        'morningCompletionTime': null,
        'eveningCompletionTime': null,
      },
    );
  }

  // Format duration in minutes to a readable string
  String formatDuration(int minutes) {
    if (minutes == 0) return 'Not set';
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) return '${hours}h';
    return '${hours}h ${remainingMinutes}m';
  }

  // Format completion time
  String formatCompletionTime(String? completionTime) {
    if (completionTime == null) return '';
    try {
      final dateTime = DateTime.parse(completionTime);
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      return '';
    }
  }

  double getMonthlyProgress(Set<DateTime> completedDays) {
    final now = DateTime.now();
    final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final int completedDaysThisMonth = completedDays
        .where((date) => date.year == now.year && date.month == now.month)
        .length;

    if (daysInMonth == 0) {
      return 0.0;
    }
    return completedDaysThisMonth / daysInMonth;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Calendar",
          style: Theme.of(
            context,
          ).textTheme.labelMedium!.copyWith(color: Colors.grey[800]),
        ),

        backgroundColor: Colors.white,
      ),

      body: ValueListenableBuilder(
        valueListenable: MeditationDayHiveDB.meditationDays.listenable(),
        builder: (context, box, _) {
          final completedDays = getCompletedDays();
          final monthlyProgress = getMonthlyProgress(completedDays);
          final progressPercentage = (monthlyProgress * 100).toInt();

          return Flex(
            direction: Axis.vertical,

            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Monthly Progress',
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: Colors.grey[800],
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      '$progressPercentage%',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 255, 106, 0),
                      ),
                    ),
                  ],
                ),
              ),

              TableCalendar(
                calendarStyle: CalendarStyle(
                  selectedTextStyle: Theme.of(context).textTheme.labelMedium!,
                ),
                rowHeight: 60,

                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },

                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });

                  showModalBottomSheet(
                    context: context,
                    barrierColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) {
                      final String formattedDate = DateFormat(
                        'MMMM d, yyyy',
                      ).format(_focusedDay);

                      // Get actual meditation data for the selected day
                      final dayData = getDayMeditationData(selectedDay);
                      final isToday =
                          selectedDay.year == DateTime.now().year &&
                          selectedDay.month == DateTime.now().month &&
                          selectedDay.day == DateTime.now().day;

                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.45,
                        child: Card(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date header with today indicator
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        formattedDate,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 25,
                                            ),
                                      ),
                                    ),
                                    if (isToday)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Text(
                                          'TODAY',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Morning Slot with actual duration
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Morning Meditation',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium!
                                                .copyWith(
                                                  fontWeight: FontWeight.w200,
                                                  color: Colors.grey[800],
                                                  fontSize: 20,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (dayData['morningDuration'] >
                                                  0) ...[
                                                Text(
                                                  ' ${formatDuration(dayData['morningDuration'])} sitting completed at ${formatCompletionTime(dayData['morningCompletionTime'])}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        color:
                                                            const Color.fromARGB(
                                                              255,
                                                              58,
                                                              165,
                                                              61,
                                                            ),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ] else ...[
                                                Text(
                                                  'Default: ${intToTimeOfDay(SettingsHiveDB.getMorningTime()[0]).format(context).toLowerCase().replaceAll(" ", '')} - ${intToTimeOfDay(SettingsHiveDB.getMorningTime()[1]).format(context).toLowerCase().replaceAll(" ", '')}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        color: Colors.grey[600],
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    dayData['morningCompleted']
                                        ? Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.green,
                                            size: 28,
                                          )
                                        : Column(
                                            children: [
                                              Text(
                                                "⏰",
                                                style: TextStyle(fontSize: 20),
                                              ),
                                              Text(
                                                "Not Done",
                                                style: TextStyle(fontSize: 10),
                                              ),
                                            ],
                                          ),
                                  ],
                                ),

                                const Divider(height: 32, thickness: 1),

                                // Evening Slot with actual duration
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Evening Meditation',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium!
                                                .copyWith(
                                                  fontWeight: FontWeight.w200,
                                                  color: Colors.grey[800],
                                                  fontSize: 20,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (dayData['eveningDuration'] >
                                                  0) ...[
                                                Text(
                                                  '${formatDuration(dayData['eveningDuration'])} sitting completed at ${formatCompletionTime(dayData['eveningCompletionTime'])}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        color: Color.fromARGB(
                                                          255,
                                                          58,
                                                          165,
                                                          61,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ] else ...[
                                                Text(
                                                  'Default: ${intToTimeOfDay(SettingsHiveDB.getEveningTime()[0]).format(context).toLowerCase().replaceAll(" ", '')} - ${intToTimeOfDay(SettingsHiveDB.getEveningTime()[1]).format(context).toLowerCase().replaceAll(" ", '')}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        color: Colors.grey[600],
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    dayData['eveningCompleted']
                                        ? Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.green,
                                            size: 28,
                                          )
                                        : Column(
                                            children: [
                                              Text(
                                                "⏰",
                                                style: TextStyle(fontSize: 20),
                                              ),
                                              Text(
                                                "Not Done",
                                                style: TextStyle(fontSize: 10),
                                              ),
                                            ],
                                          ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Summary section
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                calendarBuilders: CalendarBuilders(
                  todayBuilder: (context, day, focusedDay) {
                    return Container(
                      margin: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: Colors.white, // Or any color you prefer
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).focusColor,
                          width: 2.0,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).focusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                  selectedBuilder: (context, day, focusedDay) {
                    return Container(
                      margin: const EdgeInsets.all(6.0),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).focusColor, // Use your app's primary color
                        borderRadius: BorderRadius.circular(15.0),
                        border: Border.all(
                          color: Theme.of(context).focusColor,
                          width: 2.0,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                  defaultBuilder: (context, day, focusedDay) {
                    // highlight completed days
                    if (completedDays.contains(
                      DateTime(day.year, day.month, day.day),
                    )) {
                      return Container(
                        margin: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '${day.day}',
                              style: Theme.of(
                                context,
                              ).textTheme.labelSmall!.copyWith(),
                            ),
                            Text('✅'),
                          ],
                        ),
                      );
                    }
                    return null; // default UI
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
