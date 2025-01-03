import 'dart:async';

class Variables<T> {
  /// the current page of the cards stack.
  final int currentPage;

  /// the page size of the cards list.
  final int pageSize;

  /// This method will be called when the [EazySwipeableCards] needs more cards
  /// to the stack. If this parameter is null, the pagination won't work.
  final Future<List<T>> Function(
      {required int pageSize, required int pageNumber}) onLoadMore;

  /// the page threshold that will be used to determine when to load more data.
  final int pageThreshold;

  /// the data that the stack of cards holds
  final List<T> data;

  /// the x position of the front card.
  final double frontCardXPosition;

  /// the old x position of the front cards.
  final double oldFrontCardXPosition;

  /// the value of this variable is either 0 or 200.
  final int durationInMilliSeconds;

  /// The swipe velocity that will trigger the swipe event (pixels/second).
  final double swipeVelocity;

  /// the value of the coefficient of the card to scale and translate accordingly
  /// it should be 0.0 or 1.0;
  final double animationCoeffiecient;
  Variables({
    required this.pageSize,
    required this.pageThreshold,
    required this.frontCardXPosition,
    required this.oldFrontCardXPosition,
    required this.durationInMilliSeconds,
    required this.animationCoeffiecient,
    required this.onLoadMore,
    required this.data,
    required this.swipeVelocity,
    this.currentPage = 0,
  });

  Variables<T> copyWith({
    int? pageSize,
    int? pageThreshold,
    List<T>? data,
    double? frontCardXPosition,
    double? oldFrontCardXPosition,
    int? durationInMilliSeconds,
    double? animationCoeffiecient,
    int? currentPage,
    double? swipeVelocity,
  }) {
    return Variables<T>(
      pageSize: pageSize ?? this.pageSize,
      pageThreshold: pageThreshold ?? this.pageThreshold,
      data: data ?? this.data,
      frontCardXPosition: frontCardXPosition ?? this.frontCardXPosition,
      durationInMilliSeconds:
          durationInMilliSeconds ?? this.durationInMilliSeconds,
      animationCoeffiecient:
          animationCoeffiecient ?? this.animationCoeffiecient,
      currentPage: currentPage ?? this.currentPage,
      oldFrontCardXPosition:
          oldFrontCardXPosition ?? this.oldFrontCardXPosition,
      swipeVelocity: swipeVelocity ?? this.swipeVelocity,
      onLoadMore: onLoadMore,
    );
  }
}

class VariablesController<T> {
  late Variables<T> _variables;
  int? _latestLoadedPage;
  VariablesController({
    required Future<List<T>> Function({
      required int pageSize,
      required int pageNumber,
    }) onLoadMore,
    required int pageSize,
    required int pageThreshold,
    required double swipeVelocity,
  }) {
    _variables = Variables<T>(
      frontCardXPosition: 0,
      oldFrontCardXPosition: 0,
      durationInMilliSeconds: 0,
      animationCoeffiecient: 0,
      onLoadMore: onLoadMore,
      pageSize: pageSize,
      pageThreshold: pageThreshold,
      swipeVelocity: swipeVelocity,
      data: <T>[],
    );
    _streamController.add(_variables);
  }

  late final StreamController<Variables<T>> _streamController =
      StreamController<Variables<T>>();

  Stream<Variables<T>> get stream => _streamController.stream;

  /// get the current data
  Variables<T> get variables => _variables;

  void updateVariables({
    int? pageSize,
    int? pageThreshold,
    List<T>? data,
    double? frontCardXPosition,
    double? oldFrontCardXPosition,
    int? durationInMilliSeconds,
    double? animationCoeffiecient,
    int? currentPage,
  }) {
    _variables = _variables.copyWith(
      frontCardXPosition: frontCardXPosition,
      oldFrontCardXPosition: oldFrontCardXPosition,
      durationInMilliSeconds: durationInMilliSeconds,
      animationCoeffiecient: animationCoeffiecient,
      data: data,
      currentPage: currentPage,
      pageSize: pageSize,
      pageThreshold: pageThreshold,
    );
    _streamController.add(_variables);
  }

  Future<void> onLoadMore({bool initial = false}) async {
    if (_variables.data.isNotEmpty) {
      _variables.data.removeAt(0);
    }
    if ((_variables.data.length <= _variables.pageThreshold &&
            _latestLoadedPage != _variables.currentPage) ||
        initial) {
      _latestLoadedPage = _variables.currentPage;
      final newData = await _variables.onLoadMore(
        pageNumber: _variables.currentPage,
        pageSize: _variables.pageSize,
      );
      if (newData.isNotEmpty) {
        updateVariables(
          data: _variables.data + newData,
          currentPage: _variables.currentPage + 1,
        );
      }
    }
  }
}
