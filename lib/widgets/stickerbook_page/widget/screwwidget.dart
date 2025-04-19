import 'package:flutter/material.dart';

class ScrewWidget extends StatelessWidget {
  const ScrewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 130, 0, 0),
        child: Container(
          width: screenWidth * 0.07,
          height: screenHeight * 0.47,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/strickerbook/screw.png'),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
