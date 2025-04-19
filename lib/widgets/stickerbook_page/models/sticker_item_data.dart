// sticker_item_data.dart

class StickerItem {
  final String key;
  final String image;
  final String imageOutline;
  final double top;
  final double left;
  final double width;
  bool isCollected;

  StickerItem({
    required this.key,
    required this.image,
    required this.imageOutline,
    required this.top,
    required this.left,
    required this.width,
    this.isCollected = false,
  });
}

class StickerPageData {
  final String bookLeftImage;
  final String bookRightImage;
  final List<StickerItem> leftStickers;
  final List<StickerItem> rightStickers;

  StickerPageData({
    required this.bookLeftImage,
    required this.bookRightImage,
    required this.leftStickers,
    required this.rightStickers,
  });
}

final StickerPageData stickerChapterDot = StickerPageData(
  bookLeftImage: 'assets/images/strickerbook/book1_left.png',
  bookRightImage: 'assets/images/strickerbook/book1_right.png',
  leftStickers: [
    StickerItem(
      key: 'sticker1',
      image: 'assets/images/strickerbook/sticker1.png',
      imageOutline: 'assets/images/strickerbook/sticker1_outline.png',
      top: 0.15,
      left: 0.045,
      width: 0.1,
      isCollected: false, // ยังไม่เก็บ
    ),
    StickerItem(
      key: 'sticker2',
      image: 'assets/images/strickerbook/sticker2.png',
      imageOutline: 'assets/images/strickerbook/sticker2_outline.png',
      top: 0.15,
      left: 0.18,
      width: 0.1,
      isCollected: false, // ยังไม่เก็บ
    ),
    StickerItem(
      key: 'sticker3',
      image: 'assets/images/strickerbook/sticker3.png',
      imageOutline: 'assets/images/strickerbook/sticker3_outline.png',
      top: 0.37,
      left: 0.045,
      width: 0.1,
      isCollected: false, // ยังไม่เก็บ
    ),
    StickerItem(
      key: 'sticker4',
      image: 'assets/images/strickerbook/sticker4.png',
      imageOutline: 'assets/images/strickerbook/sticker4_outline.png',
      top: 0.37,
      left: 0.18,
      width: 0.1,
      isCollected: false, // ยังไม่เก็บ
    ),
  ],
  rightStickers: [
    StickerItem(
      key: 'sticker5',
      image: 'assets/images/strickerbook/sticker5.png',
      imageOutline: 'assets/images/strickerbook/sticker5_outline.png',
      top: 0.14,
      left: 0.04,
      width: 0.22,
      isCollected: false, // ยังไม่เก็บ
    ),
  ],
);

final StickerPageData stickerChapterLine = StickerPageData(
  bookLeftImage: 'assets/images/strickerbook/book2_left.png',
  bookRightImage: 'assets/images/strickerbook/book2_right.png',
  leftStickers: [
    StickerItem(
      key: 'stickerLine1',
      image: 'assets/images/strickerbook/line_sticker/stickerLine1.png',
      imageOutline:
          'assets/images/strickerbook/line_sticker/stickerLine1_outline.png',
      top: 0.15,
      left: 0.02,
      width: 0.125,
      isCollected: false, // ยังไม่เก็บ
    ),
    StickerItem(
      key: 'stickerLine2',
      image: 'assets/images/strickerbook/line_sticker/stickerLine2.png',
      imageOutline:
          'assets/images/strickerbook/line_sticker/stickerLine2_outline.png',
      top: 0.15,
      left: 0.15,
      width: 0.125,
      isCollected: false, // ยังไม่เก็บ
    ),
    StickerItem(
      key: 'stickerLine3',
      image: 'assets/images/strickerbook/line_sticker/stickerLine3.png',
      imageOutline:
          'assets/images/strickerbook/line_sticker/stickerLine3_outline.png',
      top: 0.37,
      left: 0.02,
      width: 0.125,
      isCollected: false, // ยังไม่เก็บ
    ),
    StickerItem(
      key: 'stickerLine4',
      image: 'assets/images/strickerbook/line_sticker/stickerLine4.png',
      imageOutline:
          'assets/images/strickerbook/line_sticker/stickerLine4_outline.png',
      top: 0.37,
      left: 0.15,
      width: 0.125,
      isCollected: false, // ยังไม่เก็บ
    ),
  ],
  rightStickers: [
    StickerItem(
      key: 'stickerLine5',
      image: 'assets/images/strickerbook/line_sticker/stickerLine5.png',
      imageOutline:
          'assets/images/strickerbook/line_sticker/stickerLine5_outline.png',
      top: 0.16,
      left: 0.04,
      width: 0.215,
      isCollected: false, // ยังไม่เก็บ
    ),
  ],
);

final StickerPageData stickerChapterShape = StickerPageData(
  bookLeftImage: 'assets/images/strickerbook/book3_left.png',
  bookRightImage: 'assets/images/strickerbook/book3_Right.png',
  leftStickers: [
    StickerItem(
      key: 'stickerShape1',
      image: 'assets/images/strickerbook/shape_sticker/stickerShape1.png',
      imageOutline:
          'assets/images/strickerbook/shape_sticker/stickerShape1_outline.png',
      top: 0.15,
      left: 0.035,
      width: 0.12,
      isCollected: false, // ยังไม่เก็บ
    ),
    StickerItem(
        key: 'stickerShape2',
        image: 'assets/images/strickerbook/shape_sticker/stickerShape2.png',
        imageOutline:
            'assets/images/strickerbook/shape_sticker/stickerShape2_outline.png',
        top: 0.15,
        left: 0.16,
        width: 0.12,
        isCollected: false // ยังไม่เก็บ
        ),
    StickerItem(
        key: 'stickerShape3',
        image: 'assets/images/strickerbook/shape_sticker/stickerShape3.png',
        imageOutline:
            'assets/images/strickerbook/shape_sticker/stickerShape3_outline.png',
        top: 0.37,
        left: 0.035,
        width: 0.12,
        isCollected: false // ยังไม่เก็บ
        ),
    StickerItem(
      key: 'stickerShape4',
      image: 'assets/images/strickerbook/shape_sticker/stickerShape4.png',
      imageOutline:
          'assets/images/strickerbook/shape_sticker/stickerShape4_outline.png',
      top: 0.37,
      left: 0.16,
      width: 0.12,
      isCollected: false, // ยังไม่เก็บ
    ),
  ],
  rightStickers: [
    StickerItem(
      key: 'stickerShape5',
      image: 'assets/images/strickerbook/shape_sticker/stickerShape5.png',
      imageOutline:
          'assets/images/strickerbook/shape_sticker/stickerShape5_outline.png',
      top: 0.14,
      left: 0.04,
      width: 0.215,
      isCollected: false, // ยังไม่เก็บ
    ),
  ],
);

final StickerPageData stickerChapterColor = StickerPageData(
  bookLeftImage: 'assets/images/strickerbook/book4_left.png',
  bookRightImage: 'assets/images/strickerbook/book4_right.png',
  leftStickers: [
    StickerItem(
      key: 'stickerColor1',
      image: 'assets/images/strickerbook/color_sticker/stickerColor1.png',
      imageOutline:
          'assets/images/strickerbook/color_sticker/stickerColor1_outline.png',
      top: 0.15,
      left: 0.035,
      width: 0.12,
      isCollected: false, // ยังไม่เก็บ
    ),
    StickerItem(
      key: 'stickerColor2',
      image: 'assets/images/strickerbook/color_sticker/stickerColor2.png',
      imageOutline:
          'assets/images/strickerbook/color_sticker/stickerColor2_outline.png',
      top: 0.15,
      left: 0.16,
      width: 0.12,
      isCollected: false, // ยังไม่เก็บ
    ),
    StickerItem(
      key: 'stickerColor3',
      image: 'assets/images/strickerbook/color_sticker/stickerColor3.png',
      imageOutline:
          'assets/images/strickerbook/color_sticker/stickerColor3_outline.png',
      top: 0.37,
      left: 0.035,
      width: 0.12,
      isCollected: false, // ยังไม่เก็บ
    ),
    StickerItem(
        key: 'stickerColor4',
        image: 'assets/images/strickerbook/color_sticker/stickerColor4.png',
        imageOutline:
            'assets/images/strickerbook/color_sticker/stickerColor4_outline.png',
        top: 0.37,
        left: 0.16,
        width: 0.12,
        isCollected: false // ยังไม่เก็บ
        ),
  ],
  rightStickers: [
    StickerItem(
        key: 'stickerColor5',
        image: 'assets/images/strickerbook/color_sticker/stickerColor5.png',
        imageOutline:
            'assets/images/strickerbook/color_sticker/stickerColor5_outline.png',
        top: 0.16,
        left: 0.04,
        width: 0.215,
        isCollected: false // ยังไม่เก็บ
        ),
  ],
);
