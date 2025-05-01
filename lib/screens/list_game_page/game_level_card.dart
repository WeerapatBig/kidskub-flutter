import 'dart:math';
import 'package:flutter/material.dart';
import '../shared_prefs_service.dart';
import 'data/game_list_data.dart';
import 'data/star_reward_data.dart';
import 'game_list_logic.dart';

class GameLevelCard extends StatelessWidget {
  final ListGameData levelData;
  final VoidCallback? onTap;

  const GameLevelCard({
    Key? key,
    required this.levelData,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double itemWidth = MediaQuery.of(context).size.width / 4.85;
    double itemHeight = MediaQuery.of(context).size.height * 0.67;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: itemWidth,
          height: itemHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Image.asset(
                levelData.isUnlocked
                    ? levelData.unlockedImagePath
                    : levelData.lockedImagePath,
                fit: BoxFit.contain,
              ),
              if (levelData.isUnlocked)
                Positioned(
                  bottom: screenHeight * -0.05,
                  right: screenWidth * 0,
                  child: _buildLevelStars(levelData, itemWidth),
                ),
              if (levelData.isUnlocked)
                Positioned(
                  top: screenHeight * -0.05,
                  right: screenWidth * -0.01,
                  child: _buildLevelBadge(
                      levelData.title, screenHeight, screenWidth),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelStars(ListGameData level, double itemWidth) {
    int earnedStars = level.earnedStars;
    String starColor = level.starColor;
    double starSize = itemWidth * 0.8;
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

    return Image.asset(
      starAsset,
      width: starSize + 50,
      height: starSize,
      fit: BoxFit.fitHeight,
    );
  }

  Widget _buildLevelBadge(
      String title, double screenWidth, double screenHeight) {
    String badgeAsset = '';
    double badgeWidth = screenWidth * 0.225;
    double badgeHeight = screenHeight * 0.21;

    if (title == 'Dot Easy' ||
        title == 'Line Easy' ||
        title == 'Shape Easy' ||
        title == 'Color Easy') {
      badgeAsset = 'assets/images/dotchapter/card1_level.png';
    } else if (title == 'Dot Hard' ||
        title == 'Line Hard' ||
        title == 'Shape Hard' ||
        title == 'Color Hard') {
      badgeAsset = 'assets/images/dotchapter/card2_level.png';
    } else if (title == 'Dot Quiz' ||
        title == 'Line Quiz' ||
        title == 'Shape Quiz' ||
        title == 'Color Quiz') {
      badgeAsset = 'assets/images/dotchapter/card3_level.png';
      badgeWidth = screenWidth * 0.285; // กำหนดขนาดเฉพาะสำหรับ Quiz
      badgeHeight = screenHeight * 0.23;
    } else {
      return const SizedBox();
    }

    return Image.asset(
      badgeAsset,
      width: badgeWidth,
      height: badgeHeight,
      fit: BoxFit.contain,
    );
  }
}

class AccumulatedStarsWidget extends StatefulWidget {
  final List<String> levels;
  final SharedPrefsService prefsService;
  final List<StarRewardData> rewardList;
  final String chapterId; // 🔸 เพิ่มตรงนี้

  const AccumulatedStarsWidget({
    Key? key,
    required this.levels,
    required this.prefsService,
    required this.rewardList,
    required this.chapterId, // 🔸 รับตรงนี้ด้วย
  }) : super(key: key);

  @override
  State<AccumulatedStarsWidget> createState() => _AccumulatedStarsWidgetState();
}

class _AccumulatedStarsWidgetState extends State<AccumulatedStarsWidget>
    with TickerProviderStateMixin {
  // AnimationController สำหรับ sequence scale
  late AnimationController _sequenceController;
  // Animation ที่เก็บค่าจาก 1.0 -> 0.2 -> 1.3 -> 1.0 -> 1.1
  late Animation<double> _scaleSequence;
  late Animation<double> _rotateSequence;

  bool canTapPurple = false;
  bool canTapYellow = false;

  @override
  void initState() {
    super.initState();
    // 1) สร้าง AnimationController มี duration = 0.24 วินาที
    //    (4 ช่วง × 0.06s)
    _sequenceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();

    // 2) สร้าง TweenSequence ให้เอฟเฟกต์ scale 4 ช่วง
    //    1) 1.0 -> 0.2
    //    2) 0.2 -> 1.3
    //    3) 1.3 -> 1.0
    //    4) 1.0 -> 1.1
    // each "weight" = 1.0 => 4 ช่วงเท่ากัน
    _scaleSequence = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.2),
        weight: 15.0,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.2),
        weight: 35.0,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0),
        weight: 20.0,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 30.0,
      ),
    ]).animate(_sequenceController);

    _rotateSequence = TweenSequence<double>([
      // ช่วงแรก 0..0.24 => 0 rad
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0.0), // ไม่หมุน
        weight: 15.0, // คิดเป็นสัดส่วน
      ),
      // ช่วงต่อไป 0.24..0.5 =>  -0.1 rad
      TweenSequenceItem<double>(
        tween: Tween(begin: 0.0, end: 0.08),
        weight: 10.0,
      ),
      // 0.5..0.76 => +0.1 rad
      TweenSequenceItem<double>(
        tween: Tween(begin: 0.08, end: -0.08),
        weight: 10.0,
      ),
      // 0.76..1.0 => 0 rad
      TweenSequenceItem<double>(
        tween: Tween(begin: -0.08, end: 0.0),
        weight: 15.0,
      ),
      // 50..100 => 0 rad
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0.0),
        weight: 50.0,
      ),
    ]).animate(_sequenceController);

    // ถ้าต้องการ loop: ใส่ Listener เช็ก status แล้ว repeat
    // _sequenceController.addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     _sequenceController.reverse();
    //   } else if (status == AnimationStatus.dismissed) {
    //     _sequenceController.forward();
    //   }
    // });
  }

  Future<void> _checkRewardStatus(int purple, int yellow) async {
    final claimedPurple = await widget.prefsService
        .isStarRewardClaimed('${widget.chapterId}_purple');
    final claimedYellow = await widget.prefsService
        .isStarRewardClaimed('${widget.chapterId}_yellow');

    setState(() {
      canTapPurple = purple >= 1 && !claimedPurple;
      canTapYellow = yellow >= 5 && !claimedYellow;
    });
  }

  @override
  void dispose() {
    _sequenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: widget.prefsService.calculateTotalStars(widget.levels),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final yellowStars = snapshot.data!['yellow']!;
        final purpleStars = snapshot.data!['purple']!;

        // บังคับดาวสีเหลืองไม่เกิน 5
        final displayYellowStars = min(yellowStars, 5);

        // เช็ค reward status
        _checkRewardStatus(purpleStars, yellowStars);

        // ถ้า canTap ใดๆ => เล่นอนิเมชัน (forward)
        // ถ้าไม่ => reset ไว้ scale = 1.0
        if (canTapPurple || canTapYellow) {
          if (_sequenceController.isDismissed) {
            // เริ่มเล่น
            _sequenceController.repeat();
          }
        } else {
          // ไม่มี canTap => reset
          if (_sequenceController.isAnimating) {
            _sequenceController.reset(); // ค่า scale จะกลับเป็นช่วงเริ่ม (1.0)
            _sequenceController.stop();
          }
        }

        return Positioned(
          bottom: MediaQuery.of(context).size.height * 0.01,
          right: MediaQuery.of(context).size.width * 0.055,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // -----------------------------
              // กลุ่มดาวม่วง
              // -----------------------------
              Row(
                children: [
                  // ใช้ AnimatedBuilder เพื่อดึงค่า scale จาก _scaleSequence
                  AnimatedBuilder(
                    animation: _sequenceController,
                    builder: (context, child) {
                      // ถ้า canTapPurple => ใช้ค่าอนิเมชัน
                      // ถ้าไม่ => 1.0, 0 rad
                      final scaleValue =
                          canTapPurple ? _scaleSequence.value : 1.0;
                      final rotateValue =
                          canTapPurple ? _rotateSequence.value : 0.0;

                      return GestureDetector(
                        onTap: canTapPurple
                            ? () async {
                                // เรียก onPurpleStarTap
                                await onPurpleStarTap(
                                  context: context,
                                  purpleStars: purpleStars,
                                  rewardList: widget.rewardList,
                                  starColor: 'purple',
                                );
                                await widget.prefsService.saveStarRewardClaimed(
                                    '${widget.chapterId}_purple');
                                // หลัง popup
                                setState(() {
                                  _sequenceController.reset();
                                  _sequenceController.stop();
                                  canTapPurple = false;
                                });
                              }
                            : null,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..scale(scaleValue)
                            ..rotateZ(rotateValue),
                          child: Container(
                            // ใส่ Glow ถ้าต้องการ
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: canTapPurple
                                  ? [
                                      BoxShadow(
                                        color: const Color.fromARGB(
                                                255, 203, 81, 255)
                                            .withOpacity(0.8),
                                        blurRadius: 30,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 0),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Image.asset(
                              'assets/images/game_list/star_purple_reward.png',
                              width: MediaQuery.of(context).size.width *
                                  0.11 *
                                  0.8,
                              height: MediaQuery.of(context).size.height *
                                  0.25 *
                                  0.8,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  Image.asset(
                    'assets/images/game_list/total_purple_$purpleStars.png',
                    width: MediaQuery.of(context).size.width * 0.142 * 0.8,
                    height: MediaQuery.of(context).size.height * 0.22 * 0.8,
                    fit: BoxFit.fitHeight,
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // -----------------------------
              // กลุ่มดาวเหลือง
              // -----------------------------
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _sequenceController,
                    builder: (context, child) {
                      final scaleValue =
                          canTapYellow ? _scaleSequence.value : 1.0;
                      final rotateValue =
                          canTapYellow ? _rotateSequence.value : 0.0;

                      return GestureDetector(
                        onTap: (canTapYellow)
                            ? () async {
                                await onYellowStarTap(
                                  context: context,
                                  yellowStars: yellowStars,
                                  rewardList: widget.rewardList,
                                  starColor: 'yellow',
                                );
                                await widget.prefsService.saveStarRewardClaimed(
                                    '${widget.chapterId}_yellow');
                                setState(() {
                                  _sequenceController.reset();
                                  _sequenceController.stop();
                                  canTapYellow = false;
                                });
                              }
                            : null,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..scale(scaleValue)
                            ..rotateZ(rotateValue),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: canTapYellow
                                  ? [
                                      BoxShadow(
                                        color: Colors.yellow.withOpacity(0.7),
                                        blurRadius: 15,
                                        spreadRadius: 3,
                                        offset: const Offset(0, 0),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Image.asset(
                              'assets/images/game_list/star_yellow_reward.png',
                              width: MediaQuery.of(context).size.width * 0.11,
                              height: MediaQuery.of(context).size.height * 0.25,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Image.asset(
                    'assets/images/game_list/total_yellow_$displayYellowStars.png',
                    width: MediaQuery.of(context).size.width * 0.142,
                    height: MediaQuery.of(context).size.height * 0.22,
                    fit: BoxFit.fitHeight,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
