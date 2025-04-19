import 'package:firstly/widgets/stickerbook_page/models/sticker_item_data.dart';
import 'package:flutter/material.dart';
import 'positioned_sticker.dart';

class BookSideWidget extends StatelessWidget {
  final String bookImage;
  final List<StickerItem> stickers;

  const BookSideWidget({
    Key? key,
    required this.bookImage,
    required this.stickers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(bookImage), //เพิ่มการแสดงภาพพื้นหลังของหนังสือ
          fit: BoxFit.contain,
        ),
      ),
      child: Stack(
        children: stickers
            .map((sticker) => PositionedSticker(sticker: sticker))
            .toList(),
      ),
    );
  }
}
