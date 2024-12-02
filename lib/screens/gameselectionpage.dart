import 'dart:ui';
import 'package:firstly/screens/colorgamelist.dart';
import 'package:firstly/screens/dotgamelist.dart';
import 'package:firstly/screens/homepage.dart';
import 'package:firstly/screens/linegamelist.dart';
import 'package:firstly/screens/shapegamelist.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'shared_prefs_service.dart';
// import 'chapter.dart';

class GameSelectionPage extends StatefulWidget {
  const GameSelectionPage({Key? key}) : super(key: key);

  @override
  _GameSelectionPageState createState() => _GameSelectionPageState();
}

class _GameSelectionPageState extends State<GameSelectionPage>
    with TickerProviderStateMixin {
  // ตัวแปรสถานะของกุญแจที่ผู้เล่นมีสำหรับแต่ละด่าน
  bool hasKey1 = true; //ลบ
  bool hasKey2 = false;
  bool hasKey3 = false;
  bool hasKey4 = false;

  bool isShowingPopup = false;

  late Size screenSize;

  // จำนวนดาวทั้งหมดที่สะสมได้จากทุก Chapter
  int totalStars = 0;

  // รายการสถานะการปลดล็อกของแต่ละด่าน
  late List<bool> levelUnlocked; //ลบ

  // รายการภาพของเกมสำหรับแต่ละด่าน
  final List<String> gameImages = [
    'assets/images/selectionpage/dotgame.png',
    'assets/images/selectionpage/linegame.png',
    'assets/images/selectionpage/shapegame.png',
    'assets/images/selectionpage/colorgame.png',
  ];
  final List<String> gameImagesLock = [
    'assets/images/selectionpage/dotgame_lock.png',
    'assets/images/selectionpage/linegame_lock.png',
    'assets/images/selectionpage/shapegame_lock.png',
    'assets/images/selectionpage/colorgame_lock.png',
  ];

  // รายการภาพตัวเรือนกุญแจ (Body) สำหรับแต่ละด่าน
  final List<String> lockBodyImages = [
    'assets/images/selectionpage/dot_lock1.png', // ด่านที่ 1 - สีฟ้า
    'assets/images/selectionpage/line_lock1.png', // ด่านที่ 2 - สีเขียว
    'assets/images/selectionpage/shape_lock1.png', // ด่านที่ 3 - สีแดง
    'assets/images/selectionpage/color_lock1.png', // ด่านที่ 4 - สีเหลือง
  ];

  // รายการภาพงวงกุญแจ (Shackle) สำหรับแต่ละด่าน
  final List<String> lockShackleImages = [
    'assets/images/selectionpage/dot_lock2.png', // ด่านที่ 1 - สีฟ้า
    'assets/images/selectionpage/line_lock2.png', // ด่านที่ 2 - สีเขียว
    'assets/images/selectionpage/shape_lock2.png', // ด่านที่ 3 - สีแดง
    'assets/images/selectionpage/color_lock2.png', // ด่านที่ 4 - สีเหลือง
  ];

  // รายการ AnimationController สำหรับอนิเมชันการสั่นและการปลดล็อกของแต่ละด่าน
  late List<AnimationController> lockShakeControllers;
  late List<AnimationController> lockUnlockControllers;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.of(context).size;
  }

  @override
  void initState() {
    super.initState();
    //_clearKeyStatus();
    // จากนั้นบันทึกข้อมูลใหม่
    _loadKeyStatus(); // โหลดสถานะกุญแจ

    // กำหนดสถานะการปลดล็อกของแต่ละด่าน
    levelUnlocked = [true, false, false, false];

    // สร้าง AnimationController สำหรับแต่ละด่าน
    lockShakeControllers = List.generate(gameImages.length, (index) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );
      // รีเซ็ตอนิเมชันเมื่อเล่นจบ
      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reset();
        }
      });
      return controller;
    });

    lockUnlockControllers = List.generate(gameImages.length, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );
    });
  }

  // ฟังก์ชันโหลดสถานะของกุญแจจาก SharedPreferences
  void _loadKeyStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? loadedKey2 = prefs.getBool('hasKey2');
    setState(() {
      hasKey2 = loadedKey2 ?? false; // อัปเดต UI
      print('Loaded hasKey2: $hasKey2'); // เพิ่มการดีบัค
    }); // อัปเดต UI
  }

  void _clearKeyStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('hasKey2'); // ลบข้อมูล hasKey2 ออกจาก SharedPreferences
    print('Cleared hasKey2'); // เพิ่มการดีบัค
  }

  // ฟังก์ชันบันทึกสถานะกุญแจใน SharedPreferences
  void _saveKeyStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool result = await prefs.setBool('hasKey2', status);
    print(
        'Saved hasKey2: $status, Success: $result'); // ตรวจสอบว่าการบันทึกทำงาน
  }

  @override
  void dispose() {
    // ปิด AnimationController เมื่อไม่ใช้งาน
    for (var controller in lockShakeControllers) {
      controller.dispose();
    }
    for (var controller in lockUnlockControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        // วางวิดเจ็ตต่าง ๆ ซ้อนกัน
        children: [
          // ภาพพื้นหลังโปร่งแสง
          const HomePage(
            showFooter: false,
            showMiddle: true,
            showHeader: true,
            showButton: false,
          ),
          BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
              child: Container(
                color: Colors.white.withOpacity(0.2),
              )),
          // เนื้อหาหลัก: PageView.builder
          PageView.builder(
            controller: PageController(viewportFraction: 0.58),
            itemCount: gameImages.length,
            itemBuilder: (context, index) {
              return buildLevelCard(index);
            },
            onPageChanged: (index) {
              // หากคุณต้องการจัดการสถานะการเปลี่ยนแปลงเพจ ให้ตรวจสอบว่าไม่เปลี่ยนสถานะที่เกี่ยวข้องกับ UI ที่กำลังถูกวาด
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  // ปรับสถานะที่ต้องการหลังจากหน้าต่าง UI วาดเสร็จ
                });
              });
            },
          ),
          // วิดเจ็ตสำหรับกุญแจทางด้านขวา
          buildKeyBar(),
          // ปุ่มลอยสำหรับย้อนกลับ
          buildBackButton(),
        ],
      ),
    );
  }

  // ฟังก์ชันสำหรับสร้างวิดเจ็ตของแต่ละด่าน
  Widget buildLevelCard(int index) {
    // AnimationController สำหรับอนิเมชันของด่านนี้
    final shakeController = lockShakeControllers[index];
    final unlockController = lockUnlockControllers[index];

    return StatefulBuilder(builder: (context, localSetState) {
      return GestureDetector(
        onTap: () {
          if (levelUnlocked[index]) {
            // ด่านถูกปลดล็อกแล้ว นำทางไปยังหน้าด่านเกมของคุณ
            navigateToLevelPage(index);
          } else {
            // ด่านยังไม่ถูกปลดล็อก
            if ((index == 0 && hasKey1) ||
                (index == 1 && hasKey2) ||
                (index == 2 && hasKey3) ||
                (index == 3 && hasKey4)) {
              // ผู้เล่นมีกุญแจสำหรับด่านนี้ เริ่มอนิเมชันปลดล็อก
              unlockController.forward().then((_) {
                // เมื่ออนิเมชันจบ ปลดล็อกด่านและนำกุญแจออก
                setState(() {
                  levelUnlocked[index] = true;
                });
              });
            } else {
              // ผู้เล่นไม่มีกุญแจ เริ่มอนิเมชันการสั่นและแสดงข้อความเตือน
              shakeController.forward(from: 0);
              showNoKeyWarning();
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 80, 10, 20),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 0.5),
            width: 100, // กำหนดความกว้างของวิดเจ็ต
            height: 300, // กำหนดความสูงของวิดเจ็ต
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ภาพเกม พร้อมกับปรับสีเมื่อด่านยังไม่ถูกปลดล็อก
                if (index == 0)
                  Image.asset(
                    'assets/images/selectionpage/dotgame.png',
                    fit: BoxFit.fitHeight,
                    width: double.infinity,
                    height: double.infinity,
                  )
                else
                  Image.asset(
                    levelUnlocked[index]
                        ? gameImages[index] // ถ้าปลดล็อคแล้วให้แสดงรูปภาพด่าน
                        : gameImagesLock[
                            index], // ถ้ายังไม่ปลดล็อคให้แสดงรูปภาพที่ถูกล็อค
                    fit: BoxFit.fitHeight,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                // ถ้าด่านยังไม่ถูกปลดล็อก แสดงแม่กุญแจพร้อมอนิเมชัน
                if (index != 0 && !levelUnlocked[index])
                  buildLockAnimation(index, shakeController, unlockController),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget buildLockAnimation(int index, AnimationController shakeController,
      AnimationController unlockController) {
    final shackleSlideAnimation =
        Tween<double>(begin: 0.0, end: -120.0).animate(
      CurvedAnimation(parent: unlockController, curve: Curves.easeOut),
    );
    final shackleFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: unlockController, curve: Curves.easeOut),
    );

    // อนิเมชันการสั่นของกุญแจเมื่อผู้เล่นไม่มีกุญแจ
    final shakeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(shakeController);

    return AnimatedBuilder(
      animation: Listenable.merge([shakeController, unlockController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(shakeAnimation.value, 0),
          child: Container(
            width: screenSize.width * 0.15,
            height: screenSize.height * 0.3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // งวงกุญแจ (Shackle) ของด่านนี้ พร้อมอนิเมชัน
                Positioned(
                  top: screenSize.height * 0.03,
                  child: Opacity(
                    opacity: shackleFadeAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, shackleSlideAnimation.value - 20),
                      child: Image.asset(
                        lockShackleImages[index],
                        width: screenSize.width * 0.15,
                        height: screenSize.height * 0.178,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                // ตัวเรือนกุญแจ (Body) ของด่านนี้
                Image.asset(
                  lockBodyImages[index],
                  width: screenSize.width * 0.15,
                  height: screenSize.height * 0.15,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ฟังก์ชันสำหรับนำทางไปยังหน้าของแต่ละด่าน
  void navigateToLevelPage(int index) async {
    switch (index) {
      case 0:
        final result = await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                const DotGameList(), // เปลี่ยนไปยังหน้าใหม่
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, -1.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 1000),
          ),
        );

        // ตรวจสอบว่าผลลัพธ์ไม่เป็น null และมีค่าดาวที่ถูกส่งกลับมา
        if (result != null && result is Map<String, dynamic>) {
          print('Received result: $result'); // ตรวจสอบค่าที่ได้รับกลับมา
          setState(() {
            if (result['hasKey2'] == true) {
              hasKey2 = true; // ปลดล็อค Chapter ถัดไป
              _saveKeyStatus(hasKey2); // บันทึกสถานะกุญแจ
              print('Chapter 2 unlocked!');
            }
          });
        }
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LineGameList(),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShapeGameList(),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ColorGameList(),
          ),
        );
        break;
      default:
        // ถ้า index ไม่ตรงกับกรณีใด ๆ
        break;
    }
  }

  // ฟังก์ชันสำหรับแสดง Pop-up ข้อความเมื่อผู้เล่นไม่มีกุญแจ
  void showNoKeyWarning() {
    // ถ้ากำลังแสดง popup อยู่ ไม่ต้องแสดงซ้ำ
    if (isShowingPopup) return;

    // ตั้งค่าสถานะให้กำลังแสดง popup
    isShowingPopup = true;

    // สร้าง AnimationController สำหรับอนิเมชันการเลื่อนเข้าและออก
    final animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // สร้าง OverlayEntry
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) {
        // สร้างอนิเมชันการเลื่อน
        final slideAnimation = Tween<Offset>(
          begin: Offset(0.0, -1.0), // เริ่มจากนอกหน้าจอด้านขวา
          end: Offset(0.0, 0.0), // เลื่อนเข้ามาในหน้าจอ
        ).animate(CurvedAnimation(
          parent: animationController,
          curve: Curves.easeOut,
        ));

        return Positioned(
          top: screenSize.height * 0, // ปรับตำแหน่งแนวตั้งตามต้องการ
          right: screenSize.width * 0.35, // ติดกับขอบขวาของหน้าจอ
          child: SlideTransition(
            position: slideAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: screenSize.width * 0.3,
                height: screenSize.height * 0.2,
                child: Image.asset(
                  'assets/images/selectionpage/key_notification.png',
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
      animationController.reverse().then((_) {
        overlayEntry.remove();
        isShowingPopup = false;
      });
    });
  }

  // ฟังก์ชันสำหรับสร้างวิดเจ็ตกุญแจทางด้านขวา
  Widget buildKeyBar() {
    return Stack(
      children: [
        // ภาพพื้นหลังของแถบกุญแจ
        Positioned(
          left: MediaQuery.of(context).size.width * 0.065,
          top: MediaQuery.of(context).size.height * -0.001,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.09,
            height: MediaQuery.of(context).size.height * 1,
            child: Image.asset(
              'assets/images/selectionpage/key_bar.png',
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
        // แสดงกุญแจที่ผู้เล่นมี
        Positioned(
          left: MediaQuery.of(context).size.width * 0.06,
          top: MediaQuery.of(context).size.height * 0.275,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // กุญแจที่ 1
              buildKeyImage(hasKey1, 'key1.png', 'key1_gray.png'),
              const SizedBox(height: 35),
              // กุญแจที่ 2
              buildKeyImage(hasKey2, 'key2.png', 'key2_gray.png'),
              const SizedBox(height: 35),
              // กุญแจที่ 3
              buildKeyImage(hasKey3, 'key3.png', 'key3_gray.png'),
              const SizedBox(height: 35),
              // กุญแจที่ 4
              buildKeyImage(hasKey4, 'key4.png', 'key4_gray.png'),
            ],
          ),
        ),
      ],
    );
  }

  // ฟังก์ชันสำหรับสร้างภาพกุญแจ
  Widget buildKeyImage(bool hasKey, String imagePath, String grayImagePath) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.1,
      height: MediaQuery.of(context).size.height * 0.08,
      child: Image.asset(
        hasKey
            ? 'assets/images/selectionpage/$imagePath'
            : 'assets/images/selectionpage/$grayImagePath',
        fit: BoxFit.fitHeight,
      ),
    );
  }

  // ฟังก์ชันสำหรับสร้างปุ่มย้อนกลับ
  Widget buildBackButton() {
    return Positioned(
      width: screenSize.width * 0.045,
      height: screenSize.height * 0.085,
      left: screenSize.width * 0.028,
      top: screenSize.height * 0.028,
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
        hoverColor: Colors.transparent,
        hoverElevation: 0,
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: screenSize.width * 0.05,
          color: Color.fromARGB(255, 21, 21, 21),
        ),
      ),
    );
  }
}
