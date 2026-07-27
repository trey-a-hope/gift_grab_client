import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:gift_grab_client/data/configuration/gap_sizes.dart';
import 'package:gift_grab_ui/widgets/gg_scaffold_widget.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = ShadTheme.of(context).textTheme;

    return GGScaffoldWidget(
      title: 'Login',
      canPop: false,
      child: SizedBox(
        width: .infinity,
        child: Column(
          mainAxisAlignment: .center,
          children: [
            GapSizes.xlGap,
            Text('Gift Grab', style: textTheme.h1),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: ClerkAuthBuilder(
                      signedOutBuilder: (context, authState) =>
                          const ClerkAuthentication(),
                      signedInBuilder: (context, authState) =>
                          const CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
