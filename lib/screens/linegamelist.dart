import 'dart:math';
import 'dart:ui';
import 'package:firstly/widgets/showkey.dart';
import 'package:firstly/widgets/showsticker.dart';
import 'package:firstly/screens/shared_prefs_service.dart';
import 'package:firstly/screens_chapter2/line_game_hard_screen.dart';
import 'package:firstly/screens_chapter2/line_game_quiz.dart';
import 'package:firstly/screens_chapter2/line_game_easy.dart';
import 'package:flutter/material.dart';
import 'package:firstly/screens/gameselectionpage.dart';

import '../function/pulse_effect.dart';
import '../screens_chapter2/line_game_motion.dart';

class LineGameList extends StatefulWidget {
  const LineGameList({super.key});

  @override
  _LineGameListState createState() => _LineGameListState();
}

class _LineGameListState extends State<LineGameList>
    with TickerProviderStateMixin {
  // สถานะการปลดล็อคของด่านต่างๆ
  bool isLevel1Unlocked = true;
  bool isLevel2Unlocked = true;
  bool isLevel3Unlocked = true;
  bool isQuizUnlocked = true;

  bool isWarningVisible = false;

  bool hasKey2 = false; // สถานะการปลดล็อค Chapter 2
  final SharedPrefsService _prefsService =
      SharedPrefsService(); // สร้าง instance ของ SharedPrefsService

  // จำนวนดาวที่ผู้ใช้สะสมได้
  int purpleStars = 0;
  int yellowStars = 0;

  late List<Map<String, dynamic>> levels;

  @override
  void initState() {
    super.initState();
    levels = initializeLevels();
  }

  void updateTotalStars() {
    int totalYellowStars = 0;
    int totalPurpleStars = 0;

    for (var level in levels) {
      if (level['starColor'] == 'yellow') {
        totalYellowStars += level['earnedStars'] as int;
      } else if (level['starColor'] == 'purple') {
        totalPurpleStars += level['earnedStars'] as int;
      }
    }

    setState(() {
      yellowStars = totalYellowStars.clamp(0, 5);
      // ถ้าดาวสีเหลืองครบ 5 ดวงแล้ว ให้ทำการส่งค่ากลับไปยัง GameSelectionPage
      if (yellowStars >= 5) {
        hasKey2 = true; // ส่งข้อมูลไปปลดล็อค Chapter ถัดไป
        _prefsService.saveKeyStatus(
            'hasKey2', hasKey2); // บันทึกข้อมูลใน SharedPreferences
        print(
            'You have yellow stars: $yellowStars .Now you can unlock chapter2');
      }
      purpleStars = totalPurpleStars.clamp(0, 1);
      print('Updated total stars: $yellowStars yellow, $purpleStars purple');
    });
  }

  // เมื่อผู้เล่นออกจากหน้า DotGameList จะส่งค่าการปลดล็อคกลับไป
  void onBackButtonPressed() {
    _prefsService.saveKeyStatus(
        'hasKey2', hasKey2); // เก็บค่าสถานะกุญแจใน SharedPreferences
    print('Saved hasKey2: $hasKey2'); // เพิ่มการดีบัค
  }

  List<Map<String, dynamic>> initializeLevels() {
    return [
      {
        'name': 'Motion',
        'unlocked': isLevel1Unlocked,
        'lockedImage': 'assets/images/linegamelist/card_lock.png',
        'unlockedImage': 'assets/images/linegamelist/card_comic.png',
        'maxStars': 0,
        'earnedStars': 0,
        'starColor': '',
        'sticker': 'sticker1',
      },
      {
        'name': 'Level 2',
        'unlocked': isLevel2Unlocked,
        'lockedImage': 'assets/images/linegamelist/card_lock.png',
        'unlockedImage': 'assets/images/linegamelist/lv1_card_unlock.png',
        'maxStars': 3,
        'earnedStars': 0,
        'starColor': 'yellow',
        'sticker': 'sticker2',
      },
      {
        'name': 'Level 3',
        'unlocked': isLevel3Unlocked,
        'lockedImage': 'assets/images/linegamelist/card_lock.png',
        'unlockedImage': 'assets/images/linegamelist/lv2_card_unlock.png',
        'maxStars': 3,
        'earnedStars': 0,
        'starColor': 'yellow',
        'sticker': 'sticker3',
      },
      {
        'name': 'Quiz',
        'unlocked': isQuizUnlocked,
        'lockedImage': 'assets/images/linegamelist/card_lock.png',
        'unlockedImage': 'assets/images/linegamelist/quiz_card_unlock.png',
        'maxStars': 1,
        'earnedStars': 0,
        'starColor': 'purple',
        'sticker': 'sticker4',
      },
    ];
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
            imagePath: 'assets/images/linegamelist/charactor_line.png',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingImages(BuildContext context) {
    double floatingImageSize = MediaQuery.of(context).size.width * 0.25;
    return List.generate(4, (index) {
      return FloatingImage(
        imagePath: 'assets/images/line.png',
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
                    if (level['unlocked'] == true && level['maxStars'] > 0)
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

    print(
        'Building stars for level with $earnedStars stars and color $starColor');

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
    if (level['unlocked'] == true) {
      dynamic result;
      if (level['name'] == 'Motion') {
        result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LineGameMotion(),
          ),
        );
        // ดีบัคเพื่อดูค่าที่ได้รับจาก MotionLevel1
        print('Received result from MotionLevel1: $result');

        // ตรวจสอบผลลัพธ์ที่ได้รับเมื่อหน้าถูกปิด
        if (result != null) {
          setState(() {
            if (level.containsKey('earnedStars')) {
              level['earnedStars'] = result['earnedStars'];
            } else {
              print('Error: earnedStars key not found in level');
            }

            if (level.containsKey('starColor')) {
              level['starColor'] = result['starColor'];
            } else {
              print('Error: starColor key not found in level');
            }

            // ดีบัคเพื่อดูการอัปเดต
            print(
                'Updated levels: ${level['earnedStars']} stars, color: ${level['starColor']}');

            // อัปเดตจำนวนดาวทั้งหมด
            updateTotalStars();
          }); // เปิดหน้า ShowStickerPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ShowStickerPage(stickerKey: level['sticker']),
            ),
          );

          unlockNextLevel('Motion');
        } else {
          print('No result returned for level: ${level['name']}');
        }
      } else if (level['name'] == 'Level 2') {
        result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DrawLineGameScreen(),
          ),
        );

        // เพิ่มการดีบัคตรงนี้เพื่อดูค่าที่ได้รับจาก DotGameEazy
        print('Received result from DotGameEazy: $result');

        //ตรวจสอบผลลัพธ์ที่ได้รับเมื่อหน้าถูกปิด
        if (result != null) {
          setState(() {
            if (level.containsKey('earnedStars')) {
              level['earnedStars'] = result['earnedStars'];
            } else {
              print('Error: earnedStars key not found in level');
            }

            if (level.containsKey('starColor')) {
              level['starColor'] = result['starColor'];
            } else {
              print('Error: starColor key not found in level');
            }

            // ดีบัคเพื่อดูการอัปเดต
            print(
                'Updated levels: ${level['earnedStars']} stars, color: ${level['starColor']}');

            // อัปเดตจำนวนดาวทั้งหมด
            updateTotalStars();
          }); // เปิดหน้า ShowStickerPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ShowStickerPage(stickerKey: level['sticker']),
            ),
          );

          unlockNextLevel('Level 2');
        } else {
          print('No result returned for level: ${level['name']}');
        }
      } else if (level['name'] == 'Level 3') {
        result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LineGameHardScreen(),
          ),
        );

        if (result != null) {
          setState(() {
            level['earnedStars'] = result['earnedStars'];
            level['starColor'] = result['starColor'];

            updateTotalStars();
          }); // เปิดหน้า ShowStickerPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ShowStickerPage(stickerKey: level['sticker']),
            ),
          );

          // ปลดล็อคด่านถัดไปถ้าจำเป็น
          unlockNextLevel('Level 3');
        } else {
          print('No result returned for level: ${level['name']}');
        }
      } else if (level['name'] == 'Quiz') {
        result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                QuizLineGame(), // เพิ่มหน้า QuizPage() ตามที่ต้องการ
          ),
        );
        if (result != null) {
          setState(() {
            level['earnedStars'] = result['earnedStars'];
            level['starColor'] = result['starColor'];

            print(
                'Updated Quiz Level: ${level['earnedStars']} stars, color: ${level['starColor']}');

            updateTotalStars();
          });
          // เปิดหน้า ShowStickerPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ShowStickerPage(stickerKey: level['sticker']),
            ),
          );
        } else {
          print('No result returned for level: ${level['name']}');
        }
      }
    } else {
      showUnlockWarning(context);
    }
  }

  void showUnlockWarning(BuildContext context) {
    // ถ้ากำลังแสดง popup อยู่ ไม่ต้องแสดงซ้ำ
    if (isWarningVisible) return;

    // ตั้งค่าสถานะให้กำลังแสดง popup
    setState(() {
      isWarningVisible = true; // ตั้งค่าว่าแอนิเมชันกำลังทำงาน
    });

    // สร้าง AnimationController สำหรับอนิเมชันการเลื่อนเข้าและออก
    final animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // สร้าง OverlayEntry สำหรับ Pop-up
    late OverlayEntry overlayEntry;

    // ฟังก์ชันสำหรับลบ OverlayEntry
    void removeOverlay() {
      animationController.reverse().then((value) {
        overlayEntry.remove();
        animationController.dispose();
        setState(() {
          isWarningVisible = false; // รีเซ็ตสถานะเมื่อแอนิเมชันเสร็จสิ้น
        });
      });
    }

    // สร้าง OverlayEntry
    overlayEntry = OverlayEntry(
      builder: (context) {
        // สร้างอนิเมชันการเลื่อน
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, -1.0), // เริ่มจากนอกหน้าจอด้านบน
          end: const Offset(0.0, 0.0), // เลื่อนเข้ามาในหน้าจอ
        ).animate(CurvedAnimation(
          parent: animationController,
          curve: Curves.easeOut,
        ));

        return Positioned(
          top: MediaQuery.of(context).size.height * 0, // ตำแหน่งบนหน้าจอ
          right:
              MediaQuery.of(context).size.width * 0.35, // ตำแหน่งขวาของหน้าจอ
          child: SlideTransition(
            position: slideAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.3,
                height: MediaQuery.of(context).size.height * 0.2,
                child: Image.asset(
                  'assets/images/dotchapter/unlock_notification.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );

    // แสดง OverlayEntry
    Overlay.of(context).insert(overlayEntry);

    // เริ่มอนิเมชันเลื่อนเข้า
    animationController.forward();

    // ตั้งเวลาให้ Pop-up แสดงผล 2 วินาที แล้วเลื่อนออก
    Future.delayed(const Duration(seconds: 2), () {
      removeOverlay();
    });
  }

  void unlockNextLevel(String currentLevel) {
    setState(() {
      if (currentLevel == 'Motion') {
        isLevel2Unlocked = true;
        levels[1]['unlocked'] = true; // ปลดล็อค Level 2
      } else if (currentLevel == 'Level 2') {
        isLevel3Unlocked = true;
        levels[2]['unlocked'] = true; // ปลดล็อค Level 3
      } else if (currentLevel == 'Level 3') {
        isQuizUnlocked = true;
        levels[3]['unlocked'] = true; // ปลดล็อค Quiz
      }
    });
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

  String getYellowStarImageName(int stars) {
    return stars >= 0 && stars <= 5 ? stars.toString() : '0';
  }

  String getPurpleStarImageName(int stars) {
    return stars == 0 ? '0' : '1';
  }
}

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Image.asset(
        'assets/images/linegamelist/gridblue.png',
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
  late Animation<double> _rotationAnimation;
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

    // เพิ่มการหมุนแบบเร็วขึ้น
    int rotationSpeed = 8 + _random.nextInt(5); // หมุนใน 8 - 12 วินาทีต่อรอบ
    double rotationCurveEnd =
        (_controller.duration!.inSeconds / rotationSpeed.toDouble())
            .clamp(0.0, 1.0);

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, rotationCurveEnd, curve: Curves.linear),
      ),
    );

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
          child: Transform.rotate(
            angle: _rotationAnimation.value,
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
