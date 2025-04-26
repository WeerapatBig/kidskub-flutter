// lib\screens\list_game_page\list_game_color_screen.dart
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

class ListGameColorScreen extends StatefulWidget {
  const ListGameColorScreen({super.key});

  @override
  State<ListGameColorScreen> createState() => _ListGameColorScreenState();
}

class _ListGameColorScreenState extends State<ListGameColorScreen>
    with TickerProviderStateMixin {
  final SharedPrefsService prefsService = SharedPrefsService();
  @override
  void initState() {
    super.initState();
    _refreshColorGameLevels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/colorgame/grid_bg_color.png',
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
                children: colorGameLevels.map((level) {
                  return GameLevelCard(
                    levelData: level,
                    onTap: () async {
                      // เรียก onLevelTap แบบ await
                      await onLevelTap(context, level, this);
                      // จากนั้นรีโหลดข้อมูลทุกด่านใน dotGameLevels
                      await _refreshColorGameLevels();
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
            levels: colorGameLevels.map((e) => e.title).toList(),
            prefsService: SharedPrefsService(),
            rewardList: starRewardsForColor,
            chapterId: 'color',
          ),
          const CharacterAnimation(
            imagePath:
                'assets/images/colorgame/quiz_color/dialog/character_red.png',
          ),
        ],
      ),
    );
  }

  /// โหลดข้อมูล SharedPref มายัดกลับเข้า dotGameLevels
  Future<void> _refreshColorGameLevels() async {
    for (var item in colorGameLevels) {
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
    double floatingImageSize =
        MediaQuery.of(context).size.width * 0.25.toDouble();

    // List ของรูปภาพที่ต้องการใช้
    List<String> imagePaths = [
      'assets/images/colorgame/quiz_color/elm_blue.png',
      'assets/images/colorgame/quiz_color/elm_green.png',
      'assets/images/colorgame/quiz_color/elm_red.png',
      'assets/images/colorgame/quiz_color/elm_yellow.png',
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
