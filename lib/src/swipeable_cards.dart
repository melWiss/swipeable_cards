import 'dart:async';

import 'package:flutter/material.dart';
import 'package:eazy_swipeable_cards/src/logger.dart';

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
    required this.builder,
    required this.onLoadMore,
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
  });

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
  final void Function()? onSwipeLeft;

  /// Callback triggered when a card is swiped right.
  final void Function()? onSwipeRight;

  /// Callback triggered when a card is double-tapped.
  final void Function()? onDoubleTap;

  /// An optional widget that appears when a card is swiped left.
  final Widget? onSwipedLeftAppear;

  /// An optional widget that appears when a card is swiped right.
  final Widget? onSwipedRightAppear;

  /// The border radius of the cards.
  final double borderRadius;

  /// The elevation level of the cards that will reflect the shadow intensity.
  final double elevation;

  @override
  State<EazySwipeableCards<T>> createState() => _SwipeableCardsState<T>();
}

class _SwipeableCardsState<T> extends State<EazySwipeableCards<T>> {
  final StreamController<Function> _controller = StreamController();
  late final StreamSubscription<Function> _subscription;
  final SwipeableLogger logger = SwipeableLogger.instance;
  late double dx1, dx1b, dy1, dx1End, dy1End, heightCard1, widthCard1;
  late double dx2, dy2, dx2End, dy2End;
  late double dx3, dy3;
  late double heightCard2, widthCard2, heightCard2End, widthCard2End;
  late int duration;
  late double swipedCardLeftOpacity, swipedCardRightOpacity;
  int index = 0;
  int pageIndex = 0;
  int? latestPageIndexCall;
  double? screenHeight, screenWidth;
  late final List<T> items;
  @override
  void initState() {
    super.initState();
    items = List<T>.empty(growable: true);
    safelyCallOnload(pageIndex);
    _subscription = _controller.stream.listen(
      (event) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            event();
          });
        });
      },
    );
  }

  void safeSetState(Function function) {
    _controller.add(function);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void init(double screenHeight, double screenWidth, {bool forced = false}) {
    if (screenHeight != this.screenHeight ||
        screenWidth != this.screenWidth ||
        forced) {
      this.screenHeight = screenHeight;
      this.screenWidth = screenWidth;
      dx1 = ((screenWidth * .9) * .05) / 2;
      dy1 = ((screenHeight * .7) * .25);
      swipedCardLeftOpacity = 0;
      swipedCardRightOpacity = 0;
      dx1b = dx1;
      dx1End = dx1;
      dy1End = dy1;
      heightCard1 = (screenHeight * .7) * .75;
      widthCard1 = (screenWidth * .9) * .95;
      dx2 = ((screenWidth * .9) * .25) / 2;
      dy2 = ((screenHeight * .7) * .01);
      dx2End = dx2;
      dy2End = dy2;
      heightCard2 = (screenHeight * .7) * .55;
      widthCard2 = (screenWidth * .9) * .75;
      heightCard2End = (screenHeight * .7) * .55;
      widthCard2End = (screenWidth * .9) * .75;
      dx3 = dx2;
      dy3 = dy2;
      duration = 0;
      if (!forced) {
        logger.log("initialized");
      }
    }
  }

  void safelyCallOnload(int pageIndex) {
    if (pageIndex != latestPageIndexCall) {
      latestPageIndexCall = pageIndex;
      widget.onLoadMore(pageNumber: pageIndex, pageSize: widget.pageSize).then(
        (value) {
          if (value.isNotEmpty) {
            items.addAll(value);
            setState(() {
              this.pageIndex++;
            });
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenHeight = constraints.maxHeight;
        double screenWidth = constraints.maxWidth;
        init(screenHeight, screenWidth);
        List<Widget> stackChildren;
        if (items.length < index + widget.pageSize + widget.pageThreshold) {
          stackChildren = items
              .sublist(index)
              .map<Widget>((e) => widget.builder(e, context))
              .toList();
          safelyCallOnload(pageIndex);
        } else {
          stackChildren = items
              .sublist(index, index + widget.pageSize)
              .map<Widget>((e) => widget.builder(e, context))
              .toList();
        }
        return SizedBox(
          height: screenHeight * .7,
          width: screenWidth * .9,
          child: Stack(
            children: <Widget>[
              if (stackChildren.length >= 3)
                Transform.translate(
                  offset: Offset(dx3, dy3),
                  child: Material(
                    elevation: widget.elevation,
                    borderRadius:
                        BorderRadius.all(Radius.circular(widget.borderRadius)),
                    clipBehavior: Clip.antiAlias,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: duration),
                      height: heightCard2,
                      width: widthCard2,
                      child: stackChildren[2],
                    ),
                  ),
                ),
              if (stackChildren.length >= 2)
                TweenAnimationBuilder(
                  tween: Tween<Offset>(
                    begin: Offset(dx2, dy2),
                    end: Offset(dx2End, dy2End),
                  ),
                  onEnd: () {
                    safeSetState(() {
                      if ((dx1 != dx1End) && (dx1End.abs() - dx1b.abs() < 1)) {
                        index++;
                        init(screenHeight, screenWidth, forced: true);
                      }
                    });
                  },
                  duration: Duration(milliseconds: duration),
                  child: Material(
                    elevation: widget.elevation,
                    borderRadius:
                        BorderRadius.all(Radius.circular(widget.borderRadius)),
                    clipBehavior: Clip.antiAlias,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: duration),
                      height: heightCard2End,
                      width: widthCard2End,
                      child: stackChildren[1],
                    ),
                  ),
                  builder: (context, Offset offsetAnimated, Widget? card) {
                    return Transform.translate(
                      offset: offsetAnimated,
                      child: card,
                    );
                  },
                ),
              if (stackChildren.isNotEmpty)
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: dx1, end: dx1End),
                  duration: Duration(milliseconds: duration),
                  onEnd: () {
                    if (dx1End == screenWidth) {
                      widget.onSwipeRight?.call();
                    } else if (dx1End == -screenWidth) {
                      widget.onSwipeLeft?.call();
                    }
                    safeSetState(() {
                      if (dx1 != dx1End) {
                        dx2End = ((screenWidth * .9) * .05) / 2;
                        dy2End = dy1;
                        heightCard2End = (screenHeight * .7) * .75;
                        widthCard2End = (screenWidth * .9) * .95;
                      }
                    });
                  },
                  child: Material(
                    elevation: widget.elevation,
                    borderRadius:
                        BorderRadius.all(Radius.circular(widget.borderRadius)),
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      height: heightCard1,
                      width: widthCard1,
                      child: Stack(
                        children: <Widget>[
                          stackChildren[0],
                          if (widget.onSwipedLeftAppear != null)
                            AnimatedContainer(
                              duration: Duration(milliseconds: duration),
                              child: Opacity(
                                opacity: swipedCardLeftOpacity,
                                child: widget.onSwipedLeftAppear,
                              ),
                            ),
                          if (widget.onSwipedRightAppear != null)
                            AnimatedContainer(
                              duration: Duration(milliseconds: duration),
                              child: Opacity(
                                opacity: swipedCardRightOpacity,
                                child: widget.onSwipedRightAppear,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  builder: (context, double dx1a, card) {
                    dx1b = dx1a;
                    return Transform.translate(
                      offset: Offset(dx1b, dy1),
                      child: GestureDetector(
                        onDoubleTap: widget.onDoubleTap,
                        onHorizontalDragStart: (DragStartDetails details) {
                          setState(() {
                            dx1 = details.globalPosition.dx - screenWidth / 2;
                            dx1End = dx1;
                            if (dx1 > 0) {
                              if (dx1 < screenWidth / 2) {
                                swipedCardRightOpacity = dx1 / screenWidth;
                              } else {
                                swipedCardRightOpacity = 1;
                              }
                              swipedCardLeftOpacity = 0;
                            } else if (dx1 < 0) {
                              if (dx1.abs() < screenWidth / 2) {
                                swipedCardLeftOpacity = dx1.abs() / screenWidth;
                              } else {
                                swipedCardLeftOpacity = 1;
                              }
                              swipedCardRightOpacity = 0;
                            } else {
                              swipedCardLeftOpacity = 0;
                              swipedCardRightOpacity = 0;
                            }
                            if (duration == 0) duration = 200;
                          });
                        },
                        onHorizontalDragUpdate: (DragUpdateDetails details) {
                          setState(() {
                            dx1 = details.globalPosition.dx - screenWidth / 2;
                            dx1End = dx1;
                            if (dx1 > 0) {
                              if (dx1 < screenWidth / 2) {
                                swipedCardRightOpacity = dx1 / screenWidth;
                              } else {
                                swipedCardRightOpacity = 1;
                              }
                              swipedCardLeftOpacity = 0;
                            } else if (dx1 < 0) {
                              if (dx1.abs() < screenWidth / 2) {
                                swipedCardLeftOpacity = dx1.abs() / screenWidth;
                              } else {
                                swipedCardLeftOpacity = 1;
                              }
                              swipedCardRightOpacity = 0;
                            } else {
                              swipedCardLeftOpacity = 0;
                              swipedCardRightOpacity = 0;
                            }
                          });
                        },
                        onHorizontalDragEnd: (DragEndDetails details) {
                          if (details.velocity.pixelsPerSecond.dx >= 1200) {
                            setState(() {
                              dx1End = screenWidth;
                              dx1 = ((screenWidth * .9) * .05) / 2;
                              swipedCardRightOpacity = 1;
                              swipedCardLeftOpacity = 0;
                            });
                          } else if (details.velocity.pixelsPerSecond.dx <=
                              -1200) {
                            setState(() {
                              dx1End = -screenWidth;
                              dx1 = ((screenWidth * .9) * .05) / 2;
                              swipedCardLeftOpacity = 1;
                              swipedCardRightOpacity = 0;
                            });
                          } else {
                            setState(() {
                              dx1 = ((screenWidth * .9) * .05) / 2;
                              dx1End = dx1;
                              swipedCardLeftOpacity = 0;
                              swipedCardRightOpacity = 0;
                            });
                          }
                        },
                        child: card!,
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
