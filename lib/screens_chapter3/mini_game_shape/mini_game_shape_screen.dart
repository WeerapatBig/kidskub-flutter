import 'package:firstly/screens_chapter3/mini_game_shape/model/shape_data.dart';
import 'package:flutter/material.dart';
import 'widgets/draggable_shape.dart';
import 'widgets/drop_target.dart';

class MiniGameShapeScreen extends StatefulWidget {
  const MiniGameShapeScreen({super.key});

  @override
  State<MiniGameShapeScreen> createState() => _MiniGameShapeScreenState();
}

class _MiniGameShapeScreenState extends State<MiniGameShapeScreen> {
  // ตำแหน่งของคาแรคเตอร์
  late double screenWidth;
  late double screenHeight;
  final double spacingRatio = 0.05; // สัดส่วนช่องว่างระหว่างรูปร่าง
  final double shapeSizeRatio = 1; // สัดส่วนของรูปร่างจากหน้าจอ
  List<ShapeData>? shapeList;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      screenWidth = size.width;
      screenHeight = size.height;

      final shapeSize = screenWidth * 0.135;

      setState(() {
        shapeList = [
          ShapeData(
            type: 'triangle',
            assetPath: 'assets/images/minigameShape/triangle.png',
            left: screenWidth * 0.09,
            bottom: screenHeight * 0.04,
            size: shapeSize,
          ),
          ShapeData(
            type: 'square',
            assetPath: 'assets/images/minigameShape/square.png',
            left: screenWidth * 0.35,
            bottom: screenHeight * 0.01,
            size: shapeSize,
          ),
          ShapeData(
            type: 'circle',
            assetPath: 'assets/images/minigameShape/circle.png',
            left: screenWidth * 0.65,
            bottom: screenHeight * 0.04,
            size: shapeSize,
          ),
        ];
      });
    });
  } // 👈 ปิด initState() ตรงนี้

  // เก็บสถานะว่ารูปร่างถูกใส่ในกล่องหรือยัง
  Map<String, bool> isShapePlaced = {
    'circle': false,
    'triangle': false,
    'square': false,
  };

  void onShapePlaced(String shapeType) {
    setState(() {
      isShapePlaced[shapeType] = true;
    });

    if (isShapePlaced.values.every((v) => v)) {
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pop(context, true); // ✅ กลับไปเลยโดยไม่โชว์ dialog
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    // ✅ ตรวจสอบว่า shapeList ถูกกำหนดค่าแล้วหรือยัง
    if (shapeList == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none, // 👈 อนุญาตให้ widget ล้นขอบ Stack
        children: [
          // พื้นหลังเกม
          Positioned.fill(
            child: Image.asset(
              'assets/images/minigameShape/miniGameShapebackground.png',
              fit: BoxFit.cover,
            ),
          ),

          // กล่องใส่รูปร่าง
          Positioned(
            top: screen.height * 0.02,
            child: Image.asset(
              'assets/images/minigameShape/shape_box.png',
              width: screen.width * 1,
            ),
          ),

          // คาแรคเตอร์
          Positioned(
            top: screen.height * 0.02,
            right: screen.width * 0.001,
            child: Image.asset(
              'assets/images/minigameShape/character.png',
              width: screen.width * 1,
            ),
          ),

          DropTargetArea(
            top: 0.26,
            left: 0.36,
            type: 'triangle',
            assetPath: 'assets/images/minigameShape/target_triangle.png',
            onShapePlaced: onShapePlaced,
            isPlaced: isShapePlaced['triangle']!,
          ),
          DropTargetArea(
            top: 0.24,
            left: 0.68,
            type: 'square',
            assetPath: 'assets/images/minigameShape/target_square.png',
            onShapePlaced: onShapePlaced,
            isPlaced: isShapePlaced['square']!,
          ),
          DropTargetArea(
            top: 0.22,
            left: 0.068,
            type: 'circle',
            assetPath: 'assets/images/minigameShape/target_circle.png',
            onShapePlaced: onShapePlaced,
            isPlaced: isShapePlaced['circle']!,
          ),

          ...shapeList!
              .where((shape) => !isShapePlaced[shape.type]!)
              .map((shape) => DraggableShape(
                    type: shape.type,
                    imagePath: shape.assetPath,
                    left: shape.left,
                    bottom: shape.bottom,
                    size: shape.size,
                  ))
              .toList(),
        ],
      ),
    );
  }
}
