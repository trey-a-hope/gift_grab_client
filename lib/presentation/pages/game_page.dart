import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:gift_grab_game/game.dart';

enum Screens { main, gameOver, login }

class GamePage extends StatelessWidget {
  const GamePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        body: GameWidget<GiftGrabGame>(
          game: GiftGrabGame(
            onEndGame: (score) => debugPrint('Game ended with score: $score'),
          ),
          overlayBuilderMap: {
            Screens.gameOver.name: (context, game) => GameOverOverlay(
                  game.score,
                  game.resetGame!,
                ),
          },
        ),
      );
}
