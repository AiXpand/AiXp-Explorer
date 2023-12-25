import 'package:flutter/foundation.dart';

class _ListenerWithFilter {
  final bool Function(dynamic) filter;
  final Function(dynamic) listener;

  _ListenerWithFilter(this.filter, this.listener);
}

class EventsNotifier {
  int _listenerIDCounter = 0;
  final int _maxListenerID = -1 >>> 1;
  final Map<int, _ListenerWithFilter> _listeners = {};

  int newListenerID() {
    _listenerIDCounter++;
    if (_listenerIDCounter >= _maxListenerID) {
      _listenerIDCounter = 0;
    }
    return _listenerIDCounter;
  }

  int addListener(
      bool Function(dynamic data) filter, Function(dynamic data) listener) {
    final listenerID = newListenerID();
    _listeners[listenerID] = _ListenerWithFilter(filter, listener);
    debugPrint('Added listener with ID: $listenerID');
    return listenerID;
  }

  void removeListener(int listenerID) {
    _listeners.remove(listenerID);
    debugPrint('Removed listener with ID: $listenerID');
  }

  void removeAllListeners() {
    _listeners.clear();
    debugPrint('Removed all listeners');
  }

  void emit(dynamic data) {
    _listeners.values
        .where((listener) => listener.filter(data))
        .forEach((listener) => listener.listener(data));
  }
}
