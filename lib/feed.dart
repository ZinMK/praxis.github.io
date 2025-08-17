import 'package:flutter/material.dart';
import 'package:meditation_scheduler/Contants.dart';

import 'package:meditation_scheduler/widgets/TimerBar.dart';

import 'package:meditation_scheduler/widgets/infotabs.dart';
import 'package:intl/intl.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

DateTime now = DateTime.now();
double iconSize = 28;

class _FeedPageState extends State<FeedPage> {
  String formattedDate = DateFormat("MMM, dd").format(now);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(UniversalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: 50),
            Text(
              'You meditated for',
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: Theme.of(context).focusColor,
              ),
            ),

            //Top Section
            Row(
              children: [
                Expanded(child: InfoTab(input: "30 days")),
                SizedBox(width: 20),
                Expanded(child: InfoTab(input: "20 hours")),
              ],
            ),

            // Today Section
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Today ${formattedDate}",
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Theme.of(context).focusColor,
                  ),
                ),
                SizedBox(width: 15),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color.fromARGB(255, 55, 208, 60),
                    shape: BoxShape.rectangle,
                  ),
                  child: Padding(
                    padding: EdgeInsetsGeometry.fromLTRB(4, 2, 4, 2),
                    child: Text(
                      "Completed 🎉",
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            TimerBar(),
            TimerBar(),
            Text(
              "Message from you",
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: Theme.of(context).focusColor,
              ),
            ),
            SizedBox(
              height: 150,
              child: InfoTab(
                input:
                    "You are doing great! Keep going you got this you got this so much you are the best! You are the best!",
                textColor: const Color.fromARGB(255, 92, 7, 1),
                outsideColor: Color.fromARGB(255, 249, 223, 156),
                insideColor: Theme.of(context).hintColor,
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                Column(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Image.asset(
                        'assets/chat.png',
                        width: iconSize,

                        color: const Color.fromARGB(255, 255, 162, 0),
                      ),
                    ),
                    Text(
                      "New Message",
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 77, 51, 7),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Image.asset(
                        'assets/setting.png',
                        width: iconSize,
                        color: const Color.fromARGB(255, 255, 162, 0),
                      ),
                    ),
                    Text(
                      "settings",
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 77, 51, 7),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Image.asset(
                        'assets/calendar.png',
                        width: iconSize,
                        color: const Color.fromARGB(255, 255, 162, 0),
                      ),
                    ),
                    Text(
                      "Calendar",
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
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
