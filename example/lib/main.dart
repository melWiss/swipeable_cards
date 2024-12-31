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
          child: EazySwipeableCards2<String>(
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
