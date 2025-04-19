import 'package:firstly/function/mediaquery_values.dart';
import 'package:flutter/material.dart';
import 'package:firstly/function/background_audio_manager.dart';
import 'package:firstly/screens/homepage.dart';

import '../../custom_button.dart';

Widget buildBackButton(BuildContext context) {
  return Positioned(
    width: context.screenWidth * 0.12,
    height: context.screenHeight * 0.2,
    left: context.screenWidth * 0.015,
    top: context.screenHeight * 0.01,
    child: CustomButton(
      onTap: () {
        BackgroundAudioManager().playButtonBackSound();
        navigateToGameSelectionPage(context);
      },
      child: Image.asset(
        'assets/images/back_button.png',
      ),
    ),
  );
}

void navigateToGameSelectionPage(BuildContext context) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => const HomePage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 1000),
    ),
  );
}
