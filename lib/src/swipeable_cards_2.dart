import 'package:eazy_swipeable_cards/src/swipeable_cards.dart';
import 'package:flutter/material.dart';

class EazySwipeableCards2<T> extends EazySwipeableCards<T> {
  const EazySwipeableCards2({
    required this.cardHeight,
    required this.cardWidth,
    required super.builder,
    required super.onLoadMore,
    this.cardDistance = 30.0,
    this.shownCards = 1,
    this.behindCardsShouldBeOpaque = false,
    super.key,
    super.onSwipeLeft,
    super.onSwipeRight,
    super.onDoubleTap,
    super.onSwipedRightAppear,
    super.onSwipedLeftAppear,
    super.borderRadius = 0,
    super.elevation = 0,
    super.pageSize = 1,
    super.pageThreshold = 0,
  })  : assert(shownCards <= pageThreshold && shownCards > 0),
        assert(cardDistance > 0),
        assert(pageThreshold > 0);

  /// The height of the front card.
  final double cardHeight;

  /// The width of the front card.
  final double cardWidth;

  /// The number of cards that will be shown behind each other.
  /// The default value is 1.
  final int shownCards;

  /// The distantance between each card.
  /// The default value is 30.0.
  final double cardDistance;

  /// This parameter is used to determine whether the cards behind the front card should be opaque.
  final bool behindCardsShouldBeOpaque;

  @override
  State<EazySwipeableCards2<T>> createState() => _EazySwipeableCards2State();
}

class _EazySwipeableCards2State<T> extends State<EazySwipeableCards2<T>> {
  ValueNotifier<int> currentIndex = ValueNotifier<int>(0);
  ValueNotifier<double> frontCardXPosition = ValueNotifier(0);
  int currentPage = 0;
  List<T> data = [];

  @override
  void initState() {
    super.initState();
    onLoadMore();
    currentIndex.addListener(() {
      if (currentIndex.value < widget.pageThreshold) {
        onLoadMore();
      }
    });
  }

  Future<void> onLoadMore() async {
    final newData = await widget.onLoadMore(
      pageNumber: currentPage++,
      pageSize: widget.pageSize,
    );
    if (newData.isNotEmpty) {
      setState(() {
        data = data.sublist(currentIndex.value) + newData.toList();
        currentIndex.value = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (int i = widget.shownCards - 1; i >= 0; i--)
          if (currentIndex.value + i < data.length)
            ListenableBuilder(
              listenable: frontCardXPosition,
              child: Transform(
                transform: Matrix4.identity()
                  ..scale(1 - i * 0.1)
                  ..translate(0.0, -i * widget.cardDistance),
                alignment: Alignment.center,
                child: SizedBox(
                  height: widget.cardHeight,
                  width: widget.cardWidth,
                  child: Opacity(
                    opacity: widget.behindCardsShouldBeOpaque ? 1 : 1 - i * 0.1,
                    child: Material(
                      elevation: widget.elevation,
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      clipBehavior: Clip.antiAlias,
                      child:
                          widget.builder(data[i - currentIndex.value], context),
                    ),
                  ),
                ),
              ),
              builder: (_, child) => GestureDetector(
                onHorizontalDragUpdate: (details) {
                  frontCardXPosition.value += details.primaryDelta!;
                },
                onHorizontalDragEnd: (details) {
                  if (frontCardXPosition.value > 100) {
                    widget.onSwipeRight?.call();
                  } else if (frontCardXPosition.value < -100) {
                    widget.onSwipeLeft?.call();
                  }
                  frontCardXPosition.value = 0;
                  print(details);
                },
                child: Transform.translate(
                  offset:
                      i > 0 ? Offset.zero : Offset(frontCardXPosition.value, 0),
                  child: child!,
                ),
              ),
            ),
      ],
    );
  }
}
