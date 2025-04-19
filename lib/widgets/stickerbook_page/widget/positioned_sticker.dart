import 'package:firstly/widgets/stickerbook_page/models/sticker_item_data.dart';
import 'package:flutter/material.dart';

class PositionedSticker extends StatelessWidget {
  final StickerItem sticker;

  const PositionedSticker({
    Key? key,
    required this.sticker,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double outlineSize = screenWidth * sticker.width;
    final double stickerSize = outlineSize * 1.25;

    return Positioned(
      top: screenHeight * sticker.top,
      left: screenWidth * sticker.left,
      child: SizedBox(
        width: stickerSize,
        height: stickerSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outline
            Positioned(
              top: (stickerSize - outlineSize) / 2,
              left: (stickerSize - outlineSize) / 2,
              child: Image.asset(
                sticker.imageOutline,
                width: outlineSize,
                height: outlineSize,
                fit: BoxFit.contain,
              ),
            ),

            // Sticker
            if (sticker.isCollected)
              Image.asset(
                sticker.image,
                width: stickerSize,
                height: stickerSize,
                fit: BoxFit.contain,
              ),
          ],
        ),
      ),
    );
  }
}
