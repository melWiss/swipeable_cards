# EazySwipeableCards Widget Documentation

## Overview

The `EazySwipeableCards` widget allows you to create swipeable cards with custom swipe actions. It is useful for creating interactive UIs where users can swipe through a stack of cards and perform specific actions based on swipe directions.

![demo](https://github.com/melWiss/swipeable_cards/blob/master/media/output.gif?raw=true)

## Features

- Display a stack of customizable cards.
- Support for swipe gestures: left, right, and double-tap.
- Optional widgets to appear during swipe actions.
- Customizable card appearance with border radius and elevation settings.

## Installation

To use the `EazySwipeableCards` widget, add the corresponding package to your `pubspec.yaml`:

```yaml
dependencies:
  eazy_swipeable_cards: ^0.0.3
```

Run `flutter pub get` to fetch the package.

## Basic Usage

Here is an example demonstrating how to use the `EazySwipeableCards` widget:

### Full Example

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: EazySwipeableCards(
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
          children: [
            Container(color: Colors.orange),
            Container(color: Colors.green),
            Container(color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
```

## Properties

### Required Properties

- **`screenHeight`**

  - Type: `double`
  - Description: The height of the screen where the cards are displayed. Typically, set this using `MediaQuery.of(context).size.height`.

- **`screenWidth`**

  - Type: `double`
  - Description: The width of the screen where the cards are displayed. Typically, set this using `MediaQuery.of(context).size.width`.

### Optional Properties

- **`children`**

  - Type: `List<Widget?>?`
  - Description: A list of widgets to display as cards. Each card will be shown one at a time.

- **`onSwipeLeft`**

  - Type: `VoidCallback?`
  - Description: Callback triggered when a card is swiped left.

- **`onSwipeRight`**

  - Type: `VoidCallback?`
  - Description: Callback triggered when a card is swiped right.

- **`onDoubleTap`**

  - Type: `VoidCallback?`
  - Description: Callback triggered when a card is double-tapped.

- **`onSwipedLeftAppear`**

  - Type: `Widget?`
  - Description: Widget that appears when a card is swiped left.

- **`onSwipedRightAppear`**

  - Type: `Widget?`
  - Description: Widget that appears when a card is swiped right.

- **`borderRadius`**

  - Type: `double`
  - Default: `0.0`
  - Description: The border radius of the cards.

- **`elevation`**

  - Type: `double`
  - Default: `0.0`
  - Description: The elevation level of the cards, reflecting shadow intensity.

## Customization Tips

- Adjust the `children` to add custom content to your cards, such as images or detailed widgets.
- Use the `onSwipeLeft` and `onSwipeRight` callbacks to trigger app-specific actions, like navigation or state updates.
- Customize `onSwipedLeftAppear` and `onSwipedRightAppear` to provide visual feedback during swipe gestures.
- Modify `borderRadius` and `elevation` to tailor the visual style of the cards to your app's theme.

## Conclusion

The `EazySwipeableCards` widget simplifies the creation of interactive swipeable card UIs with highly customizable features. Its flexible API and straightforward integration make it a powerful choice for various Flutter applications.

