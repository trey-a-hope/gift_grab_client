import 'package:flutter/material.dart';
import 'package:gift_grab_client/data/constants/lotties.dart';
import 'package:lottie/lottie.dart';

part 'menu_button.dart';

class MenuButtonWidget extends StatelessWidget {
  final MenuButton menuButton;
  final void Function()? onTap;

  const MenuButtonWidget({
    super.key,
    required this.menuButton,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            32,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade100,
              Colors.blue.shade900,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Expanded(
                child: Lottie.network(
                  menuButton.lottieUrl,
                  height: 100,
                ),
              ),
              Text(
                menuButton.name,
                style: theme.textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
