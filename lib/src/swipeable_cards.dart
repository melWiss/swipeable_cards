import 'dart:async';

import 'package:flutter/material.dart';
import 'package:eazy_swipeable_cards/src/logger.dart';

/// A widget that displays a stack of swipeable cards with customizable actions
/// for swiping left, swiping right, and double-tapping.
///
/// The `SwipeableCards` widget is designed for use cases where cards need to
/// be swiped for interaction, such as in a dating app or a meme browsing app.
/// It supports animations and optional callbacks for each swipe action.
class SwipeableCards extends StatefulWidget {
  /// Creates a [SwipeableCards] widget.
  ///
  /// [screenHeight] and [screenWidth] are required to determine the layout
  /// dimensions of the cards. The [children] parameter provides the list of
  /// widgets to display as cards, which are swiped in order.
  const SwipeableCards({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    this.children,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onDoubleTap,
    this.onSwipedRightAppear,
    this.onSwipedLeftAppear,
    this.borderColor,
  });

  /// The height of the screen, used to size the cards.
  final double screenHeight;

  /// The width of the screen, used to size the cards.
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

  /// The color of the border around each card.
  ///
  /// If no color is provided, the border will be transparent by default.
  final Color? borderColor;

  @override
  State<SwipeableCards> createState() => _SwipeableCardsState();
}

class _SwipeableCardsState extends State<SwipeableCards> {
  final StreamController<Function> _controller = StreamController();
  late final StreamSubscription<Function> _subscription;
  final SwipeableLogger logger = SwipeableLogger.instance;
  late double screenHeight, screenWidth;
  late double dx1, dx1b, dy1, dx1End, dy1End, heightCard1, widthCard1;
  late double dx2, dy2, dx2End, dy2End;
  late double dx3, dy3;
  late double heightCard2, widthCard2, heightCard2End, widthCard2End;
  late Color thirdCardColor;
  late int duration;
  late Widget? card1, card2, card3, onSwipedLeftAppear, onSwipedRightAppear;
  late double swipedCardLeftOpacity, swipedCardRightOpacity;
  late List<Widget?> cards;
  late int counter;
  late void Function() onSwipeLeft, onSwipeRight, onDoubleTap;
  late Color borderColor;
  @override
  void initState() {
    super.initState();
    onSwipedLeftAppear = widget.onSwipedLeftAppear;
    onSwipedRightAppear = widget.onSwipedRightAppear;
    screenHeight = widget.screenHeight;
    screenWidth = widget.screenWidth;
    counter = 0;
    borderColor =
        widget.borderColor != null ? widget.borderColor! : Colors.transparent;
    initCards();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (screenHeight != widget.screenHeight) {
          setState(() {
            screenHeight = widget.screenHeight;
            screenWidth = widget.screenWidth;
            init();
          });
        }
      },
    );
    init();
    _subscription = _controller.stream.listen(
      (event) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            event();
          });
        });
      },
    );
    logger.log("initiated");
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void init() {
    dx1 = ((widget.screenWidth * .9) * .05) / 2;
    dy1 = ((widget.screenHeight * .7) * .25);
    swipedCardLeftOpacity = 0;
    swipedCardRightOpacity = 0;
    dx1b = dx1;
    dx1End = dx1;
    dy1End = dy1;
    heightCard1 = (widget.screenHeight * .7) * .75;
    widthCard1 = (widget.screenWidth * .9) * .95;
    dx2 = ((widget.screenWidth * .9) * .25) / 2;
    dy2 = ((widget.screenHeight * .7) * .01);
    dx2End = dx2;
    dy2End = dy2;
    heightCard2 = (widget.screenHeight * .7) * .55;
    widthCard2 = (widget.screenWidth * .9) * .75;
    heightCard2End = (widget.screenHeight * .7) * .55;
    widthCard2End = (widget.screenWidth * .9) * .75;
    dx3 = dx2;
    dy3 = dy2;
    thirdCardColor = Colors.white10;
    duration = 0;
    onSwipeLeft = widget.onSwipeLeft != null ? widget.onSwipeLeft! : () {};
    onSwipeRight = widget.onSwipeRight != null ? widget.onSwipeRight! : () {};
    onDoubleTap = widget.onDoubleTap != null ? widget.onDoubleTap! : () {};
  }

  @override
  Widget build(BuildContext context) {
    if (screenHeight != widget.screenHeight) {
      screenHeight = widget.screenHeight;
      screenWidth = widget.screenWidth;
      init();
    }
    initCards();
    return SizedBox(
      height: widget.screenHeight * .7,
      width: widget.screenWidth * .9,
      child: Stack(
        children: <Widget>[
          card3 != null
              ? Transform.translate(
                  offset: Offset(dx3, dy3),
                  child: Material(
                    elevation: 8,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: duration),
                        height: heightCard2,
                        width: widthCard2,
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          color: thirdCardColor,
                          border: Border.all(
                            width: 1.5,
                            color: borderColor,
                          ),
                        ),
                        child: card3,
                      ),
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
                      if ((dx1 != dx1End) && (dx1End.abs() - dx1b.abs() < 1)) {
                        counter++;
                        card1 = cards[counter];
                        card2 = cards[counter + 1];
                        card3 = cards[counter + 2];
                        init();
                      }
                    });
                  },
                  duration: Duration(milliseconds: duration),
                  child: Material(
                    elevation: 8,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: duration),
                        height: heightCard2End,
                        width: widthCard2End,
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          color: Colors.white38,
                          border: Border.all(
                            width: 1.5,
                            color: borderColor,
                          ),
                        ),
                        child: card2,
                      ),
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
                        dx2End = ((widget.screenWidth * .9) * .05) / 2;
                        dy2End = dy1;
                        heightCard2End = (widget.screenHeight * .7) * .75;
                        widthCard2End = (widget.screenWidth * .9) * .95;
                        thirdCardColor = Colors.white38;
                      }
                    });
                  },
                  child: Material(
                    elevation: 8,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white38,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                          border: Border.all(width: 2, color: borderColor),
                        ),
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
                  ),
                  builder: (context, double dx1a, card) {
                    dx1b = dx1a;
                    return Transform.translate(
                      offset: Offset(dx1b, dy1),
                      child: GestureDetector(
                        onDoubleTap: onDoubleTap,
                        onHorizontalDragStart: (DragStartDetails details) {
                          setState(() {
                            dx1 = details.globalPosition.dx -
                                widget.screenWidth / 2;
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
                            dx1 = details.globalPosition.dx -
                                widget.screenWidth / 2;
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
                              dx1End = widget.screenWidth;
                              dx1 = ((widget.screenWidth * .9) * .05) / 2;
                              swipedCardRightOpacity = 1;
                              swipedCardLeftOpacity = 0;
                            });
                          } else if (details.velocity.pixelsPerSecond.dx <=
                              -1200) {
                            setState(() {
                              dx1End = -widget.screenWidth;
                              dx1 = ((widget.screenWidth * .9) * .05) / 2;
                              swipedCardLeftOpacity = 1;
                              swipedCardRightOpacity = 0;
                            });
                          } else {
                            setState(() {
                              dx1 = ((widget.screenWidth * .9) * .05) / 2;
                              dx1End = dx1;
                              swipedCardLeftOpacity = 0;
                              swipedCardRightOpacity = 0;
                            });
                          }
                        },
                        child: Stack(
                          children: <Widget>[
                            card!,
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Container(),
        ],
      ),
    );
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
