import 'dart:math';

import 'package:hive/hive.dart';

class HiveMessagesClass {
  static final messagesBox = Hive.box("messages");
  static const String _welcomeMessage =
      "Welcome to the App! you can add messages for yourself that will appear here.";

  // Initialize the welcome message if it doesn't exist
  static void _ensureWelcomeMessage() {
    if (!messagesBox.containsKey(1)) {
      messagesBox.put(1, {
        "message": _welcomeMessage,
        "date": DateTime.now().toIso8601String(),
      });
    }
  }

  // Add a new message to the box
  static void addMessage(String message) {
    // Ensure welcome message exists

    // Use a timestamp down to the microsecond for a highly unique key
    final key = messagesBox.keys.length + 1;
    messagesBox.put(key, {
      "message": message,
      "date": DateTime.now().toIso8601String(),
    });

    // Remove the welcome message after adding the first real message
    if (messagesBox.containsKey(1)) {
      messagesBox.delete(1);
    }
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
  static void deleteMessage(int key) {
    messagesBox.delete(key);
  }

  // Get a single, random message and its key
  static Map<String, dynamic>? getRandomMessageWithKey() {
    // Ensure welcome message exists
    // _ensureWelcomeMessage();

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

  // Get a random message different from the provided key (if possible)
  static Map<String, dynamic>? getRandomMessageWithKeyExcluding(
    int excludeKey,
  ) {
    final List<dynamic> keys = messagesBox.keys.toList();

    if (keys.isEmpty) return null;

    // Filter out excluded key and welcome message key "1" if there are 2+ messages
    final List<dynamic> pool = keys.length > 1
        ? keys.where((k) => k != excludeKey && k != 1).toList()
        : keys;

    if (pool.isEmpty) return null;

    final random = Random();
    final randomKey = pool[random.nextInt(pool.length)];

    final messageData = messagesBox.get(randomKey);

    if (messageData != null) {
      return {'key': randomKey, 'data': Map<String, dynamic>.from(messageData)};
    }

    return null;
  }

  // Helper to know if only the welcome message exists
  static bool hasOnlyWelcomeMessage() {
    _ensureWelcomeMessage();
    if (messagesBox.isEmpty) return false;
    if (messagesBox.length == 1) {
      final only = messagesBox.get(messagesBox.keys.first);
      if (only is Map && only["message"] == _welcomeMessage) return true;
    }
    return false;
  }
}
