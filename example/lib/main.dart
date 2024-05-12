import 'dart:math';

import 'package:flutter/material.dart';

import 'package:roulette/roulette.dart';
import 'arrow.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roulette',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class MyRoulette extends StatelessWidget {
  const MyRoulette({
    Key? key,
    // required this.selectedIndex,
    required this.controller,
  }) : super(key: key);

  // final int selectedIndex;
  final RouletteController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SizedBox(
          width: 260,
          height: 260,
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Roulette(
              // Provide controller to update its state
              controller: controller,
              // Configure roulette's appearance
              style: const RouletteStyle(
                dividerThickness: 2,
                dividerColor: Color(0xFFDCEDFC),
                selectedDividerColor: Color(0xFF80B947),
                centerStickSizePercent: 0.08,
                centerStickerColor: Color(0xFFA5D6FF),
              ),
            ),
          ),
        ),
        // const Arrow(),
      ],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static final _random = Random();

  late RouletteController _controller;
  int selectedIndex = 0;

  final colors = <Color>[
    Colors.red.withAlpha(50),
    Colors.green.withAlpha(30),
    Colors.blue.withAlpha(70),
    Colors.yellow.withAlpha(90),
    Colors.amber.withAlpha(50),
    Colors.indigo.withAlpha(70),
    Colors.indigo.withAlpha(70),
    // Colors.indigo.withAlpha(70),
  ];

  final icons = <IconData>[
    Icons.ac_unit,
    Icons.access_alarm,
    Icons.access_time,
    Icons.accessibility,
    Icons.account_balance,
    Icons.account_balance_wallet,
    Icons.account_balance_wallet,
    // Icons.account_balance_wallet,
  ];

  final images = <ImageProvider>[
    // Use [AssetImage] if you have 2.0x, 3.0x images,
    // We only have 1 exact image here
    const NetworkImage("https://picsum.photos/seed/example1/400"),
    const NetworkImage("https://picsum.photos/seed/example2/400"),
    const NetworkImage("https://picsum.photos/seed/example3/400"),
    const NetworkImage("https://picsum.photos/seed/example4/400"),
    // const NetworkImage("https://bad.link.to.image"),
    const NetworkImage("https://picsum.photos/seed/example5/400"),
    const NetworkImage("https://picsum.photos/seed/example6/400"),
    // const NetworkImage("https://picsum.photos/seed/example7/400"),
    // const NetworkImage("https://picsum.photos/seed/example8/400"),
    // MemoryImage(...)
    // FileImage(...)
    // ResizeImage(...)
  ];

  @override
  void initState() {
    super.initState();

    // assert(colors.length == icons.length);
    // assert(colors.length == images.length);

    _controller = RouletteController(
      vsync: this,
      group: RouletteGroup.uniformImages(
        images.length,
        // colorBuilder: (index) => colors[index],
        imageBuilder: (index) => images[index],
        // textBuilder: (index) => '$index',
        styleBuilder: (index) {
          return const TextStyle(color: Colors.black);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roulette'),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              MyRoulette(controller: _controller),
            ],
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.pink.withOpacity(0.1),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Use the controller to run the animation with rollTo method
        onPressed: rollTo,
        child: const Icon(Icons.refresh_rounded),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  rollTo() {
    setState(() {
      selectedIndex = _random.nextInt(5);
    });
    debugPrint('selectedIndex: $selectedIndex');
    _controller.rollTo(
      selectedIndex,
      duration: const Duration(milliseconds: 600),
      minRotateCircles: 0,
      clockwise: _random.nextBool(),
      offset: images.length + 0.0,
    );
  }
}
