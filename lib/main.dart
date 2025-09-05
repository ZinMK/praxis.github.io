import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meditation_scheduler/HiveMessages.dart';
import 'package:meditation_scheduler/services/notification_service.dart';
import 'package:meditation_scheduler/SettingsHive.dart';

import 'package:meditation_scheduler/feed.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  await Hive.openBox("meditation");
  await Hive.openBox("settings");

  await Hive.openBox("messages");
  HiveMessagesClass.addMessage(
    "Welcome to the App! You can add messages for yourself that will appear here randomly.",
  );

  // Initialize notification service
  await NotificationService().initialize();

  // Schedule daily reminders if notifications are enabled
  if (SettingsHiveDB.getNotifications()) {
    await NotificationService().scheduleDailyReminders();
  }

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App is in foreground
        NotificationService().updateAppState(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App is in background or closed
        NotificationService().updateAppState(false);
        break;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praxis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        buttonTheme: ButtonThemeData(
          buttonColor: const Color.fromARGB(255, 255, 217, 119),
        ),
        hintColor: Color.fromARGB(255, 255, 160, 7),
        textTheme: TextTheme(
          labelLarge: GoogleFonts.nunito(
            fontSize: 50,
            color: Color.fromARGB(255, 255, 106, 0),
            fontWeight: FontWeight.w800,
          ),
          labelMedium: GoogleFonts.nunito(
            fontSize: 25,
            color: Color.fromARGB(255, 255, 106, 0),
            fontWeight: FontWeight.w800,
          ),
          labelSmall: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 106, 0),
          ),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 254, 243),
        focusColor: const Color.fromARGB(255, 241, 143, 5),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).focusColor,
                        blurRadius: 40,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 100,
                    backgroundImage: AssetImage("assets/lotus.png"),
                  ),
                ),
              ],
            ),
          ),

          //
          Column(
            children: [
              Text("Praxis", style: Theme.of(context).textTheme.labelLarge),
              Text(
                "one day at a time",
                style: Theme.of(context).textTheme.labelSmall,
              ),
              SizedBox(height: 40),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).hintColor,
                  ),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return FeedPage();
                      },
                    ),
                  );
                },
                child: Text(
                  'Continue',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall!.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
