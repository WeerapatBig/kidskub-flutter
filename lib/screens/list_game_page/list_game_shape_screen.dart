// lib\screens\list_game_page\list_game_shape_screen.dart
// lib\screens\list_game_page\list_game_line_screen.dart
import 'package:firstly/screens/list_game_page/data/star_reward_data.dart';
import 'package:firstly/screens/list_game_page/game_list_logic.dart';
import 'package:firstly/screens/list_game_page/model/character_animation_model.dart';
import 'package:firstly/screens/list_game_page/model/custom_backbutton.dart';
import 'package:firstly/screens/list_game_page/model/floating_element.dart';
import 'package:flutter/material.dart';

import '../shared_prefs_service.dart';
import 'data/game_list_data.dart';
import 'game_level_card.dart';

class ListGameLineScreen extends StatefulWidget {
  const ListGameLineScreen({super.key});

  @override
  State<ListGameLineScreen> createState() => _ListGameLineScreenState();
}

class _ListGameLineScreenState extends State<ListGameLineScreen>
    with TickerProviderStateMixin {
  final SharedPrefsService prefsService = SharedPrefsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/shapegame/grid_green.png',
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
                children: shapeGameLevels.map((level) {
                  return GameLevelCard(
                    levelData: level,
                    onTap: () async {
                      // เรียก onLevelTap แบบ await
                      await onLevelTap(context, level, this);
                      // จากนั้นรีโหลดข้อมูลทุกด่านใน dotGameLevels
                      await _refreshLineGameLevels();
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
            levels: lineGameLevels.map((e) => e.title).toList(),
            prefsService: SharedPrefsService(),
            rewardList: starRewardsForLine,
          ),
          const CharacterAnimation(
            imagePath: 'assets/images/shapegame/charactor_shape.png',
          ),
        ],
      ),
    );
  }

  /// โหลดข้อมูล SharedPref มายัดกลับเข้า dotGameLevels
  Future<void> _refreshLineGameLevels() async {
    for (var item in shapeGameLevels) {
      final loadedData = await prefsService.loadLevelData(item.title);
      item.isUnlocked = loadedData['unlocked'];
      item.earnedStars = loadedData['earnedStars'];
      if (loadedData['starColor'] != null &&
          loadedData['starColor'].isNotEmpty) {
        item.starColor = loadedData['starColor'];
      }
    }
  }

  List<Widget> buildFloatingImages(BuildContext context) {
    double floatingImageSize = MediaQuery.of(context).size.width * 0.25;

    // List ของรูปภาพที่ต้องการใช้
    List<String> imagePaths = [
      'assets/images/shapegame/elm_1.png',
      'assets/images/shapegame/elm_2.png',
      'assets/images/shapegame/elm_3.png',
      'assets/images/shapegame/elm_4.png',
    ];

    return List.generate(4, (index) {
      return FloatingImage(
        imagePath: imagePaths[index],
        width: floatingImageSize,
        height: floatingImageSize,
      );
    });
  }
}
