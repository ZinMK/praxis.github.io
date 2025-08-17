import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meditation_scheduler/TimerPage.dart';
import 'package:meditation_scheduler/widgets/elevatedbutton.dart';

class TimerBar extends StatefulWidget {
  const TimerBar({super.key});

  @override
  State<TimerBar> createState() => _TimerBarState();
}

class _TimerBarState extends State<TimerBar> {
  bool isCompleted = false;
  TimeOfDay fromTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay toTime = const TimeOfDay(hour: 14, minute: 0);

  void markAsDone() {
    setState(() {
      isCompleted = true;
    });
  }

  Duration get duration {
    final from = DateTime(2025, 1, 1, fromTime.hour, fromTime.minute);
    final to = DateTime(2025, 1, 1, toTime.hour, toTime.minute);
    return to.difference(from);
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

  // Future<void> _openEditSheet() async {
  //   await showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       TimeOfDay tempFrom = fromTime;
  //       TimeOfDay tempTo = toTime;

  //       return Padding(
  //         padding: MediaQuery.of(context).viewInsets,
  //         child: StatefulBuilder(
  //           builder: (context, setModalState) {
  //             return Container(
  //               padding: const EdgeInsets.all(20),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   const Text(
  //                     "Adjust Meditation Time",
  //                     style: TextStyle(
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 20),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text("From: ${tempFrom.format(context)}"),
  //                       ElevatedButton(
  //                         onPressed: () async {
  //                           final picked = await showTimePicker(
  //                             context: context,
  //                             initialTime: tempFrom,
  //                           );
  //                           if (picked != null) {
  //                             setModalState(() => tempFrom = picked);
  //                           }
  //                         },
  //                         child: const Text("Pick"),
  //                       ),
  //                     ],
  //                   ),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text("To: ${tempTo.format(context)}"),
  //                       ElevatedButton(
  //                         onPressed: () async {
  //                           final picked = await showTimePicker(
  //                             context: context,
  //                             initialTime: tempTo,
  //                           );
  //                           if (picked != null) {
  //                             setModalState(() => tempTo = picked);
  //                           }
  //                         },
  //                         child: const Text("Pick"),
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 20),
  //                   ElevatedButton(
  //                     onPressed: () {
  //                       setState(() {
  //                         fromTime = tempFrom;
  //                         toTime = tempTo;
  //                       });
  //                       Navigator.pop(context);
  //                     },
  //                     child: const Text("Save"),
  //                   ),
  //                 ],
  //               ),
  //             );
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _openEditSheet,
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        width: 9999,
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).hintColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${fromTime.format(context).toLowerCase().replaceAll(" ", '')} - ${toTime.format(context).toLowerCase().replaceAll(" ", '')}",
                style: Theme.of(
                  context,
                ).textTheme.labelMedium!.copyWith(color: Colors.white),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 1),
                        curve: Curves.easeInOut,
                        width: isCompleted ? 200 : 120,
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
                          onPressed: markAsDone,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 1),
                            child: Text(
                              isCompleted ? "Completed 🎉" : "Mark as done ✅",
                              key: ValueKey(isCompleted),
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
                    !isCompleted
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
                                        ) => TimerPage(duration: duration),
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
                                ).then((_) => markAsDone());
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
