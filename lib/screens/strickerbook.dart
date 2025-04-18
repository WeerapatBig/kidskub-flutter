import 'dart:math';

import 'package:firstly/screens/homepage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StickerBookPage extends StatefulWidget {
  const StickerBookPage({Key? key}) : super(key: key);

  @override
  State<StickerBookPage> createState() => _StickerBookPageState();
}

class _StickerBookPageState extends State<StickerBookPage> {
  @override
  void initState() {
    super.initState();
    //SharedPrefsService.resetAllStickers();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          const BackgroundWidget(),

          ..._buildFloatingImages(context),

          // Main Content
          Column(
            children: [
              // Title Section
              const TitleWidget(),

              // Sticker Book Section
              Expanded(
                child: Row(
                  children: [
                    // Left Side with Stickers
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(170, 0, 0, 50),
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/strickerbook/book1_left.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                          child: BookSideWidget(
                            stickers: [
                              StickerItem(
                                  key: 'sticker1',
                                  image:
                                      'assets/images/strickerbook/sticker1.png',
                                  imageOutline:
                                      'assets/images/strickerbook/sticker1_outline.png',
                                  top: screenHeight * 0.15,
                                  left: screenWidth * 0.035,
                                  width: screenWidth * 0.125),
                              StickerItem(
                                  key: 'sticker2',
                                  image:
                                      'assets/images/strickerbook/sticker2.png',
                                  imageOutline:
                                      'assets/images/strickerbook/sticker2_outline.png',
                                  top: screenHeight * 0.15,
                                  left: screenWidth * 0.18,
                                  width: screenWidth * 0.125),
                              StickerItem(
                                  key: 'sticker3',
                                  image:
                                      'assets/images/strickerbook/sticker3.png',
                                  imageOutline:
                                      'assets/images/strickerbook/sticker3_outline.png',
                                  top: screenHeight * 0.37,
                                  left: screenWidth * 0.18,
                                  width: screenWidth * 0.125),
                              StickerItem(
                                  key: 'sticker4',
                                  image:
                                      'assets/images/strickerbook/sticker4.png',
                                  imageOutline:
                                      'assets/images/strickerbook/sticker4_outline.png',
                                  top: screenHeight * 0.37,
                                  left: screenWidth * 0.035,
                                  width: screenWidth * 0.125),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Right Side with a Single Sticker
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 170, 50),
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/strickerbook/book1_right.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                          child: BookSideWidget(
                            stickers: [
                              StickerItem(
                                  key: 'sticker5',
                                  image:
                                      'assets/images/strickerbook/sticker5.png',
                                  imageOutline:
                                      'assets/images/strickerbook/sticker5_outline.png',
                                  top: screenHeight * 0.15,
                                  left: screenWidth * 0.045,
                                  width: screenWidth * 0.25),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Center(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 130, 0, 0),
                child: Container(
                  width: screenWidth * 0.08,
                  height: screenHeight * 0.5,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/strickerbook/screw.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                )),
          ),
          _buildBackButton(context),
        ],
      ),
    );
  }
}

Widget _buildBackButton(BuildContext context) {
  Size buttonSize = MediaQuery.of(context).size;
  double buttonWidth = MediaQuery.of(context).size.width * 0.028;
  double buttonHeight = MediaQuery.of(context).size.height * 0.028;
  return Positioned(
    width: buttonSize.width * 0.045,
    height: buttonSize.height * 0.085,
    left: buttonWidth,
    top: buttonHeight,
    child: FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomePage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      },
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Icon(
        Icons.arrow_back_ios_new_rounded,
        size: buttonSize.width * 0.05,
        color: const Color.fromARGB(255, 21, 21, 21),
      ),
    ),
  );
}

List<Widget> _buildFloatingImages(BuildContext context) {
  double floatingImageSize = MediaQuery.of(context).size.width * 0.15;
  return List.generate(4, (index) {
    return FloatingImage(
      imagePath: 'assets/images/strickerbook/bg_elm.png',
      width: floatingImageSize,
      height: floatingImageSize,
    );
  });
}

// Background Widget
class BackgroundWidget extends StatelessWidget {
  const BackgroundWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/strickerbook/grid.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// Title Widget
class TitleWidget extends StatelessWidget {
  const TitleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
      child: Image.asset(
        'assets/images/strickerbook/title.png',
        height: screenHeight * 0.15, // Adjust title size dynamically
        fit: BoxFit.contain,
      ),
    );
  }
}

// Book Side Widget
class BookSideWidget extends StatelessWidget {
  final List<StickerItem> stickers;

  const BookSideWidget({
    Key? key,
    required this.stickers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: stickers.map((sticker) {
        return PositionedSticker(
          sticker: sticker,
        );
      }).toList(),
    );
  }
}

class StickerBookPrefsService {
  static Future<bool> loadIsCollected(String? stickerKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(stickerKey ?? '') ?? false;
  }

  // static Future<void> saveIsCollected(String? stickerKey, bool isCollected) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool(stickerKey ?? '', isCollected);
  // }

  Future<void> clearAllPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ล้างข้อมูลทั้งหมดใน SharedPreferences
  }

  static Future<void> saveIsCollected(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<bool> getIsCollected(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  // Reset specific sticker
  static Future<void> resetSticker(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key); // Remove the specific key
  }

  // Reset all stickers
  static Future<void> resetAllStickers() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> stickerKeys = [
      'sticker1',
      'sticker2',
      'sticker3',
      'sticker4',
      'sticker5',
    ]; // Add all sticker keys here

    for (String key in stickerKeys) {
      await prefs.remove(key); // Remove each key
    }
  }

  void resetStickerData() async {
    await StickerBookPrefsService.resetAllStickers();
    print('Sticker data has been reset!');
  }
}

// Positioned Sticker Widget
class PositionedSticker extends StatelessWidget {
  final StickerItem sticker;

  const PositionedSticker({
    Key? key,
    required this.sticker,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool?>(
      future: StickerBookPrefsService.getIsCollected(sticker.key),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }
        bool isCollected = snapshot.data ?? false;
        return Positioned(
            // Adjust position dynamically (example values here, customize as needed)
            top: sticker.top,
            left: sticker.left,
            child: Image.asset(
              isCollected
                  ? sticker.image // Display collected sticker
                  : sticker.imageOutline, // Display outline sticker
              width: sticker.width,
              fit: BoxFit.contain,
            ));
      },
    );
  }
}

// Sticker Item Model
class StickerItem {
  final String key; // Key used in SharedPreferences
  final String image;
  final String imageOutline;
  final double top; // Add width parameter
  final double left; // Add height parameter
  final double width; // Add width parameter

  StickerItem({
    required this.key,
    required this.image,
    required this.imageOutline,
    required this.top,
    required this.left,
    required this.width,
  });

  Future<bool> getIsCollected() async {
    // Get isCollected from SharedPreferences with a default value
    return await StickerBookPrefsService.getIsCollected(key);
  }
}

class FloatingImage extends StatefulWidget {
  final String imagePath;
  final double width;
  final double height;

  const FloatingImage({
    required this.imagePath,
    required this.width,
    required this.height,
  });

  @override
  _FloatingImageState createState() => _FloatingImageState();
}

class _FloatingImageState extends State<FloatingImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double _startX;
  late double _startY;
  late double _dx;
  late double _dy;
  late Random _random;

  @override
  void initState() {
    super.initState();
    _random = Random();

    _controller = AnimationController(
      duration: Duration(seconds: 50 + _random.nextInt(10)),
      vsync: this,
    )..repeat();

    _startX = _random.nextDouble() * 2 * pi;
    _startY = _random.nextDouble() * 2 * pi;
    _dx = (_random.nextDouble() - 0.5) * 2 * pi;
    _dy = (_random.nextDouble() - 0.5) * 2 * pi;
  }

  @override
  void dispose() {
    // ตรวจสอบให้แน่ใจว่า AnimationController ถูก dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double t = _controller.value * 5 * pi;
        double x = 0.5 + 0.5 * sin(t * _dx + _startX);
        double y = 0.5 + 0.5 * cos(t * _dy + _startY);

        double posX = x * (screenSize.width - widget.width);
        double posY = y * (screenSize.height - widget.height);

        // Calculate rotation
        double rotationAngle = t; // Rotate based on time

        return Positioned(
          left: posX,
          top: posY,
          child: Transform.rotate(
            angle: rotationAngle * 10,
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: child!,
            ),
          ),
        );
      },
      child: Image.asset(widget.imagePath),
    );
  }
}
