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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: EazySwipeableCards2<(MaterialColor, int, int)>(
            cardHeight: 400,
            cardWidth: MediaQuery.sizeOf(context).width,
            shownCards: 9,
            cardDistance: 75,
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
            pageThreshold: 10,
            onLoadMore: ({required pageNumber, required pageSize}) {
              logger.log("pageNumber: $pageNumber;\tpageSize: $pageSize");
              return Future.value([
                (Colors.orange, 0, pageNumber),
                (Colors.green, 1, pageNumber),
                (Colors.blue, 2, pageNumber),
                (Colors.red, 3, pageNumber),
                (Colors.pink, 4, pageNumber),
                (Colors.orange, 0, pageNumber),
                (Colors.green, 1, pageNumber),
                (Colors.blue, 2, pageNumber),
                (Colors.red, 3, pageNumber),
                (Colors.pink, 4, pageNumber),
                (Colors.orange, 0, pageNumber),
                (Colors.green, 1, pageNumber),
                (Colors.blue, 2, pageNumber),
                (Colors.red, 3, pageNumber),
                (Colors.pink, 4, pageNumber),
                (Colors.orange, 0, pageNumber),
                (Colors.green, 1, pageNumber),
                (Colors.blue, 2, pageNumber),
                (Colors.red, 3, pageNumber),
                (Colors.pink, 4, pageNumber),
              ]);
            },
            builder: ((MaterialColor, int, int) item, BuildContext _) => Container(
              color: item.$1,
              child: Center(
                child: Text(
                  'Card ${item.$2}, Page ${item.$3}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
