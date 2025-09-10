import 'package:flutter/material.dart';

class ScreenListenerProvider extends ChangeNotifier {
  bool _onScreen = false;
  String _conversationId = '';

  bool get onScreen => _onScreen;
  String get conversationid => _conversationId;
  void setOnScreen(bool value) {
    _onScreen = value;
    notifyListeners();
  }

  void setConversation(String value) {
    _conversationId = value;
    notifyListeners();
  }
}
