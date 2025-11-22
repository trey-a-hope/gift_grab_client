import 'package:fluo/fluo.dart';
import 'package:fluo/fluo_onboarding.dart';
import 'package:fluo/fluo_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/data/configuration/gap_sizes.dart';
import 'package:gift_grab_client/main.dart';
import 'package:gift_grab_client/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:gift_grab_ui/widgets/gg_scaffold_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_util/modal_util.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  bool _newError(AuthState previous, AuthState current) =>
      previous.error != current.error;

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();

    final textTheme = ShadTheme.of(context).textTheme;
    final colorScheme = ShadTheme.of(context).colorScheme;

    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: _newError,
      listener: (context, state) {
        if (state.error != null) {
          ModalUtil.showError(context, title: state.error!);
          Fluo.instance.clearSession();
        }
      },
      buildWhen: _newError,
      builder: (context, state) {
        if (state.isLoading)
          return const Center(child: CircularProgressIndicator());

        return FluoOnboarding(
          fluoTheme: FluoTheme.web(
            primaryColor: colorScheme.foreground,
            continueButtonStyle: continueButtonStyle,
          ),
          onUserReady: () async {
            final user = Fluo.instance.session!.user;

            final id = user.id;
            final username = user.firstName ?? 'NOUSERNAME';

            authCubit.loginCustom(id: id, username: username);

            logger.i('Welcome back, ${user.firstName} 👋🏾');
          },
          introBuilder: (context, bottomContainerHeight) {
            return GGScaffoldWidget(
              title: 'Login',
              canPop: false,
              child: SizedBox(
                width: double.infinity,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsetsGeometry.only(
                      bottom: bottomContainerHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: .center,
                      mainAxisAlignment: .center,
                      children: [
                        GapSizes.xlGap,
                        Text('Gift Grab', style: textTheme.h1),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsGeometry.symmetric(
                              horizontal: GapSizes.xlGap.mainAxisExtent,
                            ),
                            child: Lottie.network(
                              'https://lottie.host/a470a89f-73ab-4c17-9c93-f41cba57289c/Cs3tJzRAcQ.json',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Custom continue button style, just to get the black title text.
final continueButtonStyle = ButtonStyle(
  splashFactory: NoSplash.splashFactory,
  elevation: WidgetStateProperty.all(0),
  backgroundColor: WidgetStateProperty.resolveWith(
    (states) => states.contains(WidgetState.disabled)
        ? Colors.grey.shade100
        : Colors.white,
  ),
  // Here...
  foregroundColor: WidgetStateProperty.resolveWith(
    (states) => states.contains(WidgetState.disabled)
        ? Colors.black.withAlpha(255 ~/ 4)
        : Colors.black,
  ),
  minimumSize: WidgetStateProperty.all(const Size.fromHeight(50)),
  mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
  textStyle: WidgetStateProperty.all(
    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
  ),
  overlayColor: WidgetStateProperty.resolveWith<Color?>(
    (Set<WidgetState> states) =>
        states.contains(WidgetState.hovered) ? Colors.grey.shade50 : null,
  ),
  shape: WidgetStateProperty.resolveWith<OutlinedBorder>(
    (Set<WidgetState> states) => RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
      side: BorderSide(
        color: states.contains(WidgetState.hovered)
            ? Colors.grey.shade600
            : const Color(0xffdadce0),
        width: 1.0,
      ),
    ),
  ),
);
