import 'dart:math';

import 'package:hive/hive.dart';

class HiveMessagesClass {
  static final messagesBox = Hive.box("messages");

  // Add a new message to the box
  static void addMessage(String message) {
    // Use a timestamp down to the microsecond for a highly unique key
    final String key = DateTime.now().toIso8601String();
    messagesBox.put(key, {
      "message": message,
      "date": DateTime.now().toIso8601String(),
    });
  }

  // Get all messages as a Map of keys to their data
  static Map<dynamic, dynamic> getMessages() {
    return messagesBox.toMap();
  }

  // Get a list of all message data (excluding keys)
  static List<dynamic> getAllMessageData() {
    return messagesBox.values.toList();
  }

  // Delete a message by its key
  static void deleteMessage(String key) {
    messagesBox.delete(key);
  }

  // Get a single, random message and its key
  static Map<String, dynamic>? getRandomMessageWithKey() {
    final List<dynamic> keys = messagesBox.keys.toList();
    if (keys.isEmpty) {
      return null;
    }
    final random = Random();
    final randomKey = keys[random.nextInt(keys.length)];
    final messageData = messagesBox.get(randomKey);

    if (messageData != null) {
      return {
        'key': randomKey, // Include the key in the returned map
        'data': Map<String, dynamic>.from(messageData),
      };
    }
    return null;
  }
}
