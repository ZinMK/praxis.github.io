import 'dart:ffi';

import 'package:hive/hive.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:meditation_scheduler/Provider/meditation_provider.dart';

class MeditationDayHiveDB {
  static final normalizedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  static final _key = normalizedDate.toIso8601String();
  // Box which will use to store the things
  static final meditationDays = Hive.box("meditation");

  // Create or add single data in hive

  // Create or add multiple data in hive

  // Get All data  stored in hive
  static bool getTodayMorningComplete() {
    return meditationDays.get(
      _key,
      defaultValue: {
        'morningCompleted': false,
        'eveningCompleted': false,
        'morningDuration': 0,
        'eveningDuration': 0,
      },
    )['morningCompleted'];
  }

  static List<bool> getThisDayCompleted(DateTime today) {
    final _newkey = today.toIso8601String();

    print(
      meditationDays.get(
        _newkey,
        defaultValue: {
          'morningCompleted': false,
          'eveningCompleted': false,
          'morningDuration': 0,
          'eveningDuration': 0,
        },
      )['morningCompleted'],
    );
    print(
      meditationDays.get(
        _newkey,
        defaultValue: {
          'morningCompleted': false,
          'eveningCompleted': false,
          'morningDuration': 0,
          'eveningDuration': 0,
        },
      )['eveningCompleted'],
    );

    return [
      meditationDays.get(
        _newkey,
        defaultValue: {
          'morningCompleted': false,
          'eveningCompleted': false,
          'morningDuration': 0,
          'eveningDuration': 0,
        },
      )['morningCompleted'],
      meditationDays.get(
        _newkey,
        defaultValue: {
          'morningCompleted': false,
          'eveningCompleted': false,
          'morningDuration': 0,
          'eveningDuration': 0,
        },
      )['eveningCompleted'],
    ];
  }

  static bool getTodayEveningComplete() {
    return meditationDays.get(
      _key,
      defaultValue: {
        'morningCompleted': false,
        'eveningCompleted': false,
        'morningDuration': 0,
        'eveningDuration': 0,
      },
    )['eveningCompleted'];
  }

  static void updateMorningAsComplete(int duration) async {
    Map<dynamic, dynamic> entry = await meditationDays.get(
      _key,
      defaultValue: {
        'morningCompleted': false,
        'eveningCompleted': false,
        'morningDuration': 0,
        'eveningDuration': 0,
      },
    );
    entry['morningCompleted'] = true;
    entry['morningDuration'] = duration;
    await meditationDays.put(_key, entry);
    print('morning Updated' + entry.toString());
  }

  static void updateEveningAsComplete(int duration) async {
    Map<dynamic, dynamic> entry = await meditationDays.get(
      _key,
      defaultValue: {
        'morningCompleted': false,
        'eveningCompleted': false,
        'morningDuration': 0,
        'eveningDuration': 0,
      },
    );
    entry['eveningCompleted'] = true;
    entry['eveningDuration'] = duration;
    await meditationDays.put(_key, entry);
    print('Evening Updated' + entry.toString());
  }

  static int getTotalMeditationMinutes() {
    int sumMinutes = 0;

    for (var entry in meditationDays.values) {
      final data = Map<String, dynamic>.from(entry);

      int morning = data['morningDuration'] ?? 0;
      int evening = data['eveningDuration'] ?? 0;

      sumMinutes += morning + evening;
    }

    return sumMinutes;
  }

  static void undoSlot(bool morning) async {
    Map<dynamic, dynamic> entry = await meditationDays.get(
      _key,
      defaultValue: {
        'morningCompleted': false,
        'eveningCompleted': false,
        'morningDuration': 0,
        'eveningDuration': 0,
      },
    );

    if (morning) {
      entry['morningCompleted'] = false;
      entry['morningDuration'] = 0;
    } else {
      entry['eveningCompleted'] = false;
      entry['eveningDuration'] = 0;
    }

    await meditationDays.put(_key, entry);
  }

  static int getTotalMeditationDays() {
    int sum_Complete_days = 0;
    for (int i = 0; i < meditationDays.length; i++) {
      Map<dynamic, dynamic> entry = meditationDays.get(
        meditationDays.keys.toList()[i],
        defaultValue: {
          'morningCompleted': false,
          'eveningCompleted': false,
          'morningDuration': 0,
          'eveningDuration': 0,
        },
      );

      if (entry['morningCompleted'] && entry['eveningCompleted']) {
        sum_Complete_days += 1;
      }
    }
    return sum_Complete_days;
  }
}
