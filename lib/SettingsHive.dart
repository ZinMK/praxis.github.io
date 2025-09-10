import 'package:hive/hive.dart';

class SettingsHiveDB {
  static final settings = Hive.box("settings");

  static Map<dynamic, dynamic> _getSettings() {
    return settings.get(
      "settings",
      defaultValue: {
        "morningStartTime": 900,
        "morningEndTime": 1000,
        "eveningStartTime": 1700,
        "eveningEndTime": 1800,
        "timersound": "Wave",
        "timerbackground": "default",
        "notifications": true,
      },
    );
  }

  static List getMorningTime() {
    final meditationDays = _getSettings();
    return [
      meditationDays['morningStartTime'],
      meditationDays['morningEndTime'],
    ];
  }

  static List getEveningTime() {
    final meditationDays = _getSettings();
    return [
      meditationDays['eveningStartTime'],
      meditationDays['eveningEndTime'],
    ];
  }

  static String getTimerSound() {
    return _getSettings()['timersound'];
  }

  static String getTimerBG() {
    return _getSettings()['timerbackground'];
  }

  static bool getNotifications() {
    return _getSettings()['notifications'];
  }

  static void updateMorningStartTime(int starthour) {
    final meditationDays = _getSettings();
    meditationDays['morningStartTime'] = starthour;
    settings.put("settings", meditationDays);
  }

  static void updateMorningEndTime(int endhour) {
    final meditationDays = _getSettings();
    meditationDays['morningEndTime'] = endhour;
    settings.put("settings", meditationDays);
  }

  static void updateEveningStartTime(int starthour) {
    final meditationDays = _getSettings();
    meditationDays['eveningStartTime'] = starthour;
    settings.put("settings", meditationDays);
  }

  static void updateEveningEndTime(int endhour) {
    final meditationDays = _getSettings();
    meditationDays['eveningEndTime'] = endhour;
    settings.put("settings", meditationDays);
  }

  static void updateTimer(String timer) {
    final meditationDays = _getSettings();
    meditationDays['timersound'] = timer;
    settings.put("settings", meditationDays);
  }

  static void updateTimerBG(String bg) {
    final meditationDays = _getSettings();
    meditationDays['timerbackground'] = bg;
    settings.put("settings", meditationDays);
  }

  static void updateNotifications(bool value) {
    final meditationDays = _getSettings();
    meditationDays['notifications'] = value;
    settings.put("settings", meditationDays);
  }
}
