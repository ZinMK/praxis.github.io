import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:meditation_scheduler/HiveDb.dart';
import 'package:meditation_scheduler/Provider/meditation_provider.dart';
import 'package:meditation_scheduler/SettingsHive.dart';
import 'package:meditation_scheduler/TimerPage.dart';
import 'package:meditation_scheduler/widgets/elevatedbutton.dart';
import 'package:audioplayers/audioplayers.dart';

class TimerBar extends ConsumerStatefulWidget {
  final MeditationSlot meditationslot;

  const TimerBar({super.key, required this.meditationslot});

  @override
  ConsumerState<TimerBar> createState() => _TimerBarState();
}

TimeOfDay intToTimeOfDay(int time) {
  // Pad with zeros so "930" becomes "0930"
  String timeStr = time.toString().padLeft(4, '0');

  int hour = int.parse(timeStr.substring(0, 2));
  int minute = int.parse(timeStr.substring(2, 4));

  return TimeOfDay(hour: hour, minute: minute);
}

class _TimerBarState extends ConsumerState<TimerBar> {
  late TimeOfDay fromTime;
  late TimeOfDay toTime;
  bool _isExpanded = false;
  String? _selectedAudio;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Available guided meditation audio files with their durations (in minutes)
  final Map<String, Map<String, dynamic>> _guidedMeditationAudios = {
    'None (Manual Timer)': {
      'file': null,
      'duration': 0,
      'displayName': 'Manual Timer',
    },
    '10_M_ANP_Guided.mp3': {
      'file': 'Audio/10_M_ANP_Guided.mp3',
      'duration': 10,
      'displayName': '10 mins Anapana',
    },
    '1H_VPSN.mp3': {
      'file': 'Audio/1H_VPSN.mp3',
      'duration': 60,
      'displayName': '1h Vipassana',
    },
    'ANP_VPSN.mp3': {
      'file': 'Audio/ANP_VPSN.mp3',
      'duration': 64,
      'displayName': '1h Anpn & Vipsn',
    },
  };

  @override
  void initState() {
    super.initState();
    _selectedAudio = 'None (Manual Timer)'; // Default to manual timer
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Duration get duration {
    // If guided meditation is selected, use its duration
    if (_selectedAudio != null && _selectedAudio != 'None (Manual Timer)') {
      final audioData = _guidedMeditationAudios[_selectedAudio];
      if (audioData != null) {
        return Duration(minutes: audioData['duration']);
      }
    }

    // Otherwise use the time range duration
    final from = DateTime(2025, 1, 1, fromTime.hour, fromTime.minute);
    final to = DateTime(2025, 1, 1, toTime.hour, toTime.minute);
    return to.difference(from);
  }

  void markAsDone() {
    setState(() {
      if (widget.meditationslot == MeditationSlot.morning) {
        MeditationDayHiveDB.updateMorningAsComplete(duration.inMinutes);
      } else {
        MeditationDayHiveDB.updateEveningAsComplete(duration.inMinutes);
      }
    });
  }

  void _playAudioPreview(String audioKey) async {
    final audioData = _guidedMeditationAudios[audioKey];
    if (audioData != null && audioData['file'] != null) {
      try {
        await _audioPlayer.play(AssetSource(audioData['file']));
        // Stop preview after 10 seconds
        Future.delayed(Duration(seconds: 10), () {
          _audioPlayer.stop();
        });
      } catch (e) {
        print('Error playing preview: $e');
      }
    }
  }

  void _stopAudioPreview() {
    _audioPlayer.stop();
  }

  void _selectAudio(String audioKey) {
    setState(() {
      _selectedAudio = audioKey;
    });
    _stopAudioPreview();
  }

  Future _openEditSheet() async {
    await showCupertinoModalPopup(
      context: context,
      builder: (context) {
        TimeOfDay tempFrom = fromTime;
        TimeOfDay tempTo = toTime;
        bool isAdjustingFromTime = true;

        return Material(
          borderRadius: BorderRadius.circular(30),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: StatefulBuilder(
                builder: (context, setModalState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isAdjustingFromTime
                                ? "Set Start Time"
                                : "Set End Time",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.label,
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Text("Save"),
                            onPressed: () {
                              setState(() {
                                fromTime = tempFrom;
                                toTime = tempTo;

                                if (widget.meditationslot ==
                                    MeditationSlot.morning) {
                                  SettingsHiveDB.updateMorningStartTime(
                                    fromTime.hour * 100 + fromTime.minute,
                                  );
                                  SettingsHiveDB.updateMorningEndTime(
                                    toTime.hour * 100 + toTime.minute,
                                  );
                                } else {
                                  SettingsHiveDB.updateEveningStartTime(
                                    fromTime.hour * 100 + fromTime.minute,
                                  );
                                  SettingsHiveDB.updateEveningEndTime(
                                    toTime.hour * 100 + toTime.minute,
                                  );
                                }
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      SizedBox(
                        height: 100,

                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.time,
                          initialDateTime: DateTime(
                            2023,
                            1,
                            1,
                            isAdjustingFromTime ? tempFrom.hour : tempTo.hour,
                            isAdjustingFromTime
                                ? tempFrom.minute
                                : tempTo.minute,
                          ),
                          onDateTimeChanged: (dateTime) {
                            setModalState(() {
                              if (isAdjustingFromTime) {
                                tempFrom = TimeOfDay(
                                  hour: dateTime.hour,
                                  minute: dateTime.minute,
                                );
                              } else {
                                tempTo = TimeOfDay(
                                  hour: dateTime.hour,
                                  minute: dateTime.minute,
                                );
                              }
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      CupertinoButton(
                        child: Text(isAdjustingFromTime ? "Next" : "Back"),
                        onPressed: () {
                          setModalState(() {
                            isAdjustingFromTime = !isAdjustingFromTime;
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool iscompleted;

    if (widget.meditationslot == MeditationSlot.morning) {
      iscompleted = MeditationDayHiveDB.getTodayMorningComplete();
    } else {
      iscompleted = MeditationDayHiveDB.getTodayEveningComplete();
    }

    return GestureDetector(
      onLongPress: _openEditSheet,
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        width: double.infinity,

        /// alignment: Alignment.topCenter,
        height: _isExpanded ? 250 : 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).hintColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder(
                valueListenable: Hive.box('settings').listenable(),
                builder: (context, value, child) {
                  if (widget.meditationslot == MeditationSlot.morning) {
                    fromTime = intToTimeOfDay(
                      SettingsHiveDB.getMorningTime()[0],
                    );
                    toTime = intToTimeOfDay(SettingsHiveDB.getMorningTime()[1]);
                  } else {
                    fromTime = intToTimeOfDay(
                      SettingsHiveDB.getEveningTime()[0],
                    );
                    toTime = intToTimeOfDay(SettingsHiveDB.getEveningTime()[1]);
                  }
                  return Text(
                    "${fromTime.format(context).toLowerCase().replaceAll(" ", '')} - ${toTime.format(context).toLowerCase().replaceAll(" ", '')}",
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium!.copyWith(color: Colors.white),
                  );
                },
              ),

              // Audio selection section (only show when expanded)
              if (_isExpanded) ...[
                SizedBox(height: 15),
                Text(
                  "Guided Meditation Audio",
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10),
                Flexible(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _guidedMeditationAudios.length,
                    itemBuilder: (context, index) {
                      final audioKey = _guidedMeditationAudios.keys.elementAt(
                        index,
                      );
                      final audioData = _guidedMeditationAudios[audioKey]!;
                      final isSelected = _selectedAudio == audioKey;

                      return Container(
                        margin: EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () => _selectAudio(audioKey),
                          onLongPress: audioData['file'] != null
                              ? () => _playAudioPreview(audioKey)
                              : null,
                          child: Container(
                            width: 100,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isSelected
                                  ? Color.fromARGB(255, 249, 223, 156)
                                  : Colors.white.withOpacity(0.2),
                              border: isSelected
                                  ? Border.all(
                                      color: Color.fromARGB(255, 92, 7, 1),
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Center(
                              child: SingleChildScrollView(
                                child: Text(
                                  audioData['displayName'],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Color.fromARGB(255, 92, 7, 1)
                                        : Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 1),
                        curve: Curves.easeInOut,
                        width: iscompleted ? 200 : 120,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            elevation: const WidgetStatePropertyAll(0),
                            foregroundColor: WidgetStateProperty.all(
                              Colors.white,
                            ),
                            backgroundColor: WidgetStateProperty.all(
                              const Color.fromARGB(255, 249, 223, 156),
                            ),
                          ),
                          onPressed: () {
                            if (iscompleted) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    title: Text(
                                      "Meditation Completed",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    content: Text(
                                      "This meditation session is marked as complete. Do you want to undo?",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(fontSize: 16, height: 1.4),
                                    ),
                                    actionsPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    actions: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                            ),
                                            onPressed: () {
                                              Navigator.of(
                                                context,
                                              ).pop(); // just close
                                            },
                                            child: const Text(
                                              "Back",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                            ),
                                            onPressed: () {
                                              // Undo completion
                                              setState(() {
                                                if (widget.meditationslot ==
                                                    MeditationSlot.morning) {
                                                  MeditationDayHiveDB.undoSlot(
                                                    true,
                                                  );
                                                } else {
                                                  MeditationDayHiveDB.undoSlot(
                                                    false,
                                                  );
                                                }
                                              });
                                              Navigator.of(
                                                context,
                                              ).pop(); // close dialog
                                            },
                                            child: const Text(
                                              "UNDO",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              markAsDone();
                            }
                          },

                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 1),
                            child: Text(
                              iscompleted ? "Completed ✅" : "Mark as done ✅",
                              key: ValueKey(iscompleted),
                              style: Theme.of(context).textTheme.labelSmall!
                                  .copyWith(
                                    color: const Color.fromARGB(255, 92, 7, 1),
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    !iscompleted
                        ? Expanded(
                            child: ElevatedButton_widget(
                              input: "Start",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => TimerPage(
                                          duration: duration,
                                          slot: widget.meditationslot,
                                          selectedAudio:
                                              _selectedAudio !=
                                                  'None (Manual Timer)'
                                              ? _guidedMeditationAudios[_selectedAudio]!['displayName']
                                                    .toString()
                                              : null,
                                        ),
                                    transitionsBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                          child,
                                        ) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          );
                                        },
                                    transitionDuration: const Duration(
                                      milliseconds: 1000,
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
