import 'package:flutter/material.dart';

class DropTargetArea extends StatelessWidget {
  final double top;
  final double left;
  final String type;
  final bool isPlaced;
  final void Function(String) onShapePlaced;
  final String assetPath;

  const DropTargetArea({
    super.key,
    required this.top,
    required this.left,
    required this.type,
    required this.onShapePlaced,
    required this.isPlaced,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * top,
      left: MediaQuery.of(context).size.width * left,
      child: DragTarget<String>(
        onAccept: (data) {
          if (data == type) {
            onShapePlaced(type);
          }
        },
        builder: (context, candidateData, rejectedData) {
          if (isPlaced) {
            Widget image = Image.asset(
              assetPath,
              width: 160, // default size
            );

            switch (type) {
              case 'circle':
                image = Transform.translate(
                  offset: const Offset(-75, -80),
                  child: Image.asset(
                    assetPath,
                    width: 270,
                  ),
                );
                break;
              case 'triangle':
                image = Transform.translate(
                  offset: const Offset(-118, -122),
                  child: Image.asset(
                    assetPath,
                    width: 348,
                  ),
                );
                break;
              case 'square':
                image = Transform.translate(
                  offset: const Offset(-20, -102),
                  child: Image.asset(
                    assetPath,
                    width: 157,
                  ),
                );
                break;
            }

            return image;
          } else {
            return Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
            );
          }
        },
      ),
    );
  }
}
