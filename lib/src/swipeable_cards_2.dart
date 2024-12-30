import 'package:eazy_swipeable_cards/src/logger.dart';
import 'package:eazy_swipeable_cards/src/swipeable_cards.dart';
import 'package:eazy_swipeable_cards/src/variables_controller.dart';
import 'package:flutter/material.dart';

class EazySwipeableCards2<T> extends EazySwipeableCards<T> {
  const EazySwipeableCards2({
    required this.cardHeight,
    required this.cardWidth,
    required super.builder,
    required super.onLoadMore,
    this.cardsAnimationInMilliseconds = 200,
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

  /// The animation duration of the cards in milliseconds.
  final int cardsAnimationInMilliseconds;

  @override
  State<EazySwipeableCards2<T>> createState() => _EazySwipeableCards2State();
}

class _EazySwipeableCards2State<T> extends State<EazySwipeableCards2<T>> {
  final logger = SwipeableLogger.instance;
  final VariablesController _controller = VariablesController();

  int currentPage = 0;
  List<T> data = [];

  @override
  void initState() {
    super.initState();
    onLoadMore(initial: true);
  }

  Future<void> onLoadMore({bool initial = false}) async {
    if (_controller.variables.currentIndex >= widget.pageThreshold || initial) {
      final newData = await widget.onLoadMore(
        pageNumber: currentPage++,
        pageSize: widget.pageSize,
      );
      if (newData.isNotEmpty) {
        data =
            data.sublist(_controller.variables.currentIndex) + newData.toList();
        _controller.updateVariables(currentIndex: 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Variables>(
        stream: _controller.stream,
        builder: (context, snapshot) {
          final variables = snapshot.data ?? _controller.variables;
          return Stack(
            children: [
              for (int i = widget.shownCards - 1; i >= 0; i--)
                if (_controller.variables.currentIndex + i < data.length)
                  GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      _controller.updateVariables(
                        frontCardXPosition: variables.frontCardXPosition +
                            details.primaryDelta!,
                      );
                    },
                    onHorizontalDragEnd: (details) {
                      if (details.velocity.pixelsPerSecond.dx.abs() > 1000) {
                        if (details.velocity.pixelsPerSecond.dx > 1000) {
                          widget.onSwipeRight?.call();
                          _controller.updateVariables(
                            frontCardXPosition:
                                MediaQuery.sizeOf(context).width +
                                    widget.cardWidth * 2,
                            durationInMilliSeconds:
                                widget.cardsAnimationInMilliseconds,
                            animationCoeffiecient: 1,
                          );
                        } else if (details.velocity.pixelsPerSecond.dx <
                            -1000) {
                          widget.onSwipeLeft?.call();
                          _controller.updateVariables(
                            frontCardXPosition:
                                -(MediaQuery.sizeOf(context).width +
                                    widget.cardWidth * 2),
                            durationInMilliSeconds:
                                widget.cardsAnimationInMilliseconds,
                            animationCoeffiecient: 1,
                          );
                        }
                        onLoadMore();
                      } else {
                        _controller.updateVariables(frontCardXPosition: 0);
                      }
                    },
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: 0,
                        end: variables.animationCoeffiecient,
                      ),
                      curve: Curves.easeIn,
                      duration: Duration(
                          milliseconds: variables.durationInMilliSeconds),
                      onEnd: () {
                        if (i == 0 && variables.animationCoeffiecient == 1) {
                          _controller.updateVariables(
                            durationInMilliSeconds: 0,
                            animationCoeffiecient: 0,
                            frontCardXPosition: 0,
                            currentIndex: variables.currentIndex + 1,
                          );
                        }
                      },
                      builder: (context, coeff, _) {
                        return Transform(
                          transform: Matrix4.identity()
                            ..scale(1 - (i - coeff) * 0.1)
                            ..translate(
                              i > 0 ? 0.0 : variables.frontCardXPosition,
                              -(i - coeff) * widget.cardDistance,
                            ),
                          alignment: Alignment.center,
                          child: SizedBox(
                            height: widget.cardHeight,
                            width: widget.cardWidth,
                            child: Opacity(
                              opacity: widget.behindCardsShouldBeOpaque
                                  ? 1
                                  : (1 - i * 0.1),
                              child: Material(
                                elevation: widget.elevation,
                                borderRadius:
                                    BorderRadius.circular(widget.borderRadius),
                                clipBehavior: Clip.antiAlias,
                                child: widget.builder(
                                  data[(i + variables.currentIndex).abs()],
                                  context,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            ],
          );
        });
  }
}
