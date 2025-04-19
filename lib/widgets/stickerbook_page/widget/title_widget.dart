import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {
  const TitleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
      child: Image.asset(
        'assets/images/strickerbook/title.png',
        height: screenHeight * 0.15,
        fit: BoxFit.contain,
      ),
    );
  }
}
