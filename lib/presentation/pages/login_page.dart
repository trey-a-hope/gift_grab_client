import 'package:fluo/fluo.dart';
import 'package:fluo/fluo_onboarding.dart';
import 'package:fluo/fluo_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gift_grab_client/data/configuration/gap_sizes.dart';
import 'package:gift_grab_client/main.dart';
import 'package:gift_grab_client/presentation/cubits/auth/cubit/auth_cubit.dart';
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
          fluoTheme: FluoTheme.web(),
          onUserReady: () async {
            final user = Fluo.instance.session!.user;

            final id = user.id;
            final username = user.firstName ?? 'NOUSERNAME';

            authCubit.loginCustom(id: id, username: username);

            logger.i('Welcome back, ${user.firstName} 👋🏾');
          },
          introBuilder: (context, bottomContainerHeight) {
            return Container(
              width: double.infinity,
              color: Colors.white,
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
            );
          },
        );
      },
    );
  }
}
