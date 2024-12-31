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
  late final VariablesController _controller = VariablesController(
    onLoadMore: widget.onLoadMore,
    pageSize: widget.pageSize,
    pageThreshold: widget.pageThreshold,
  );

  @override
  void initState() {
    super.initState();
    _controller.onLoadMore(initial: true);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Variables>(
      stream: _controller.stream,
      builder: (context, snapshot) {
        final variables = snapshot.data ?? _controller.variables;
        return SwipeableCardStack(
          controller: _controller,
          variables: variables,
          widget: widget,
        );
      },
    );
  }
}

class SwipeableCardStack<T> extends StatelessWidget {
  const SwipeableCardStack({
    super.key,
    required this.controller,
    required this.variables,
    required this.widget,
  });

  final VariablesController controller;
  final Variables variables;
  final EazySwipeableCards2<T> widget;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (int i = widget.shownCards - 1; i >= 0; i--)
          if (i < controller.variables.data.length)
            SwipeableCard(
              index: i,
              controller: controller,
              variables: variables,
              widget: widget,
            ),
      ],
    );
  }
}

class SwipeableCard<T> extends StatelessWidget {
  const SwipeableCard({
    super.key,
    required this.index,
    required this.controller,
    required this.variables,
    required this.widget,
  });

  final int index;
  final VariablesController controller;
  final Variables variables;
  final EazySwipeableCards2<T> widget;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        controller.updateVariables(
          frontCardXPosition:
              variables.frontCardXPosition + details.primaryDelta!,
        );
      },
      onDoubleTap: widget.onDoubleTap,
      onHorizontalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx.abs() > 1000) {
          if (details.velocity.pixelsPerSecond.dx > 1000) {
            widget.onSwipeRight?.call();
            controller.updateVariables(
              frontCardXPosition:
                  MediaQuery.sizeOf(context).width + widget.cardWidth * 2,
              durationInMilliSeconds: widget.cardsAnimationInMilliseconds,
              animationCoeffiecient: 1,
            );
          } else if (details.velocity.pixelsPerSecond.dx < -1000) {
            widget.onSwipeLeft?.call();
            controller.updateVariables(
              frontCardXPosition:
                  -(MediaQuery.sizeOf(context).width + widget.cardWidth * 2),
              durationInMilliSeconds: widget.cardsAnimationInMilliseconds,
              animationCoeffiecient: 1,
            );
          }
        } else {
          controller.updateVariables(frontCardXPosition: 0);
        }
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(
          begin: 0,
          end: variables.animationCoeffiecient,
        ),
        curve: Curves.easeIn,
        duration: Duration(milliseconds: variables.durationInMilliSeconds),
        onEnd: () {
          if (index == 0 && variables.animationCoeffiecient == 1) {
            controller.updateVariables(
              durationInMilliSeconds: 0,
              animationCoeffiecient: 0,
              frontCardXPosition: 0,
            );
            controller.onLoadMore();
          }
        },
        builder: (context, coeff, _) {
          return Transform(
            transform: Matrix4.identity()
              ..scale(1 - (index - coeff) * 0.1)
              ..translate(
                index > 0 ? 0.0 : variables.frontCardXPosition,
                -(index - coeff) * widget.cardDistance,
              ),
            alignment: Alignment.center,
            child: SizedBox(
              height: widget.cardHeight,
              width: widget.cardWidth,
              child: Opacity(
                opacity:
                    widget.behindCardsShouldBeOpaque ? 1 : (1 - index * 0.1),
                child: Material(
                  elevation: widget.elevation,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: widget.builder(
                          controller.variables.data[index],
                          context,
                        ),
                      ),
                      if (index == 0 &&
                          widget.onSwipedRightAppear != null &&
                          controller.variables.frontCardXPosition > 0)
                        SwipeableCardOpacity(
                          controller: controller,
                          widget: widget,
                          isRight: true,
                        ),
                      if (index == 0 &&
                          widget.onSwipedLeftAppear != null &&
                          controller.variables.frontCardXPosition < 0)
                        SwipeableCardOpacity(
                          controller: controller,
                          widget: widget,
                          isRight: false,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SwipeableCardOpacity<T> extends StatelessWidget {
  const SwipeableCardOpacity({
    super.key,
    required this.controller,
    required this.widget,
    required this.isRight,
  });

  final VariablesController controller;
  final EazySwipeableCards2<T> widget;
  final bool isRight;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: _max(
          ((controller.variables.frontCardXPosition + 10) /
                      MediaQuery.sizeOf(context).width +
                  (isRight ? .2 : 0))
              .abs(),
          1,
        ),
        child: isRight ? widget.onSwipedRightAppear : widget.onSwipedLeftAppear,
      ),
    );
  }

  double _max(double current, double max) {
    return current > max ? max : current;
  }
}
