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