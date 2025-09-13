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
import 'package:meditation_scheduler/navigationBar.dart';

import 'package:meditation_scheduler/widgets/TimerBar.dart';

import 'package:meditation_scheduler/widgets/infotabs.dart';
import 'package:intl/intl.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

DateTime now = DateTime.now();

class _FeedPageState extends ConsumerState<FeedPage> {
  @override
  Widget build(BuildContext context) {
    final totalHeight = MediaQuery.of(context).size.height;

    // final childCount = 6; // how many main children

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.all(UniversalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: totalHeight * 0.03),
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
                                input: MeditationDayHiveDB.formatMeditationDays(
                                  MeditationDayHiveDB.getTotalMeditationDays(),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: totalHeight * 0.02),
                        Expanded(
                          child: InfoTab(
                            input: MeditationDayHiveDB.formatMeditationHours(
                              (MeditationDayHiveDB.getTotalMeditationMinutes() /
                                      60)
                                  .round(),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: totalHeight * 0.01),
                // Today Section
                //
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          overflow: TextOverflow.visible,
                          "Today ${DateFormat("MMM, dd").format(DateTime.now())}",
                          style: Theme.of(context).textTheme.labelMedium!
                              .copyWith(color: Theme.of(context).focusColor),
                        ),

                        SizedBox(width: 20),
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
                                entry['morningCompleted'] &&
                                entry['eveningCompleted'];

                            return todayCompleted
                                ? Flexible(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: const Color.fromARGB(
                                          255,
                                          55,
                                          208,
                                          60,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        child: Text(
                                          overflow: TextOverflow.visible,
                                          "Completed 🎉",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall!
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
                    Consumer(
                      builder: (context, ref, child) {
                        return TimerBar(meditationslot: MeditationSlot.morning);
                      },
                    ),
                    SizedBox(height: totalHeight * 0.005),
                    Consumer(
                      builder: (context, ref, child) {
                        return TimerBar(meditationslot: MeditationSlot.evening);
                      },
                    ),
                  ],
                ),
                SizedBox(height: totalHeight * 0.01),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overflow: TextOverflow.visible,
                      "Message from you",
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: Theme.of(context).focusColor,
                      ),
                    ),
                    SizedBox(height: totalHeight * 0.01),
                    SizedBox(
                      height: totalHeight * 0.18,
                      child: ValueListenableBuilder(
                        valueListenable: Hive.box('messages').listenable(),
                        builder: (context, value, child) {
                          final box = Hive.box('messages');
                          return _RandomMessageTile(key: ValueKey(box.length));
                        },
                      ),
                    ),
                    SizedBox(height: totalHeight * 0.01),
                    Navbar(),
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
    // Get a random message (will include welcome message if no user messages exist)
    final random = HiveMessagesClass.getRandomMessageWithKeyExcluding(1);
    if (random != null) {
      setState(() {
        _currentMessage = random['data']['message'];
      });
    } else {
      // Fallback to welcome message if something goes wrong
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
