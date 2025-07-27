import 'package:flutter/material.dart';
import 'package:gift_grab_client/data/constants/lotties.dart';
import 'package:lottie/lottie.dart';

part 'no_results.dart';

class NoResultsWidget extends StatelessWidget {
  final NoResultsEnum type;

  const NoResultsWidget(this.type, {super.key});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(type.lottieUrl, height: 200),
          Text(type.name, style: Theme.of(context).textTheme.displayLarge),
        ],
      );
}
