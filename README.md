# Eazy Swipeable Cards Documentation

## Overview

The `EazySwipeableCards` widget provides a stack of interactive cards that users can swipe left, swipe right, or double-tap. This widget is ideal for applications like dating apps, meme browsing, or any app where swipe-based interaction is central to the user experience.

![demo](https://github.com/melWiss/swipeable_cards/blob/master/media/output.gif?raw=true)

Key features include:

- Customizable swipe actions (left, right, double-tap).
- Optional widgets that appear when swiping left or right.
- Pagination support for dynamically loading more cards.
- Animations for swipe gestures.
- Customizable card styles, including border radius and elevation.
- Adjustable swipe velocity triggers.
- Support for multiple visible cards in the stack.
- Improved performance using the bloc pattern.
- Logging support for debugging actions.

---

## Getting Started

To use the `EazySwipeableCards` widget in your Flutter project, first, add the `eazy_swipeable_cards` package to your `pubspec.yaml` file.

```yaml
dependencies:
  eazy_swipeable_cards: ^1.0.0
```

Then, import the package:

```dart
import 'package:eazy_swipeable_cards/eazy_swipeable_cards.dart';
```

---

## Usage Example

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eazy_swipeable_cards/eazy_swipeable_cards.dart';
import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EazySwipeableCards Demo',
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(),
      ),
      home: const MyHomePage(title: 'Swipeable Cards Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int counter = 0;
  SwipeableLogger logger = SwipeableLogger.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: EazySwipeableCards<String>(
            cardWidth: 400,
            cardHeight: 400,
            shownCards: 10,
            cardDistance: 120,
            behindCardsShouldBeOpaque: false,
            cardsAnimationInMilliseconds: 250,
            onSwipeLeft: () {
              setState(() {
                counter--;
              });
            },
            onSwipeRight: () {
              setState(() {
                counter++;
              });
            },
            onDoubleTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Card double-tapped!')),
              );
            },
            onSwipedLeftAppear: const Material(
              color: Colors.red,
              child: Center(
                child: Icon(
                  Icons.thumb_down,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            ),
            onSwipedRightAppear: const Material(
              color: Colors.green,
              child: Center(
                child: Icon(
                  Icons.thumb_up,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            ),
            borderRadius: 22.0,
            elevation: 5.0,
            pageSize: 20,
            pageThreshold: 11,
            onLoadMore: ({required pageNumber, required pageSize}) async {
              logger.log("pageNumber: $pageNumber;\tpageSize: $pageSize");
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                  SnackBar(
                      content: Text(
                          'pageNumber: $pageNumber;\tpageSize: $pageSize')),
                );
              });
              const base = "https://meme-server.deno.dev";
              var response = await get(Uri.parse("$base/api/images"));
              var data = jsonDecode(response.body);
              List memes = List.from(data);
              return memes.map((e) => '$base${e['image']}').toList().sublist(
                    pageNumber * pageSize,
                    pageNumber * pageSize + pageSize,
                  );
            },
            builder: (String item, BuildContext _) => Image.network(
              item,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Changelog

### 1.0.0

- Refactored code using bloc pattern.
- Added swipe velocity as a configurable parameter.
- Improved animations and performance.
- Added double-tap interaction.
- Optional widgets for swipe actions (left and right).
- Enhanced layout and visibility options.
- Pagination support with `onLoadMore` callback.
- Added logging support.

---

## Parameters

### Required Parameters

#### `builder`

- **Type:** `Widget Function(T item, BuildContext context)`
- **Description:** A builder method that defines how each card is rendered based on the provided data of type `T`.

#### `onLoadMore`

- **Type:** `Future<List<T>> Function({required int pageSize, required int pageNumber})`
- **Description:** Loads more cards dynamically when the stack runs low.

### Optional Parameters

- `cardHeight`: Height of the cards.
- `cardWidth`: Width of the cards.
- `shownCards`: Number of visible cards in the stack.
- `cardDistance`: Distance between cards.
- `swipeVelocity`: Velocity threshold for swipe detection.
- `cardsAnimationInMilliseconds`: Duration of swipe animations.
- `behindCardsShouldBeOpaque`: Makes cards behind opaque.
- `onSwipeLeft`, `onSwipeRight`, `onDoubleTap`: Callbacks for actions.
- `onSwipedLeftAppear`, `onSwipedRightAppear`: Widgets for swipe visuals.
- `borderRadius`: Corner radius of cards.
- `elevation`: Shadow elevation.

---

## License

```
MIT License
```

---

## Contributions

Feel free to create issues or submit pull requests on [GitHub](https://github.com/melWiss/swipeable_cards).

