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
  });

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

  @override
  State<EazySwipeableCards2<T>> createState() => _EazySwipeableCards2State();
}

class _EazySwipeableCards2State<T> extends State<EazySwipeableCards2<T>> {
  ValueNotifier<int> currentIndex = ValueNotifier<int>(0);
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
    return Transform.translate(
      offset: Offset(0, -widget.cardDistance * widget.shownCards),
      child: Stack(
        children: [
          for (int i = widget.shownCards - 1; i >= 0; i--)
            if (currentIndex.value + i < data.length)
              Positioned.fill(
                top: (widget.shownCards - i) * widget.cardDistance * 2,
                child: Center(
                  child: Material(
                    elevation: widget.elevation,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      height: widget.cardHeight - i * widget.cardDistance,
                      width: widget.cardWidth - i * widget.cardDistance,
                      child:
                          widget.builder(data[i - currentIndex.value], context),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
