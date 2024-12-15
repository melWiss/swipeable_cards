# SwipeableCards Widget Documentation

## Overview

The `SwipeableCards` widget allows you to create swipeable cards with custom swipe actions. It is useful for creating interactive UIs where users can swipe through a stack of cards and perform specific actions based on swipe directions.

![demo](https://github.com/melWiss/swipeable_cards/blob/master/media/output.gif?raw=true)

## Features

- Display a stack of cards with customizable child widgets.
- Handle swipe gestures (e.g., left or right swipes) using callback functions.
- Optional widgets to appear on swipe actions.
- Flexible layout with customizable borders and interactive double-tap behavior.

## Installation

To use the `SwipeableCards` widget, add the `eazy_swipeable_cards` package to your `pubspec.yaml`:

```yaml
dependencies:
  eazy_swipeable_cards: ^0.0.1
```

Run `flutter pub get` to fetch the package.

## Basic Usage

Below is an example demonstrating how to use the `SwipeableCards` widget:

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
      title: 'Swipeable Cards Example',
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
        child: SwipeableCards(
          screenHeight: MediaQuery.of(context).size.height,
          screenWidth: MediaQuery.of(context).size.width,
          onSwipeLeft: () {
            setState(() {
              counter++;
            });
          },
          onSwipeRight: () {
            setState(() {
              counter--;
            });
          },
          onDoubleTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Card Double-Tapped!')),
            );
          },
          onSwipedLeftAppear: Container(
            alignment: Alignment.center,
            color: Colors.red.withOpacity(0.5),
            child: const Icon(Icons.thumb_down, size: 100, color: Colors.white),
          ),
          onSwipedRightAppear: Container(
            alignment: Alignment.center,
            color: Colors.green.withOpacity(0.5),
            child: const Icon(Icons.thumb_up, size: 100, color: Colors.white),
          ),
          borderColor: Colors.black,
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.yellow,
            ),
            Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.blue,
            ),
            Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.green,
            ),
            Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.red,
            ),
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

- **`children`**

  - Type: `List<Widget>`
  - Description: A list of widgets to display as cards.

### Optional Callbacks

- **`onSwipeLeft`**

  - Type: `VoidCallback?`
  - Description: Called when a card is swiped left.

- **`onSwipeRight`**

  - Type: `VoidCallback?`
  - Description: Called when a card is swiped right.

- **`onDoubleTap`**

  - Type: `VoidCallback?`
  - Description: Called when a card is double-tapped.

### Optional Appearance Properties

- **`onSwipedLeftAppear`**

  - Type: `Widget?`
  - Description: An optional widget that appears when a card is swiped left.

- **`onSwipedRightAppear`**

  - Type: `Widget?`
  - Description: An optional widget that appears when a card is swiped right.

- **`borderColor`**

  - Type: `Color?`
  - Description: The color of the border around each card. If not specified, the border is transparent by default.

## Example Explanation

1. **App Structure**:

   - The app uses the `SwipeableCards` widget inside the `MyHomePage` class.
   - The cards are full-screen containers with different colors.

2. **Handling Swipes**:

   - The `onSwipeLeft` callback increments a counter, while the `onSwipeRight` callback decrements it.

3. **Custom Behavior**:

   - The `onDoubleTap` callback displays a `SnackBar` when a card is double-tapped.
   - The `onSwipedLeftAppear` and `onSwipedRightAppear` properties show widgets for swipe indicators.

4. **Responsiveness**:

   - The `screenHeight` and `screenWidth` are set using `MediaQuery` to ensure the widget adapts to different screen sizes.

5. **Appearance**:

   - Use the `borderColor` property to add or customize the border around each card.

## Customization Tips

- Modify the `children` list to add custom content to your cards (e.g., images, text).
- Use `onSwipeLeft` and `onSwipeRight` to trigger specific actions, such as navigating to a new screen or updating state.
- Customize `onSwipedLeftAppear` and `onSwipedRightAppear` to provide user feedback for swipe actions.
- Adjust `borderColor` to match the app’s theme or card design.

## Troubleshooting

- Ensure the `SwipeableCards` widget is wrapped in a `Center` or appropriate layout to avoid overflow issues.
- Verify that swipe gestures are not blocked by overlapping widgets or layouts.

## Conclusion

The `SwipeableCards` widget is a versatile and easy-to-use component for creating swipeable interfaces. With minimal setup and high customizability, it can fit a wide range of use cases in your Flutter app.

