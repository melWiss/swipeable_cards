import 'package:eazy_swipeable_cards/src/logger.dart';
import 'package:eazy_swipeable_cards/src/variables_controller.dart';
import 'package:flutter/material.dart';

/// A widget that displays a stack of swipeable cards with customizable actions
/// for swiping left, swiping right, and double-tapping.
///
/// The `EazySwipeableCards` widget is designed for use cases where cards need to
/// be swiped for interaction, such as in a dating app or a meme browsing app.
/// It supports animations and optional callbacks for each swipe action.
class EazySwipeableCards<T> extends StatefulWidget {
  /// Creates a [EazySwipeableCards] widget.
  ///
  /// The [builder] parameter provides a method that will build the cards
  /// depending on the [T] items.
  const EazySwipeableCards({
    required this.cardHeight,
    required this.cardWidth,
    required this.builder,
    required this.onLoadMore,
    this.swipeVelocity = 1000,
    this.cardsAnimationInMilliseconds = 250,
    this.cardDistance = 30.0,
    this.shownCards = 1,
    this.behindCardsShouldBeOpaque = false,
    super.key,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onDoubleTap,
    this.onSwipedRightAppear,
    this.onSwipedLeftAppear,
    this.borderRadius = 0,
    this.elevation = 0,
    this.pageSize = 1,
    this.pageThreshold = 0,
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

  /// The swipe velocity that will trigger the swipe event (pixels/second).
  final double swipeVelocity;

  /// This parameter will be used to determine when to call the builder function.
  /// If the number of cards left in the stack is equal to [pageThreshold] then
  /// the [onLoadMore] items will be called.
  final int pageThreshold;

  /// This will represent the page size of stack.
  final int pageSize;

  /// This method will be called when the [EazySwipeableCards] needs more cards
  /// to the stack. If this parameter is null, the pagination won't work.
  final Future<List<T>> Function(
      {required int pageSize, required int pageNumber}) onLoadMore;

  /// A builder method to build the cards.
  final Widget Function(T item, BuildContext context) builder;

  /// Callback triggered when a card is swiped left.
  final void Function(T item)? onSwipeLeft;

  /// Callback triggered when a card is swiped right.
  final void Function(T item)? onSwipeRight;

  /// Callback triggered when a card is double-tapped.
  final void Function(T item)? onDoubleTap;

  /// An optional widget that appears when a card is swiped left.
  final Widget? onSwipedLeftAppear;

  /// An optional widget that appears when a card is swiped right.
  final Widget? onSwipedRightAppear;

  /// The border radius of the cards.
  final double borderRadius;

  /// The elevation level of the cards that will reflect the shadow intensity.
  final double elevation;

  @override
  State<EazySwipeableCards<T>> createState() => _EazySwipeableCardsState();
}

class _EazySwipeableCardsState<T> extends State<EazySwipeableCards<T>> {
  final logger = SwipeableLogger.instance;
  late final VariablesController _controller = VariablesController(
    onLoadMore: widget.onLoadMore,
    pageSize: widget.pageSize,
    pageThreshold: widget.pageThreshold,
    swipeVelocity: widget.swipeVelocity,
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
  final EazySwipeableCards<T> widget;

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
  final EazySwipeableCards<T> widget;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        controller.updateVariables(
          frontCardXPosition:
              variables.frontCardXPosition + details.primaryDelta!,
        );
      },
      onDoubleTap: () =>
          widget.onDoubleTap?.call(controller.variables.data[index]),
      onHorizontalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx.abs() >
            controller.variables.swipeVelocity) {
          if (details.velocity.pixelsPerSecond.dx >
              controller.variables.swipeVelocity) {
            widget.onSwipeRight?.call(controller.variables.data[index]);
            controller.updateVariables(
              frontCardXPosition:
                  MediaQuery.sizeOf(context).width + widget.cardWidth * 2,
              durationInMilliSeconds: widget.cardsAnimationInMilliseconds,
              animationCoeffiecient: 1,
            );
          } else if (details.velocity.pixelsPerSecond.dx <
              -controller.variables.swipeVelocity) {
            widget.onSwipeLeft?.call(controller.variables.data[index]);
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
      child: CardAnimation(
        index: index,
        controller: controller,
        variables: variables,
        widget: widget,
      ),
    );
  }
}

class CardAnimation<T> extends StatelessWidget {
  const CardAnimation({
    super.key,
    required this.index,
    required this.controller,
    required this.variables,
    required this.widget,
  });

  final int index;
  final VariablesController controller;
  final Variables variables;
  final EazySwipeableCards<T> widget;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
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
        return CardPositionAnimation(
          index: index,
          controller: controller,
          variables: variables,
          widget: widget,
          coeff: coeff,
        );
      },
    );
  }
}

class CardPositionAnimation<T> extends StatelessWidget {
  const CardPositionAnimation({
    super.key,
    required this.index,
    required this.controller,
    required this.variables,
    required this.widget,
    required this.coeff,
  });

  final int index;
  final VariablesController controller;
  final Variables variables;
  final EazySwipeableCards<T> widget;
  final double coeff;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: controller.variables.oldFrontCardXPosition,
        end: controller.variables.frontCardXPosition,
      ),
      onEnd: () {
        controller.updateVariables(
          oldFrontCardXPosition: controller.variables.frontCardXPosition,
        );
      },
      duration:
          Duration(milliseconds: controller.variables.durationInMilliSeconds),
      builder: (context, dx, _) {
        return Transform(
          transform: Matrix4.identity()
            ..scale(1 - (index - coeff) * 0.1)
            ..translate(
              index > 0 ? 0.0 : dx,
              -(index - coeff) * widget.cardDistance,
            ),
          alignment: Alignment.center,
          child: SizedBox(
            height: widget.cardHeight,
            width: widget.cardWidth,
            child: Opacity(
              opacity: widget.behindCardsShouldBeOpaque ? 1 : (1 - index * 0.1),
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
  final EazySwipeableCards<T> widget;
  final bool isRight;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Opacity(
        opacity: _max(
          ((controller.variables.frontCardXPosition + 10) /
                  MediaQuery.sizeOf(context).width)
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
