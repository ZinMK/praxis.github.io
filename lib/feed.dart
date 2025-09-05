import 'dart:core';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meditation_scheduler/Contants.dart';
import 'package:meditation_scheduler/HiveDb.dart';
import 'package:meditation_scheduler/HiveMessages.dart';
import 'package:meditation_scheduler/Provider/meditation_provider.dart';
import 'package:meditation_scheduler/Settings.dart';
import 'package:meditation_scheduler/calendar.dart';

import 'package:meditation_scheduler/widgets/TimerBar.dart';

import 'package:meditation_scheduler/widgets/infotabs.dart';
import 'package:intl/intl.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

DateTime now = DateTime.now();
double iconSize = 28;

class _FeedPageState extends ConsumerState<FeedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.all(UniversalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Text(
              'You meditated for',
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: Theme.of(context).focusColor,
              ),
              overflow: TextOverflow.visible,
            ),

            //Top Section
            ValueListenableBuilder(
              valueListenable: Hive.box("meditation").listenable(),
              builder: (context, value, child) {
                return Row(
                  children: [
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, child) {
                          return InfoTab(
                            input:
                                '${MeditationDayHiveDB.getTotalMeditationDays()} days',
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: InfoTab(
                        input:
                            "${(MeditationDayHiveDB.getTotalMeditationMinutes() / 60).toStringAsFixed(0)} hours",
                      ),
                    ),
                  ],
                );
              },
            ),

            // Today Section
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  overflow: TextOverflow.visible,
                  "Today ${DateFormat("MMM, dd").format(DateTime.now())}",
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Theme.of(context).focusColor,
                  ),
                ),
                SizedBox(width: 15),
                ValueListenableBuilder(
                  valueListenable: Hive.box("meditation").listenable(),
                  builder: (context, Box box, _) {
                    final normalizedDate = DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                    );
                    final key = normalizedDate.toIso8601String();

                    final entry = box.get(
                      key,
                      defaultValue: {
                        'morningCompleted': false,
                        'eveningCompleted': false,
                        'morningDuration': 0,
                        'eveningDuration': 0,
                      },
                    );

                    final todayCompleted =
                        entry['morningCompleted'] && entry['eveningCompleted'];

                    return todayCompleted
                        ? Flexible(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: const Color.fromARGB(255, 55, 208, 60),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Text(
                                  overflow: TextOverflow.visible,
                                  "Completed 🎉",
                                  style: Theme.of(context).textTheme.labelSmall!
                                      .copyWith(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                ),
                              ),
                            ),
                          )
                        : Container();
                  },
                ),
              ],
            ),

            Consumer(
              builder: (context, ref, child) {
                return TimerBar(meditationslot: MeditationSlot.morning);
              },
            ),

            Consumer(
              builder: (context, ref, child) {
                return TimerBar(meditationslot: MeditationSlot.evening);
              },
            ),
            Text(
              overflow: TextOverflow.visible,
              "Message from you",
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: Theme.of(context).focusColor,
              ),
            ),
            SizedBox(
              height: 150,
              child: ValueListenableBuilder(
                valueListenable: Hive.box('messages').listenable(),
                builder: (context, value, child) {
                  var data = HiveMessagesClass.getRandomMessageWithKey();
                  return GestureDetector(
                    onTap: () {},
                    child: InfoTab(
                      input: data!["data"]['message'],
                      textColor: const Color.fromARGB(255, 92, 7, 1),
                      outsideColor: Color.fromARGB(255, 249, 223, 156),
                      insideColor: Theme.of(context).hintColor,
                    ),
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        final TextEditingController _messageController =
                            TextEditingController();

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shadowColor: Colors.white,
                              backgroundColor: Colors.white,
                              title: const Text('Add a Message'),

                              content: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText:
                                      'Remember to be kind to yourself...',
                                  hintStyle: TextStyle(fontSize: 14),
                                ),
                                autofocus: true,
                              ),
                              actions: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton(
                                      child: Text(
                                        'Cancel',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium!
                                            .copyWith(
                                              color: const Color.fromARGB(
                                                255,
                                                90,
                                                90,
                                                90,
                                              ),
                                              fontSize: 18,
                                            ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),

                                    TextButton(
                                      child: Text(
                                        'Add',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium!
                                            .copyWith(fontSize: 18),
                                      ),
                                      onPressed: () {
                                        if (_messageController
                                            .text
                                            .isNotEmpty) {
                                          // Add the message to Hive
                                          HiveMessagesClass.addMessage(
                                            _messageController.text,
                                          );
                                          Navigator.of(context).pop();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: Image.asset(
                        'assets/chat.png',
                        width: iconSize,

                        color: const Color.fromARGB(255, 255, 162, 0),
                      ),
                    ),
                    Text(
                      overflow: TextOverflow.visible,
                      "Add Message",
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 77, 51, 7),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return SettingsPage();
                            },
                          ),
                        );
                      },
                      icon: Image.asset(
                        'assets/setting.png',
                        width: iconSize,
                        color: const Color.fromARGB(255, 255, 162, 0),
                      ),
                    ),
                    Text(
                      overflow: TextOverflow.visible,
                      "settings",
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 77, 51, 7),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return CalendarPage();
                            },
                          ),
                        );
                      },
                      icon: Image.asset(
                        'assets/calendar.png',
                        width: iconSize,
                        color: const Color.fromARGB(255, 255, 162, 0),
                      ),
                    ),
                    Text(
                      overflow: TextOverflow.visible,
                      "Calendar",
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 77, 51, 7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
