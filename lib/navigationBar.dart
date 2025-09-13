import 'package:flutter/material.dart';
import 'package:meditation_scheduler/HiveMessages.dart';
import 'package:meditation_scheduler/Settings.dart';
import 'package:meditation_scheduler/calendar.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  @override
  Widget build(BuildContext context) {
    double iconSize = MediaQuery.of(context).size.width * 0.07;
    double fontsize = MediaQuery.of(context).size.width * 0.035;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
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
                          hintText: 'Remember to be kind to yourself...',
                          hintStyle: TextStyle(fontSize: 14),
                        ),
                        autofocus: true,
                      ),
                      actions: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              child: Text(
                                'Cancel',
                                style: Theme.of(context).textTheme.labelMedium!
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
                                style: Theme.of(
                                  context,
                                ).textTheme.labelMedium!.copyWith(fontSize: 18),
                              ),
                              onPressed: () {
                                if (messageController.text.isNotEmpty) {
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
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                fontSize: fontsize,
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(255, 77, 51, 7),
              ),
            ),
          ],
        ),
        Column(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
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
                fontSize: fontsize,
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(255, 77, 51, 7),
              ),
            ),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
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
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(255, 77, 51, 7),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
