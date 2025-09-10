import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:hive/hive.dart';

import 'package:meditation_scheduler/SettingsHive.dart';
import 'package:meditation_scheduler/services/notification_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

TimeOfDay intToTimeOfDay(int time) {
  // Pad with zeros so "930" becomes "0930"
  String timeStr = time.toString().padLeft(4, '0');

  int hour = int.parse(timeStr.substring(0, 2));
  int minute = int.parse(timeStr.substring(2, 4));

  return TimeOfDay(hour: hour, minute: minute);
}

class _SettingsPageState extends State<SettingsPage> {
  final Map<String, String> _soundFiles = {
    "Alarm": "Alarm.wav",
    "Wave": "Smooth.mp3",
    "Pluck": "pluck.mp3",
  };

  Map<String, String> reverse = {
    "Alarm.wav": "Alarm",
    "Smooth.mp3": "Wave",
    "pluck.mp3": "Pluck",
  };

  String? _selectedSound = SettingsHiveDB.getTimerSound();
  bool _remindersEnabled = SettingsHiveDB.getNotifications();

  late TimeOfDayRange _defaultScheduleMorning = TimeOfDayRange(
    start: intToTimeOfDay(SettingsHiveDB.getMorningTime()[0]),
    end: intToTimeOfDay(SettingsHiveDB.getMorningTime()[1]),
  );

  late TimeOfDayRange _defaultScheduleEvening = TimeOfDayRange(
    start: intToTimeOfDay(SettingsHiveDB.getEveningTime()[0]),
    end: intToTimeOfDay(SettingsHiveDB.getEveningTime()[1]),
  );

  @override
  void initState() {
    super.initState();
    // _audioPlayer.onPositionChanged.listen((position) {
    //   setState(() {
    //     _audioPosition = position.inSeconds.toDouble();
    //   });
    // });

    _defaultScheduleMorning = TimeOfDayRange(
      start: intToTimeOfDay(SettingsHiveDB.getMorningTime()[0]),
      end: intToTimeOfDay(SettingsHiveDB.getMorningTime()[1]),
    );
    ;
    _defaultScheduleEvening = TimeOfDayRange(
      start: intToTimeOfDay(SettingsHiveDB.getEveningTime()[0]),
      end: intToTimeOfDay(SettingsHiveDB.getEveningTime()[1]),
    );
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  double _audioPosition = 0.0;
  bool _isPlaying = false;
  late Color _selectedColor = Colors.black;

  final Map<String, TimeOfDayRange> _schedule = {
    "Monday": TimeOfDayRange(
      start: TimeOfDay(hour: 7, minute: 0),
      end: TimeOfDay(hour: 8, minute: 0),
    ),
    "Tuesday": TimeOfDayRange(
      start: TimeOfDay(hour: 7, minute: 0),
      end: TimeOfDay(hour: 8, minute: 0),
    ),
    "Wednesday": TimeOfDayRange(
      start: TimeOfDay(hour: 7, minute: 0),
      end: TimeOfDay(hour: 8, minute: 0),
    ),
    "Thursday": TimeOfDayRange(
      start: TimeOfDay(hour: 7, minute: 0),
      end: TimeOfDay(hour: 8, minute: 0),
    ),
    "Friday": TimeOfDayRange(
      start: TimeOfDay(hour: 7, minute: 0),
      end: TimeOfDay(hour: 8, minute: 0),
    ),
    "Saturday": TimeOfDayRange(
      start: TimeOfDay(hour: 7, minute: 0),
      end: TimeOfDay(hour: 8, minute: 0),
    ),
    "Sunday": TimeOfDayRange(
      start: TimeOfDay(hour: 7, minute: 0),
      end: TimeOfDay(hour: 8, minute: 0),
    ),
  };

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playPreview(String sound) async {
    await _audioPlayer.play(AssetSource(_soundFiles[sound]!));
    setState(() {
      _isPlaying = true;
      _selectedSound = sound;
    });
  }

  void _showSoundPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                  initialItem: _soundFiles.keys.toList().indexOf(
                    _selectedSound!,
                  ),
                ),
                onSelectedItemChanged: (index) {
                  final newSound = _soundFiles.keys.toList()[index];
                  SettingsHiveDB.updateTimer(_soundFiles[newSound]!);

                  _playPreview(newSound);
                },
                children: _soundFiles.keys
                    .map((s) => Center(child: Text(s)))
                    .toList(),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showDefaultTimePicker(bool isMorning) {
    final initialStart = isMorning
        ? _defaultScheduleMorning.start
        : _defaultScheduleEvening.start;
    ;
    final initialEnd = isMorning
        ? _defaultScheduleMorning.end
        : _defaultScheduleEvening.end;

    TimeOfDay? tempStart = initialStart;
    TimeOfDay? tempEnd = initialEnd;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Material(
        child: Container(
          height: 350,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Set Default Schedule",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.label.resolveFrom(context),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "Start",
                            style: TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.label.resolveFrom(context),
                            ),
                          ),
                          Expanded(
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.time,
                              initialDateTime: DateTime(
                                2023,
                                1,
                                1,
                                initialStart.hour,
                                initialEnd.minute,
                              ),
                              onDateTimeChanged: (val) {
                                tempStart = TimeOfDay(
                                  hour: val.hour,
                                  minute: val.minute,
                                );
                              },
                              itemExtent: 48,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "End",
                            style: TextStyle(
                              fontSize: 16,
                              color: CupertinoColors.label.resolveFrom(context),
                            ),
                          ),
                          Expanded(
                            child: CupertinoDatePicker(
                              mode: CupertinoDatePickerMode.time,
                              initialDateTime: DateTime(
                                2023,
                                1,
                                1,
                                initialEnd.hour,
                                initialEnd.minute,
                              ),
                              onDateTimeChanged: (val) {
                                tempEnd = TimeOfDay(
                                  hour: val.hour,
                                  minute: val.minute,
                                );
                              },
                              itemExtent: 48,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CupertinoButton(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CupertinoButton(
                      child: const Text("Save"),
                      onPressed: () {
                        setState(() {
                          if (isMorning) {
                            _defaultScheduleMorning = TimeOfDayRange(
                              start: tempStart!,
                              end: tempEnd!,
                            );

                            SettingsHiveDB.updateMorningStartTime(
                              tempStart!.hour * 100 + tempStart!.minute,
                            );

                            SettingsHiveDB.updateMorningEndTime(
                              tempEnd!.hour * 100 + tempEnd!.minute,
                            );
                          } else {
                            _defaultScheduleEvening = TimeOfDayRange(
                              start: tempStart!,
                              end: tempEnd!,
                            );

                            SettingsHiveDB.updateEveningStartTime(
                              tempStart!.hour * 100 + tempStart!.minute,
                            );

                            SettingsHiveDB.updateEveningEndTime(
                              tempEnd!.hour * 100 + tempEnd!.minute,
                            );
                          }

                          // Reschedule daily reminders with new times
                          if (_remindersEnabled) {
                            NotificationService().scheduleDailyReminders();
                          }
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmReset() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Reset Data"),
        content: const Text(
          "Are you sure you want to reset all meditation data?",
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              await Hive.deleteBoxFromDisk("messages");
              await Hive.deleteBoxFromDisk("meditation");
              await Hive.deleteBoxFromDisk("settings");
              Navigator.pop(context);
              // Reset logic here
            },
            child: const Text("Reset"),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            "Settings",
            style: Theme.of(
              context,
            ).textTheme.labelMedium!.copyWith(color: Colors.grey[800]),
          ),
          backgroundColor: CupertinoColors.systemBackground,
        ),
        backgroundColor: CupertinoColors.systemGroupedBackground,
        child: SafeArea(
          child: ListView(
            children: [
              CupertinoListSection(
                header: const Text("Sound"),
                backgroundColor: CupertinoColors.systemGroupedBackground,
                children: [
                  CupertinoListTile(
                    title: Text(
                      "Timer Sound",
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium!.copyWith(fontSize: 20),
                    ),
                    additionalInfo: Text(
                      _selectedSound!,
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                    onTap: _showSoundPicker,
                    backgroundColor: CupertinoColors.systemBackground,
                  ),
                ],
              ),
              CupertinoListSection(
                header: Text("Notifications"),
                backgroundColor: CupertinoColors.systemGroupedBackground,
                children: [
                  CupertinoListTile(
                    title: Text(
                      "Reminders",
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium!.copyWith(fontSize: 20),
                    ),
                    trailing: CupertinoSwitch(
                      value: _remindersEnabled,
                      onChanged: (val) async {
                        setState(() => _remindersEnabled = val);
                        SettingsHiveDB.updateNotifications(val);

                        // Schedule or cancel daily reminders based on setting
                        if (val) {
                          await NotificationService().scheduleDailyReminders();
                        } else {
                          await NotificationService().cancelDailyReminders();
                        }
                      },
                    ),
                    backgroundColor: CupertinoColors.systemBackground,
                  ),
                ],
              ),
              CupertinoListSection(
                header: Text("Default Schedule"),
                backgroundColor: CupertinoColors.systemGroupedBackground,
                children: [
                  CupertinoListTile(
                    title: Text(
                      "Morning Session Time",
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium!.copyWith(fontSize: 20),
                    ),
                    subtitle: Text(
                      "${_defaultScheduleMorning.start.format(context)} - ${_defaultScheduleMorning.end.format(context)}",
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: const Color.fromARGB(255, 38, 38, 38),
                        fontSize: 15,
                      ),
                    ),
                    onTap: () => _showDefaultTimePicker(true),
                    backgroundColor: CupertinoColors.systemBackground,
                  ),

                  CupertinoListTile(
                    title: Text(
                      "Evening Session Time",
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium!.copyWith(fontSize: 20),
                    ),
                    subtitle: Text(
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: const Color.fromARGB(255, 38, 38, 38),
                        fontSize: 15,
                      ),
                      "${_defaultScheduleEvening.start.format(context)} - ${_defaultScheduleEvening.end.format(context)}",
                    ),
                    onTap: () => _showDefaultTimePicker(false),
                    backgroundColor: CupertinoColors.systemBackground,
                  ),
                ],
              ),

              CupertinoListSection(
                header: const Text(
                  "Timer Background Color",
                  style: TextStyle(decoration: TextDecoration.none),
                ),
                backgroundColor: CupertinoColors.systemGroupedBackground,
                children: [
                  CupertinoListTile(
                    title: const Text(
                      "Default (white)",
                      style: TextStyle(decoration: TextDecoration.none),
                    ),
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    trailing: _selectedColor == CupertinoColors.activeBlue
                        ? const Icon(
                            CupertinoIcons.check_mark,
                            color: CupertinoColors.activeBlue,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedColor = Theme.of(
                          context,
                        ).scaffoldBackgroundColor;
                        SettingsHiveDB.updateTimerBG("default");
                      });
                    },
                    backgroundColor: CupertinoColors.systemBackground,
                  ),
                  CupertinoListTile(
                    title: const Text(
                      "Dark",
                      style: TextStyle(decoration: TextDecoration.none),
                    ),
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 33, 33, 33),
                        shape: BoxShape.circle,
                      ),
                    ),
                    trailing: _selectedColor == CupertinoColors.systemRed
                        ? const Icon(
                            CupertinoIcons.check_mark,
                            color: CupertinoColors.activeBlue,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedColor = CupertinoColors.systemRed;
                        SettingsHiveDB.updateTimerBG("dark");
                      });
                    },
                    backgroundColor: CupertinoColors.systemBackground,
                  ),
                ],
              ),

              CupertinoListSection(
                header: Text("General Information"),
                backgroundColor: CupertinoColors.systemGroupedBackground,
                children: [
                  CupertinoListTile(
                    title: Text(
                      "Look for Courses",
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium!.copyWith(fontSize: 19),
                    ),
                    onTap: () async {
                      try {
                        await launchUrl(
                          Uri.parse(
                            "https://www.dhamma.org/en-US/courses/search",
                          ),
                          mode: LaunchMode.externalApplication,
                        );
                      } catch (e) {
                        Exception(
                          'Could not launch  "https://www.dhamma.org/en-US/courses/search"',
                        );
                      }
                    },
                    backgroundColor: CupertinoColors.systemBackground,
                  ),
                  CupertinoListTile(
                    title: Text(
                      "Vipassana Research Institute",
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium!.copyWith(fontSize: 19),
                    ),
                    onTap: () async {
                      if (!await launchUrl(
                        Uri.parse("https://www.vridhamma.org/"),
                        mode: LaunchMode.externalApplication,
                      )) {
                        throw Exception(
                          'Could not launch  https://www.vridhamma.org/',
                        );
                      }
                    },
                    backgroundColor: CupertinoColors.systemBackground,
                  ),
                ],
              ),

              CupertinoListSection(
                header: Text("Privacy Policy"),
                backgroundColor: CupertinoColors.systemGroupedBackground,
                children: [
                  CupertinoListTile(
                    title: Text(
                      "Privacy Policy",
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium!.copyWith(fontSize: 19),
                    ),
                    trailing: Icon(
                      CupertinoIcons.arrow_up_right_square,
                      color: CupertinoColors.systemBlue,
                      size: 20,
                    ),
                    onTap: () async {
                      try {
                        await launchUrl(
                          Uri.parse(
                            "https://zinmk.github.io/praxis.github.io/",
                          ),
                          mode: LaunchMode.inAppBrowserView,
                        );
                      } catch (e) {
                        // Show error dialog if URL fails to launch
                        showCupertinoDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title: const Text("Error"),
                            content: const Text(
                              "Could not open Privacy Policy. Please check your internet connection and try again.",
                            ),
                            actions: [
                              CupertinoDialogAction(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    backgroundColor: CupertinoColors.systemBackground,
                  ),
                ],
              ),

              CupertinoListSection(
                header: const Text("Data"),
                backgroundColor: CupertinoColors.systemGroupedBackground,
                children: [
                  CupertinoListTile(
                    title: Text(
                      "Reset Data",
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontSize: 19,
                      ),
                    ),
                    onTap: _confirmReset,
                    backgroundColor: CupertinoColors.systemBackground,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimeOfDayRange {
  final TimeOfDay start;
  final TimeOfDay end;
  TimeOfDayRange({required this.start, required this.end});
}
