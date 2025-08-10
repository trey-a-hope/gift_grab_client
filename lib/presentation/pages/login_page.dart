import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gift_grab_client/data/constants/globals.dart';
import 'package:gift_grab_client/data/enums/login_error_exclusions.dart';
import 'package:gift_grab_client/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:gift_grab_ui/ui.dart';

class LoginPage extends StatelessWidget {
  static const _savedEmail = 'trey.a.hope@gmail.com';
  static const _savedPassword = 'giftgrab';

  static const _usernameField = 'Username';

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();

    return GGScaffoldWidget(
      title: 'Login',
      canPop: false,
      child: FlutterLogin(
        title: 'Gift Grab',
        logo: Image.asset(Globals.giftAsset).image,
        savedEmail: _savedEmail,
        savedPassword: _savedPassword,
        theme: LoginTheme(
          primaryColor: Colors.blueAccent,
          accentColor: Colors.white,
        ),
        termsOfService: [
          TermOfService(
            id: '_',
            mandatory: true,
            text: 'I understand that I will never score higher than trey.codes',
          ),
        ],
        additionalSignupFields: const [
          UserFormField(
            keyName: _usernameField,
            icon: Icon(
              Icons.face,
            ),
          ),
        ],
        loginProviders: [
          LoginProvider(
            icon: FontAwesomeIcons.google,
            label: 'Google',
            errorsToExcludeFromErrorMessage: [LoginErrorExclusions.CANCELED.id],
            callback: () async => await authCubit.loginGoogle(),
          ),
          if (Platform.isIOS || Platform.isMacOS) ...[
            LoginProvider(
              icon: FontAwesomeIcons.apple,
              label: 'Apple',
              errorsToExcludeFromErrorMessage: [
                LoginErrorExclusions.CANCELED.id
              ],
              callback: () async => await authCubit.loginApple(),
            ),
          ]
        ],
        onSignup: (data) async {
          final error = _getFormError(data);

          return error ??
              await authCubit.signup(
                data.name!,
                data.password!,
                data.additionalSignupData![_usernameField]!,
              );
        },
        onLogin: (data) async => authCubit.loginEmail(
          data.name,
          data.password,
        ),
        onRecoverPassword: (val) => null,
      ),
    );
  }

  String? _getFormError(SignupData data) => data.name == null ||
          data.password == null ||
          data.additionalSignupData == null
      ? 'Email, password, and username cannot be null'
      : null;
}
