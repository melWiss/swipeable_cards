import 'dart:developer' as dev;

class SwipeableLogger {
  static SwipeableLogger? _swipeableLogger;
  SwipeableLogger._();
  static SwipeableLogger get instance =>
      _swipeableLogger ??= SwipeableLogger._();

  void log(String text) {
    dev.log(text, name: "SwipeableCards");
  }
}
