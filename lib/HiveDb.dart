import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MeditationDayHiveDB {
  static final normalizedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  static final _key = normalizedDate.toIso8601String();
  // Box which will use to store the things
  static final meditationDays = Hive.box("meditation");

  // Check if day has changed and clear day-specific times if needed
  static Future<void> checkAndResetDaySpecificTimes() async {
    const String lastDateKey = 'lastAppDate';
    final String currentDate = DateTime.now().toIso8601String().split(
      'T',
    )[0]; // YYYY-MM-DD format

    final lastDate = meditationDays.get(lastDateKey);

    if (lastDate != currentDate) {
      // Day has changed, clear any existing day-specific times for today
      final entry = await meditationDays.get(
        _key,
        defaultValue: {
          'morningCompleted': false,
          'eveningCompleted': false,
          'morningDuration': 0,
          'eveningDuration': 0,
          'morningCompletionTime': null,
          'eveningCompletionTime': null,
          'morningStartTime': null,
          'morningEndTime': null,
          'eveningStartTime': null,
          'eveningEndTime': null,
        },
      );

      // Reset day-specific times to null
      entry['morningStartTime'] = null;
      entry['morningEndTime'] = null;
      entry['eveningStartTime'] = null;
      entry['eveningEndTime'] = null;

      await meditationDays.put(_key, entry);
      await meditationDays.put(lastDateKey, currentDate);
    }
  }

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
        'morningCompletionTime': null,
        'eveningCompletionTime': null,
      },
    )['morningCompleted'];
  }

  static List<bool> getThisDayCompleted(DateTime today) {
    final _newkey = today.toIso8601String();

    return [
      meditationDays.get(
        _newkey,
        defaultValue: {
          'morningCompleted': false,
          'eveningCompleted': false,
          'morningDuration': 0,
          'eveningDuration': 0,
          'morningCompletionTime': null,
          'eveningCompletionTime': null,
        },
      )['morningCompleted'],
      meditationDays.get(
        _newkey,
        defaultValue: {
          'morningCompleted': false,
          'eveningCompleted': false,
          'morningDuration': 0,
          'eveningDuration': 0,
          'morningCompletionTime': null,
          'eveningCompletionTime': null,
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
        'morningCompletionTime': null,
        'eveningCompletionTime': null,
      },
    )['eveningCompleted'];
  }

  static Future<void> updateMorningAsComplete(int duration) async {
    Map<dynamic, dynamic> entry = await meditationDays.get(
      _key,
      defaultValue: {
        'morningCompleted': false,
        'eveningCompleted': false,
        'morningDuration': 0,
        'eveningDuration': 0,
        'morningCompletionTime': null,
        'eveningCompletionTime': null,
      },
    );
    entry['morningCompleted'] = true;
    entry['morningDuration'] = duration;
    entry['morningCompletionTime'] = DateTime.now().toIso8601String();
    await meditationDays.put(_key, entry);
  }

  static Future<void> updateEveningAsComplete(int duration) async {
    Map<dynamic, dynamic> entry = await meditationDays.get(
      _key,
      defaultValue: {
        'morningCompleted': false,
        'eveningCompleted': false,
        'morningDuration': 0,
        'eveningDuration': 0,
        'morningCompletionTime': null,
        'eveningCompletionTime': null,
      },
    );
    entry['eveningCompleted'] = true;
    entry['eveningDuration'] = duration;
    entry['eveningCompletionTime'] = DateTime.now().toIso8601String();
    await meditationDays.put(_key, entry);
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

  static Future<void> undoSlot(bool morning) async {
    Map<dynamic, dynamic> entry = await meditationDays.get(
      _key,
      defaultValue: {
        'morningCompleted': false,
        'eveningCompleted': false,
        'morningDuration': 0,
        'eveningDuration': 0,
        'morningCompletionTime': null,
        'eveningCompletionTime': null,
      },
    );

    if (morning) {
      entry['morningCompleted'] = false;
      entry['morningDuration'] = 0;
      entry['morningCompletionTime'] = null;
    } else {
      entry['eveningCompleted'] = false;
      entry['eveningDuration'] = 0;
      entry['eveningCompletionTime'] = null;
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

  // Day-specific time methods
  static Future<void> updateTodayMorningTimes(
    int startTime,
    int endTime,
  ) async {
    Map<dynamic, dynamic> entry = await meditationDays.get(
      _key,
      defaultValue: {
        'morningCompleted': false,
        'eveningCompleted': false,
        'morningDuration': 0,
        'eveningDuration': 0,
        'morningCompletionTime': null,
        'eveningCompletionTime': null,
        'morningStartTime': null,
        'morningEndTime': null,
        'eveningStartTime': null,
        'eveningEndTime': null,
      },
    );
    entry['morningStartTime'] = startTime;
    entry['morningEndTime'] = endTime;
    await meditationDays.put(_key, entry);
  }

  static Future<void> updateTodayEveningTimes(
    int startTime,
    int endTime,
  ) async {
    Map<dynamic, dynamic> entry = await meditationDays.get(
      _key,
      defaultValue: {
        'morningCompleted': false,
        'eveningCompleted': false,
        'morningDuration': 0,
        'eveningDuration': 0,
        'morningCompletionTime': null,
        'eveningCompletionTime': null,
        'morningStartTime': null,
        'morningEndTime': null,
        'eveningStartTime': null,
        'eveningEndTime': null,
      },
    );
    entry['eveningStartTime'] = startTime;
    entry['eveningEndTime'] = endTime;
    await meditationDays.put(_key, entry);
  }

  static List<int?> getTodayMorningTimes() {
    final entry = meditationDays.get(
      _key,
      defaultValue: {
        'morningCompleted': false,
        'eveningCompleted': false,
        'morningDuration': 0,
        'eveningDuration': 0,
        'morningCompletionTime': null,
        'eveningCompletionTime': null,
        'morningStartTime': null,
        'morningEndTime': null,
        'eveningStartTime': null,
        'eveningEndTime': null,
      },
    );
    return [entry['morningStartTime'], entry['morningEndTime']];
  }

  static List<int?> getTodayEveningTimes() {
    final entry = meditationDays.get(
      _key,
      defaultValue: {
        'morningCompleted': false,
        'eveningCompleted': false,
        'morningDuration': 0,
        'eveningDuration': 0,
        'morningCompletionTime': null,
        'eveningCompletionTime': null,
        'morningStartTime': null,
        'morningEndTime': null,
        'eveningStartTime': null,
        'eveningEndTime': null,
      },
    );
    return [entry['eveningStartTime'], entry['eveningEndTime']];
  }
}
