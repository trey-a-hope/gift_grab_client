import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class FlexGridviewWidget extends StatelessWidget {
  final List<Widget> children;

  /// General padding for this page and its widgets.
  static const padding = 8.0;

  const FlexGridviewWidget({
    required this.children,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Column(
      children: [
        const Gap(20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(padding),
            child: GridView.builder(
              key: UniqueKey(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(width),
              ),
              itemBuilder: (_, index) => Padding(
                padding: const EdgeInsets.all(padding),
                child: children[index],
              ),
              itemCount: children.length,
            ),
          ),
        ),
      ],
    );
  }

  /// Determines cross axis count based on width of screen.
  int _getCrossAxisCount(double width) {
    // If on mobile devices, use cross axis count of two.
    if (width < 600) return 2;

    // Round down from estimate.
    return (width / 250).floor();
  }
}
