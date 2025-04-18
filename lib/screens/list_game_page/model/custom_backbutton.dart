import 'package:firstly/function/mediaquery_values.dart';
import 'package:flutter/material.dart';

import '../../../widgets/custom_button.dart';
import '../../gameselectionpage.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback onTap;
  final double widthFactor;
  final double heightFactor;

  const CustomBackButton({
    Key? key,
    required this.onTap,
    this.widthFactor = 0.12,
    this.heightFactor = 0.2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: context.screenWidth * 0.015,
      top: context.screenHeight * 0.01,
      child: SizedBox(
        width: context.screenWidth * 0.12,
        height: context.screenHeight * 0.2,
        child: CustomButton(
            onTap: () {
              navigateToGameSelectionPage(context);
            },
            child: Image.asset(
              'assets/images/back_button.png',
            )),
      ),
    );
  }
}

void navigateToGameSelectionPage(BuildContext context) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => const GameSelectionPage(),
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
