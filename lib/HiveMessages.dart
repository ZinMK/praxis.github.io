import 'dart:math';

import 'package:hive/hive.dart';

class HiveMessagesClass {
  static final messagesBox = Hive.box("messages");
  static const String _welcomeMessage =
      "Welcome to the App! you can add messages for yourself that will appear here.";

  // Initialize the welcome message if it doesn't exist and no user messages exist
  static void _ensureWelcomeMessage() {
    // Only add welcome message if box is completely empty
    if (messagesBox.isEmpty) {
      messagesBox.put(1, {
        "message": _welcomeMessage,
        "date": DateTime.now().toIso8601String(),
      });
    }
  }

  // Call this once when the app starts to ensure welcome message exists
  static void initializeWelcomeMessage() {
    _ensureWelcomeMessage();
  }

  // Add a new message to the box
  static void addMessage(String message) {
    // Remove welcome message if it exists (user is adding their first real message)
    if (messagesBox.containsKey(1)) {
      messagesBox.delete(1);
    }

    // Generate a unique key that's within Hive's integer range
    int key = 2; // Start from 2 (1 is reserved for welcome message)
    while (messagesBox.containsKey(key)) {
      key++;
    }

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
  static void deleteMessage(int key) {
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

  // Get a random message different from the provided key (if possible)
  static Map<String, dynamic>? getRandomMessageWithKeyExcluding(
    int excludeKey,
  ) {
    final List<dynamic> keys = messagesBox.keys.toList();

    if (keys.isEmpty) return null;

    // If only welcome message exists, return it
    if (keys.length == 1 && keys.contains(1)) {
      final messageData = messagesBox.get(1);
      if (messageData != null) {
        return {'key': 1, 'data': Map<String, dynamic>.from(messageData)};
      }
    }

    // Filter out excluded key and welcome message key "1" if there are user messages
    final List<dynamic> pool = keys
        .where((k) => k != excludeKey && k != 1)
        .toList();

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
    if (messagesBox.isEmpty) return false;
    if (messagesBox.length == 1 && messagesBox.containsKey(1)) {
      final only = messagesBox.get(1);
      if (only is Map && only["message"] == _welcomeMessage) return true;
    }
    return false;
  }

  // Helper to check if user has added any messages
  static bool hasUserMessages() {
    return messagesBox.keys.any((key) => key != 1);
  }
}
