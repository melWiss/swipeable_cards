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

---

## Getting Started

To use the `EazySwipeableCards` widget in your Flutter project, first, add the `eazy_swipeable_cards` package to your `pubspec.yaml` file.

```yaml
dependencies:
  eazy_swipeable_cards: ^0.0.4
```

Then, import the package:

```dart
import 'package:eazy_swipeable_cards/eazy_swipeable_cards.dart';
```

---

## Usage Example

```dart
import 'package:flutter/material.dart';
import 'package:eazy_swipeable_cards/eazy_swipeable_cards.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EazySwipeableCards Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
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
        child: EazySwipeableCards<MaterialColor>(
          screenHeight: MediaQuery.of(context).size.height,
          screenWidth: MediaQuery.of(context).size.width,
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
          borderRadius: 12.0,
          elevation: 5.0,
          pageSize: 6,
          pageThreshold: 3,
          onLoadMore: ({required pageNumber, required pageSize}) async {
            logger.log("pageNumber: $pageNumber;\tpageSize: $pageSize");
            await Future.delayed(const Duration(seconds: 3));
            return Future.value([
              Colors.orange,
              Colors.green,
              Colors.blue,
              Colors.orange,
              Colors.green,
              Colors.blue,
            ]);
          },
          builder: (MaterialColor item, BuildContext _) => Container(
            color: item,
          ),
        ),
      ),
    );
  }
}
```

---

## Parameters

### Required Parameters

#### `builder`

- **Type:** `Widget Function(T item, BuildContext context)`
- **Description:** A builder method that defines how each card is rendered based on the provided data of type `T`.

### Optional Parameters

#### `onLoadMore`

- **Type:** `Future<List<T>> Function({required int pageSize, required int pageNumber})?`
- **Description:** A callback to load more items when the stack is running low. Pagination logic is handled here.

#### `onSwipeLeft`

- **Type:** `void Function()?`
- **Description:** A callback triggered when a card is swiped left.

#### `onSwipeRight`

- **Type:** `void Function()?`
- **Description:** A callback triggered when a card is swiped right.

#### `onDoubleTap`

- **Type:** `void Function()?`
- **Description:** A callback triggered when a card is double-tapped.

#### `onSwipedLeftAppear`

- **Type:** `Widget?`
- **Description:** A widget displayed when a card is swiped left.

#### `onSwipedRightAppear`

- **Type:** `Widget?`
- **Description:** A widget displayed when a card is swiped right.

#### `borderRadius`

- **Type:** `double`
- **Default:** `0`
- **Description:** The border radius of the cards.

#### `elevation`

- **Type:** `double`
- **Default:** `0`
- **Description:** The elevation level of the cards.

#### `pageSize`

- **Type:** `int`
- **Default:** `1`
- **Description:** Determines the number of cards to load per page.

#### `pageThreshold`

- **Type:** `int`
- **Default:** `0`
- **Description:** Defines the threshold at which more items are loaded.

---

## Deprecated Parameters

### `screenHeight`

- **Type:** `double`
- **Description:** Previously used to define the height of the cards. The widget now takes the entire available space.

### `screenWidth`

- **Type:** `double`
- **Description:** Previously used to define the width of the cards. The widget now takes the entire available space.

---

## Migration Notes

For existing implementations using `screenHeight` and `screenWidth`, simply remove these parameters, as the widget now automatically adapts to the available space.

