import 'dart:math';
import 'dart:ui';
import 'package:firstly/widgets/showkey.dart';
import 'package:firstly/widgets/showsticker.dart';
import 'package:firstly/screens_chapter1/dotgamehard.dart';
import 'package:firstly/screens_chapter1/motionlevel1.dart';
import 'package:firstly/screens_chapter1/quizgamedot.dart';
import 'package:firstly/screens_chapter1/dotgameeasy.dart';
import 'package:flutter/material.dart';
import 'package:firstly/screens/gameselectionpage.dart';

import '../../function/background_audio_manager.dart';
import '../../function/pulse_effect.dart';
import 'gamelist_data.dart';
import 'gamelist_logic.dart';

class DotGameList extends StatefulWidget {
  const DotGameList({super.key});

  @override
  _DotGameListState createState() => _DotGameListState();
}

class _DotGameListState extends State<DotGameList>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    levels = initializeLevels();

    // เล่นเพลงเมื่อเข้าหน้านี้
    BackgroundAudioManager().playBackgroundMusic();
  }

  // เมื่อผู้เล่นออกจากหน้า DotGameList จะเรียกฟังก์ชัน onBackButtonPressed() จาก logic
  void onBackButtonPressedLocal() {
    onBackButtonPressed(); // เรียกใช้จาก dotgame_logic.dart
    print('Saved hasKey2: $hasKey2');
  }

  @override
  Widget build(BuildContext context) {
    double sreenWidth = MediaQuery.of(context).size.width;
    double sreenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundImage(),
          ..._buildFloatingImages(context),
          const BackdropBlurEffect(),
          _buildBackButton(context),
          Center(child: _buildLevelSelection(context)),
          Container(
            height: sreenHeight * 0.4,
            width: sreenWidth * 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  if (isLevel2Unlocked)
                    Positioned(
                        left: sreenWidth * 0.38,
                        top: sreenHeight * 0.16,
                        width: sreenWidth * 0.12,
                        height: sreenHeight * 0.2,
                        child: Image.asset(
                            'assets/images/dotchapter/card1_level.png')),
                  if (isLevel3Unlocked)
                    Positioned(
                        left: sreenWidth * 0.61,
                        top: sreenHeight * 0.16,
                        width: sreenWidth * 0.12,
                        height: sreenHeight * 0.2,
                        child: Image.asset(
                            'assets/images/dotchapter/card2_level.png')),
                  if (isQuizUnlocked)
                    Positioned(
                        left: sreenWidth * 0.81,
                        top: sreenHeight * 0.17,
                        width: sreenWidth * 0.17,
                        height: sreenHeight * 0.2,
                        child: Image.asset(
                            'assets/images/dotchapter/card3_level.png')),
                ],
              ),
            ),
          ),
          _buildStarsDisplay(context),
          const CharacterAnimation(
            imagePath: 'assets/images/dotchapter/chractor1.png',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingImages(BuildContext context) {
    double floatingImageSize = MediaQuery.of(context).size.width * 0.15;
    return List.generate(4, (index) {
      return FloatingImage(
        imagePath: 'assets/images/dotchapter/elm.png',
        width: floatingImageSize,
        height: floatingImageSize,
      );
    });
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
          BackgroundAudioManager().playButtonBackSound(); // เล่นเสียงกดปุ่ม
          //onBackButtonPressed();
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const GameSelectionPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(-1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                final tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 1000),
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

  Widget _buildLevelSelection(BuildContext context) {
    double itemWidth = MediaQuery.of(context).size.width / 4.5;
    double itemHeight = MediaQuery.of(context).size.height * 0.8;

    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: levels.map((level) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () => _onLevelTap(context, level),
              child: SizedBox(
                width: itemWidth,
                height: itemHeight,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      level['unlocked'] == true
                          ? level['unlockedImage']
                          : level['lockedImage'],
                      fit: BoxFit.contain,
                    ),
                    if (level['unlocked'] == true)
                      Positioned(
                        child: _buildLevelStars(level, itemWidth),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLevelStars(Map<String, dynamic> level, double itemWidth) {
    int earnedStars = level['earnedStars'] ?? 0;
    String starColor = level['starColor'] ?? '';
    double starSize = itemWidth * 0.68;
    String starAsset = '';

    if (starColor == 'yellow') {
      switch (earnedStars) {
        case 0:
          starAsset = 'assets/images/dotchapter/yellow_stars_empty.png';
          break;
        case 1:
          starAsset = 'assets/images/dotchapter/yellow_stars_one.png';
          break;
        case 2:
          starAsset = 'assets/images/dotchapter/yellow_stars_two.png';
          break;
        case 3:
          starAsset = 'assets/images/dotchapter/yellow_stars_full.png';
          break;
        default:
          starAsset = 'assets/images/dotchapter/yellow_stars_empty.png';
      }
    } else if (starColor == 'purple') {
      starAsset = earnedStars == 0
          ? 'assets/images/dotchapter/purple_stars_empty.png'
          : 'assets/images/dotchapter/purple_stars_full.png';
    } else {
      return const SizedBox();
    }

    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter, // จัดตำแหน่งรูปภาพให้อยู่มุมขวาบน
          child: Padding(
            padding:
                const EdgeInsets.only(bottom: 8, right: 18), // ระยะห่างจากขอบ
            child: Image.asset(
              starAsset,
              width: starSize + 50,
              height: starSize,
              fit: BoxFit.fitHeight, // ให้รูปภาพคงสัดส่วน
            ),
          ),
        ),
      ],
    );
  }

  void _onLevelTap(BuildContext context, Map<String, dynamic> level) async {
    final updatedLevel = await prefsService.loadLevelData(level['name']);
    if (level['unlocked'] == true) {
      // หยุดเพลงก่อนเข้าสู่ Level
      BackgroundAudioManager().pauseBackgroundMusic();
      if (level['name'] == 'Motion') {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MotionLevel1(),
          ),
        );
        // หยุดเพลงก่อนเข้าสู่ Level
        BackgroundAudioManager().playBackgroundMusic();

        setState(() {
          level['earnedStars'] = updatedLevel['earnedStars'];
          level['starColor'] = updatedLevel['starColor'];
          level['unlocked'] = updatedLevel['unlocked'];
        });
        await updateTotalStars(); // เปิดหน้า ShowStickerPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowStickerPage(stickerKey: level['sticker']),
          ),
        );

        await unlockNextLevel('Motion');
        print('--- Debug after unlockNextLevel Motion ---');
        levels.forEach((lv) => print(lv));
      } else if (level['name'] == 'Level 2') {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DotGameEasy(),
          ),
        );
        setState(() {
          level['earnedStars'] = updatedLevel['earnedStars'];
          level['starColor'] = updatedLevel['starColor'];
          level['unlocked'] = updatedLevel['unlocked'];
        });
        await updateTotalStars(); // เปิดหน้า ShowStickerPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowStickerPage(stickerKey: level['sticker']),
          ),
        );

        await unlockNextLevel('Level 2');
        print('--- Debug after unlockNextLevel Level 2 ---');
        levels.forEach((lv) => print(lv));
      } else if (level['name'] == 'Level 3') {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DotGameHard(),
          ),
        );

        setState(() {
          level['earnedStars'] = updatedLevel['earnedStars'];
          level['starColor'] = updatedLevel['starColor'];
          level['unlocked'] = updatedLevel['unlocked'];
        });
        await updateTotalStars(); // เปิดหน้า ShowStickerPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowStickerPage(stickerKey: level['sticker']),
          ),
        );

        // ปลดล็อคด่านถัดไปถ้าจำเป็น
        await unlockNextLevel('Level 3');
      } else if (level['name'] == 'Quiz') {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DotQuizGame(), // เพิ่มหน้า QuizPage() ตามที่ต้องการ
          ),
        );
        setState(() {
          level['earnedStars'] = updatedLevel['earnedStars'];
          level['starColor'] = updatedLevel['starColor'];
          level['unlocked'] = updatedLevel['unlocked'];
        });
        await updateTotalStars();
        // เปิดหน้า ShowStickerPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowStickerPage(stickerKey: level['sticker']),
          ),
        );
      }
    } else {
      showUnlockWarning(context, this);
    }
  }

  bool hasClaimedPurpleStar = false;
  bool hasClaimedYellowStar = false;

  Widget _buildStarsDisplay(BuildContext context) {
    double starSize = MediaQuery.of(context).size.width * 0.2;
    double paddingHorizontal = MediaQuery.of(context).size.width * 0.05;
    double paddingVertical = MediaQuery.of(context).size.height * 0.05;

    return Positioned(
      bottom: paddingVertical * -1.7,
      right: paddingHorizontal * 0.5,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: yellowStars == 5 && !hasClaimedYellowStar
                ? () async {
                    // แสดง ShowStickerPage เมื่อกด
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ShowKeyPage(stickerKey: 'sticker6'),
                      ),
                    );
                    // อัปเดตสถานะหลังจากกดรับแล้ว
                    setState(() {
                      hasClaimedYellowStar = true;
                    });
                  }
                : null, // ไม่ให้กดหากยังไม่มีดาวม่วง
            child: AnimatedOpacity(
              duration: const Duration(seconds: 1),
              opacity: yellowStars == 5 && !hasClaimedYellowStar
                  ? 0.9
                  : 1.0, // ถ้ามีดาวม่วง เรืองแสงเต็ม
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (yellowStars == 5 && !hasClaimedYellowStar)
                    PulseEffect(
                      size: starSize - 80,
                      color: const Color.fromARGB(255, 255, 187, 14)
                          .withOpacity(0.5),
                      position: const Offset(-40, 0),
                    ), // ใส่เอฟเฟกต์เรืองแสง
                  Image.asset(
                    'assets/images/dotchapter/yellow_stars_${getYellowStarImageName(yellowStars)}.png',
                    width: starSize,
                    height: starSize,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // ดาวสีม่วง
          GestureDetector(
            onTap: purpleStars == 1 && !hasClaimedPurpleStar
                ? () async {
                    onBackButtonPressed();
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ShowStickerPage(stickerKey: 'sticker5'),
                      ),
                    );
                    // อัปเดตสถานะหลังจากกดรับแล้ว
                    setState(() {
                      hasClaimedPurpleStar = true;
                    });
                  }
                : null, // ไม่ให้กดหากยังไม่มีดาวม่วง
            child: AnimatedOpacity(
              duration: const Duration(seconds: 1),
              opacity: purpleStars == 1 && !hasClaimedPurpleStar
                  ? 0.9
                  : 1.0, // ถ้ามีดาวม่วง เรืองแสงเต็ม
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (purpleStars == 1 && !hasClaimedPurpleStar)
                    PulseEffect(
                      size: starSize - 80,
                      color: Colors.purple.withOpacity(0.3),
                      position: const Offset(-40, 0),
                    ), // ใส่เอฟเฟกต์เรืองแสง
                  Image.asset(
                    'assets/images/dotchapter/purple_stars_${getPurpleStarImageName(purpleStars)}.png',
                    width: starSize,
                    height: starSize,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Image.asset(
        'assets/images/dotchapter/bg.png',
        fit: BoxFit.cover,
      ),
    );
  }
}

class BackdropBlurEffect extends StatelessWidget {
  const BackdropBlurEffect({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
      child: Container(
        color: Colors.white.withOpacity(0.1),
      ),
    );
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
        double t = _controller.value * 2 * pi;
        double x = 0.5 + 0.5 * sin(t * _dx + _startX);
        double y = 0.5 + 0.5 * cos(t * _dy + _startY);

        double posX = x * (screenSize.width - widget.width);
        double posY = y * (screenSize.height - widget.height);

        return Positioned(
          left: posX,
          top: posY,
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: child!,
          ),
        );
      },
      child: Image.asset(widget.imagePath),
    );
  }
}

class CharacterAnimation extends StatefulWidget {
  final String imagePath;

  const CharacterAnimation({required this.imagePath});

  @override
  _CharacterAnimationState createState() => _CharacterAnimationState();
}

class _CharacterAnimationState extends State<CharacterAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // เรียกเมื่อหน้ากลับมาทำงาน
    BackgroundAudioManager().playBackgroundMusic();

    double screenWidth = MediaQuery.of(context).size.width;
    double characterSize = screenWidth * 0.1;

    _positionAnimation = Tween<double>(
      begin: -characterSize,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: -45.0,
      end: 15.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double characterSize = MediaQuery.of(context).size.width * 0.23;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          bottom: -50,
          left: _positionAnimation.value - 50,
          child: Transform.rotate(
            angle: _rotationAnimation.value * pi / 180,
            child: Image.asset(
              widget.imagePath,
              width: characterSize,
              height: characterSize,
            ),
          ),
        );
      },
    );
  }
}
