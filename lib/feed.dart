import 'dart:core';
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
    final totalHeight = MediaQuery.of(context).size.height;
    // final childCount = 6; // how many main children

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.all(UniversalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: totalHeight * 0.05),
            Text(
              'You meditated for',
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: Theme.of(context).focusColor,
              ),
              overflow: TextOverflow.visible,
            ),
            SizedBox(height: totalHeight * 0.01),
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
                    SizedBox(width: totalHeight * 0.02),
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
            SizedBox(height: totalHeight * 0.02),

            // Today Section
            //
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

            SizedBox(height: totalHeight * 0.01),
            Flexible(
              child: ListView(
                padding: EdgeInsets.all(0),
                physics: NeverScrollableScrollPhysics(), // disable
                shrinkWrap: true,
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      return TimerBar(meditationslot: MeditationSlot.morning);
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Consumer(
                    builder: (context, ref, child) {
                      return TimerBar(meditationslot: MeditationSlot.evening);
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Text(
                    overflow: TextOverflow.visible,
                    "Message from you",
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: Theme.of(context).focusColor,
                    ),
                  ),
                  SizedBox(height: totalHeight * 0.01),
                  SizedBox(
                    height: totalHeight * 0.2,
                    child: ValueListenableBuilder(
                      valueListenable: Hive.box('messages').listenable(),
                      builder: (context, value, child) {
                        final box = Hive.box('messages');
                        return _RandomMessageTile(key: ValueKey(box.length));
                      },
                    ),
                  ),
                  SizedBox(height: totalHeight * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                    children: [
                      Column(
                        children: [
                          IconButton(
                            onPressed: () {
                              final TextEditingController messageController =
                                  TextEditingController();

                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shadowColor: Colors.white,
                                    backgroundColor: Colors.white,
                                    title: const Text('Add a Message'),

                                    content: TextField(
                                      controller: messageController,
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
                                              if (messageController
                                                  .text
                                                  .isNotEmpty) {
                                                // Add the message to Hive
                                                HiveMessagesClass.addMessage(
                                                  messageController.text,
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
                            "add message",
                            style: Theme.of(context).textTheme.labelSmall!
                                .copyWith(
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
                            style: Theme.of(context).textTheme.labelSmall!
                                .copyWith(
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
                            "calendar",
                            style: Theme.of(context).textTheme.labelSmall!
                                .copyWith(
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
          ],
        ),
      ),
    );
  }
}

class _RandomMessageTile extends StatefulWidget {
  const _RandomMessageTile({super.key});
  @override
  State<_RandomMessageTile> createState() => _RandomMessageTileState();
}

class _RandomMessageTileState extends State<_RandomMessageTile> {
  String _currentMessage =
      "Welcome to the App! you can add messages for yourself that will appear here.";

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  void _loadInitial() {
    // If there are messages, pick a random one; if none, show welcome text
    final random = HiveMessagesClass.getRandomMessageWithKeyExcluding(1);
    if (random != null) {
      setState(() {
        _currentMessage = random['data']['message'];
      });
    } else {
      // If no messages exist, set the welcome message key
      setState(() {
        _currentMessage =
            "Welcome to the App! you can add messages for yourself that will appear here.";
      });
    }
  }

  void _nextRandom() {
    final next = HiveMessagesClass.getRandomMessageWithKeyExcluding(1);
    if (next != null) {
      setState(() {
        _currentMessage = next['data']['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _nextRandom,
      child: InfoTab(
        input: _currentMessage,
        textColor: const Color.fromARGB(255, 92, 7, 1),
        outsideColor: const Color.fromARGB(255, 249, 223, 156),
        insideColor: Theme.of(context).hintColor,
      ),
    );
  }
}
