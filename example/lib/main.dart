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