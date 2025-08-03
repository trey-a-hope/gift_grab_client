import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gift_grab_client/data/constants/globals.dart';
import 'package:gift_grab_client/data/enums/login_error_exclusions.dart';
import 'package:gift_grab_client/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:gift_grab_ui/widgets/gg_scaffold_widget.dart';

class LoginPage extends StatelessWidget {
  static const _usernameFormField = 'Username';

  static const _savedEmail = 'trey.a.hope@gmail.com';
  static const _savedPassword = 'giftgrab';

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();

    return GGScaffoldWidget(
      title: 'Login',
      canPop: false,
      child: FlutterLogin(
        title: 'Gift Grab',
        savedEmail: _savedEmail,
        savedPassword: _savedPassword,
        logo: Image.asset(Globals.giftAsset).image,
        additionalSignupFields: const [
          UserFormField(
            icon: Icon(Icons.face),
            keyName: _usernameFormField,
          ),
        ],
        theme: LoginTheme(
          primaryColor: Colors.blueAccent,
          accentColor: Colors.white,
        ),
        onLogin: (data) async => authCubit.loginEmail(data.name, data.password),
        termsOfService: [
          TermOfService(
            id: '_',
            mandatory: true,
            text: 'I understand that I will never score higher than trey.codes',
          )
        ],
        onSignup: (data) async {
          final error = _getFormError(data);

          return error ??
              await authCubit.signup(
                data.name!,
                data.password!,
                data.additionalSignupData![_usernameFormField]!,
              );
        },
        onRecoverPassword: (val) => null,
        loginProviders: [
          LoginProvider(
            icon: FontAwesomeIcons.google,
            label: 'Google',
            errorsToExcludeFromErrorMessage: [LoginErrorExclusions.CANCELED.id],
            callback: () async => await context.read<AuthCubit>().loginGoogle(),
          ),
          if (Platform.isIOS) ...[
            LoginProvider(
              icon: FontAwesomeIcons.apple,
              label: 'Apple',
              errorsToExcludeFromErrorMessage: [
                LoginErrorExclusions.CANCELED.id
              ],
              callback: () async =>
                  await context.read<AuthCubit>().loginApple(),
            ),
          ]
        ],
      ),
    );
  }

  String? _getFormError(SignupData _) =>
      _.name == null || _.password == null || _.additionalSignupData == null
          ? 'Email, password, and username cannot be null'
          : null;
}
