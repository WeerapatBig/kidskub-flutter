import 'package:flame/components.dart';

import '../logic/game_color_logic.dart';

class GameController extends Component {
  final ColorGame game;
  GameController(this.game);

  void onLeftPressed() {
    game.player.move(Vector2(-1, 0));
    game.incrementPlayerMoveCount();
  }

  void onRightPressed() {
    game.player.move(Vector2(1, 0));
    game.incrementPlayerMoveCount();
  }

  void onUpPressed() {
    game.player.move(Vector2(0, -1));
    game.incrementPlayerMoveCount();
  }

  void onDownPressed() {
    game.player.move(Vector2(0, 1));

    game.incrementPlayerMoveCount();
  }
}
