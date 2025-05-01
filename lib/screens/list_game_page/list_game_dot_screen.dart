// lib\screens\list_game_page\list_game_dot_screen.dart
import 'package:firstly/screens/list_game_page/model/character_animation_model.dart';
import 'package:flutter/material.dart';
import '../shared_prefs_service.dart';
import 'data/game_list_data.dart';
import 'data/star_reward_data.dart';
import 'game_level_card.dart';
import 'game_list_logic.dart';
import 'model/custom_backbutton.dart';
import 'model/floating_element.dart';

class ListGameDotScreen extends StatefulWidget {
  const ListGameDotScreen({super.key});

  @override
  State<ListGameDotScreen> createState() => _ListGameDotScreenState();
}

class _ListGameDotScreenState extends State<ListGameDotScreen>
    with TickerProviderStateMixin {
  final SharedPrefsService prefsService = SharedPrefsService();
  @override
  void initState() {
    super.initState();
    _refreshDotGameLevels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/dotchapter/bg.png',
              fit: BoxFit.cover,
            ),
          ),
          ...buildFloatingImages(context),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 65),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: dotGameLevels.map((level) {
                  return GameLevelCard(
                    levelData: level,
                    onTap: () async {
                      // เรียก onLevelTap แบบ await
                      await onLevelTap(context, level, this);
                      // จากนั้นรีโหลดข้อมูลทุกด่านใน dotGameLevels
                      await _refreshDotGameLevels();
                      // เมื่อกลับมาแล้ว ให้รีเฟรชหน้า
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          CustomBackButton(
            onTap: () => navigateToGameSelectionPage(context),
          ),
          AccumulatedStarsWidget(
            levels: dotGameLevels.map((e) => e.title).toList(),
            prefsService: SharedPrefsService(),
            rewardList: starRewardsForDot,
            chapterId: 'dot',
          ),
          const CharacterAnimation(
            imagePath: 'assets/images/dotchapter/chractor1.png',
          ),
        ],
      ),
    );
  }

  /// โหลดข้อมูล SharedPref มายัดกลับเข้า dotGameLevels
  Future<void> _refreshDotGameLevels() async {
    for (var item in dotGameLevels) {
      final loadedData = await prefsService.loadLevelData(item.title);
      item.isUnlocked = loadedData['unlocked'];
      item.earnedStars = loadedData['earnedStars'];
      if (loadedData['starColor'] != null &&
          loadedData['starColor'].isNotEmpty) {
        item.starColor = loadedData['starColor'];
      }
    }
    setState(() {}); // รีเฟรช UI
  }

  List<Widget> buildFloatingImages(BuildContext context) {
    double floatingImageSize = MediaQuery.of(context).size.width * 0.15;
    return List.generate(4, (index) {
      return FloatingImage(
        imagePath: 'assets/images/dotchapter/elm.png',
        width: floatingImageSize,
        height: floatingImageSize,
      );
    });
  }
}
