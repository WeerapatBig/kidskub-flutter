import 'package:firstly/function/mediaquery_values.dart';
import 'package:firstly/widgets/stickerbook_page/widget/back_button.dart';
import 'package:firstly/widgets/stickerbook_page/widget/background_widget.dart';
import 'package:firstly/widgets/stickerbook_page/widget/book_side_widget.dart';
import 'package:firstly/widgets/stickerbook_page/widget/screwwidget.dart';
import 'package:firstly/widgets/stickerbook_page/widget/title_widget.dart';
import 'package:flutter/material.dart';

import '../../screens/list_game_page/model/floating_element.dart';
import 'models/sticker_item_data.dart';
import 'services/sticker_prefs_service.dart';

class StickerBookPage extends StatefulWidget {
  const StickerBookPage({Key? key}) : super(key: key);

  @override
  State<StickerBookPage> createState() => _StickerBookPageState();
}

class _StickerBookPageState extends State<StickerBookPage> {
  final PageController _pageController = PageController();
  final List<String> _chapters = ['dot', 'line', 'shape', 'color'];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    updateStickerCollectionStatus().then((_) {
      setState(() {});
    });
  }

  Future<void> updateStickerCollectionStatus() async {
    List<StickerItem> allStickers = [
      ...stickerChapterDot.leftStickers,
      ...stickerChapterDot.rightStickers,
      ...stickerChapterLine.leftStickers,
      ...stickerChapterLine.rightStickers,
      ...stickerChapterShape.leftStickers,
      ...stickerChapterShape.rightStickers,
      ...stickerChapterColor.leftStickers,
      ...stickerChapterColor.rightStickers,
    ];

    for (var sticker in allStickers) {
      bool collected =
          await StickerBookPrefsService.getIsCollected(sticker.key);
      sticker.isCollected = collected;
    }
  }

  StickerPageData _getPageData(String chapter) {
    switch (chapter) {
      case 'dot':
        return stickerChapterDot;
      case 'line':
        return stickerChapterLine;
      case 'shape':
        return stickerChapterShape;
      case 'color':
        return stickerChapterColor;
      default:
        return stickerChapterDot;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundWidget(),
          ..._buildFloatingImages(context),
          Column(
            children: [
              const TitleWidget(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _chapters.length,
                  onPageChanged: (index) {
                    // กระโดดทันทีไปยังหน้านั้น เพื่อ cancel animation
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _pageController.jumpToPage(index); // ยกเลิกแอนิเมชัน
                    });
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final chapter = _chapters[index];
                    final data = _getPageData(chapter);

                    return Stack(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(170, 0, 0, 50),
                                child: BookSideWidget(
                                  bookImage: data.bookLeftImage,
                                  stickers: data.leftStickers,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 0, 170, 50),
                                child: BookSideWidget(
                                  bookImage: data.bookRightImage,
                                  stickers: data.rightStickers,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Positioned(
                          top: -20,
                          left: 0,
                          right: 0,
                          child: Align(
                            alignment: Alignment.center,
                            child: ScrewWidget(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            top: context.screenHeight * 0.22,
            left: context.screenWidth * 0.185,
            child: Opacity(
              opacity: 0.0, // ทำให้มองไม่เห็น แต่ยังแตะได้
              child: Row(
                children: List.generate(_chapters.length, (index) {
                  final List<Widget> widgets = [];
                  // เพิ่มปุ่ม
                  widgets.add(Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _chapterButton(index),
                  ));
                  if (index == 1) {
                    widgets.add(const SizedBox(width: 95));
                  }
                  return widgets;
                }).expand((widgetList) => widgetList).toList(),
              ),
            ),
          ),
          buildBackButton(context),
        ],
      ),
    );
  }

  Widget _chapterButton(int index) {
    return GestureDetector(
      onTap: () {
        _pageController.jumpToPage(index);
        setState(() {
          _currentPage = index;
        });
      },
      child: Container(
        width: 150,
        height: 50,
        decoration: BoxDecoration(
          color: index == _currentPage
              ? Colors.amber.shade400
              : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

List<Widget> _buildFloatingImages(BuildContext context) {
  double floatingImageSize = MediaQuery.of(context).size.width * 0.15;
  return List.generate(4, (index) {
    return FloatingImage(
      imagePath: 'assets/images/strickerbook/bg_elm.png',
      width: floatingImageSize,
      height: floatingImageSize,
    );
  });
}
