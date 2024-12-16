import 'dart:async';

import 'package:flutter/material.dart';
import 'package:eazy_swipeable_cards/src/logger.dart';

/// A widget that displays a stack of swipeable cards with customizable actions
/// for swiping left, swiping right, and double-tapping.
///
/// The `EazySwipeableCards` widget is designed for use cases where cards need to
/// be swiped for interaction, such as in a dating app or a meme browsing app.
/// It supports animations and optional callbacks for each swipe action.
class EazySwipeableCards extends StatefulWidget {
  /// Creates a [EazySwipeableCards] widget.
  ///
  /// [screenHeight] and [screenWidth] are required to determine the layout
  /// dimensions of the cards. The [children] parameter provides the list of
  /// widgets to display as cards, which are swiped in order.
  const EazySwipeableCards({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    this.children,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onDoubleTap,
    this.onSwipedRightAppear,
    this.onSwipedLeftAppear,
    this.borderRadius = 0,
    this.elevation = 0,
  });

  /// The height of the screen, used to size the cards.
  @Deprecated("The widget will now take the whole available space.")
  final double screenHeight;

  /// The width of the screen, used to size the cards.
  @Deprecated("The widget will now take the whole available space.")
  final double screenWidth;

  /// A list of widgets to display as swipeable cards.
  ///
  /// Each card will be displayed one at a time, and the next card will appear
  /// as the previous card is swiped away.
  final List<Widget?>? children;

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
  State<EazySwipeableCards> createState() => _SwipeableCardsState();
}

class _SwipeableCardsState extends State<EazySwipeableCards> {
  final StreamController<Function> _controller = StreamController();
  late final StreamSubscription<Function> _subscription;
  final SwipeableLogger logger = SwipeableLogger.instance;
  late double dx1, dx1b, dy1, dx1End, dy1End, heightCard1, widthCard1;
  late double dx2, dy2, dx2End, dy2End;
  late double dx3, dy3;
  late double heightCard2, widthCard2, heightCard2End, widthCard2End;
  late int duration;
  late Widget? card1, card2, card3, onSwipedLeftAppear, onSwipedRightAppear;
  late double swipedCardLeftOpacity, swipedCardRightOpacity;
  late double borderRadius;
  late double elevation;
  late List<Widget?> cards;
  late int counter;
  late void Function() onSwipeLeft, onSwipeRight, onDoubleTap;
  double? screenHeight, screenWidth;
  @override
  void initState() {
    super.initState();
    onSwipedLeftAppear = widget.onSwipedLeftAppear;
    onSwipedRightAppear = widget.onSwipedRightAppear;
    counter = 0;
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

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void init(double screenHeight, double screenWidth) {
    if (screenHeight != this.screenHeight || screenWidth != this.screenWidth) {
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
      onSwipeLeft = widget.onSwipeLeft != null ? widget.onSwipeLeft! : () {};
      onSwipeRight = widget.onSwipeRight != null ? widget.onSwipeRight! : () {};
      onDoubleTap = widget.onDoubleTap != null ? widget.onDoubleTap! : () {};
      borderRadius = widget.borderRadius;
      elevation = widget.elevation;
      logger.log("refreshed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double screenHeight = constraints.maxHeight;
      double screenWidth = constraints.maxWidth;
      init(screenHeight, screenWidth);
      initCards();
      return SizedBox(
        height: screenHeight * .7,
        width: screenWidth * .9,
        child: Stack(
          children: <Widget>[
            card3 != null
                ? Transform.translate(
                    offset: Offset(dx3, dy3),
                    child: Material(
                      elevation: elevation,
                      borderRadius:
                          BorderRadius.all(Radius.circular(borderRadius)),
                      clipBehavior: Clip.antiAlias,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: duration),
                        height: heightCard2,
                        width: widthCard2,
                        child: card3,
                      ),
                    ),
                  )
                : Container(),
            card2 != null
                ? TweenAnimationBuilder(
                    tween: Tween<Offset>(
                      begin: Offset(dx2, dy2),
                      end: Offset(dx2End, dy2End),
                    ),
                    onEnd: () {
                      _controller.add(() {
                        if ((dx1 != dx1End) &&
                            (dx1End.abs() - dx1b.abs() < 1)) {
                          counter++;
                          card1 = cards[counter];
                          card2 = cards[counter + 1];
                          card3 = cards[counter + 2];
                          init(screenHeight, screenWidth);
                        }
                      });
                    },
                    duration: Duration(milliseconds: duration),
                    child: Material(
                      elevation: elevation,
                      borderRadius:
                          BorderRadius.all(Radius.circular(borderRadius)),
                      clipBehavior: Clip.antiAlias,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: duration),
                        height: heightCard2End,
                        width: widthCard2End,
                        child: card2,
                      ),
                    ),
                    builder: (context, Offset offsetAnimated, Widget? card) {
                      return Transform.translate(
                        offset: offsetAnimated,
                        child: card,
                      );
                    },
                  )
                : Container(),
            card1 != null
                ? TweenAnimationBuilder(
                    tween: Tween<double>(begin: dx1, end: dx1End),
                    duration: Duration(milliseconds: duration),
                    onEnd: () {
                      if (dx1End == screenWidth) {
                        onSwipeRight();
                      } else if (dx1End == -screenWidth) {
                        onSwipeLeft();
                      }
                      _controller.add(() {
                        if (dx1 != dx1End) {
                          dx2End = ((screenWidth * .9) * .05) / 2;
                          dy2End = dy1;
                          heightCard2End = (screenHeight * .7) * .75;
                          widthCard2End = (screenWidth * .9) * .95;
                        }
                      });
                    },
                    child: Material(
                      elevation: elevation,
                      borderRadius:
                          BorderRadius.all(Radius.circular(borderRadius)),
                      clipBehavior: Clip.antiAlias,
                      child: SizedBox(
                        height: heightCard1,
                        width: widthCard1,
                        child: Stack(
                          children: <Widget>[
                            card1!,
                            onSwipedLeftAppear != null
                                ? AnimatedContainer(
                                    duration: Duration(milliseconds: duration),
                                    child: Opacity(
                                      opacity: swipedCardLeftOpacity,
                                      child: onSwipedLeftAppear,
                                    ),
                                  )
                                : Container(),
                            onSwipedRightAppear != null
                                ? AnimatedContainer(
                                    duration: Duration(milliseconds: duration),
                                    child: Opacity(
                                      opacity: swipedCardRightOpacity,
                                      child: onSwipedRightAppear,
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                    builder: (context, double dx1a, card) {
                      dx1b = dx1a;
                      return Transform.translate(
                        offset: Offset(dx1b, dy1),
                        child: GestureDetector(
                          onDoubleTap: onDoubleTap,
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
                                  swipedCardLeftOpacity =
                                      dx1.abs() / screenWidth;
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
                                  swipedCardLeftOpacity =
                                      dx1.abs() / screenWidth;
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
                  )
                : Container(),
          ],
        ),
      );
    });
  }

  void initCards() {
    if (widget.children != null) {
      cards = widget.children!;
      cards.add(null);
      cards.add(null);
      cards.add(null);
      if (cards.length < counter) counter = 0;
      card1 = cards[counter];
      card2 = cards[counter + 1];
      card3 = cards[counter + 2];
    } else {
      cards = [null, null, null];
    }
  }
}
