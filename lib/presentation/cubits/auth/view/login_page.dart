import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:gift_grab_client/data/constants/globals.dart';
import 'package:gift_grab_client/presentation/cubits/auth/cubit/auth_cubit.dart';
import 'package:gift_grab_ui/ui.dart';

class LoginPage extends StatelessWidget {
  static const _usernameFormField = 'Username';

  static const _savedEmail = 'trey.a.hope@gmail.com';
  static const _savedPassword = 'Peachy5050';

  final AuthCubit authCubit;

  const LoginPage(this.authCubit, {super.key});

  @override
  Widget build(BuildContext context) {
    return GGScaffoldWidget(
      title: 'Login',
      canPop: false,
      child: FlutterLogin(
        logo: Image.asset(Globals.giftAsset).image,
        savedEmail: _savedEmail,
        savedPassword: _savedPassword,
        termsOfService: [
          TermOfService(
            id: '_',
            mandatory: true,
            text: 'I understand that I will never score higher than trey.codes',
          )
        ],
        title: 'Gift Grab',
        theme: LoginTheme(
          primaryColor: Colors.blueAccent,
          accentColor: Colors.white,
        ),
        onLogin: (data) async => await _onLoginEmail(
          email: data.name,
          password: data.password,
        ),
        additionalSignupFields: const [
          UserFormField(
            icon: Icon(Icons.face),
            keyName: _usernameFormField,
          ),
        ],
        onSignup: (data) async {
          final formError = getFormError(data);

          return formError != null
              ? formError
              : await _onSignUpEmail(
                  email: data.name!,
                  password: data.password!,
                  username: data.additionalSignupData![_usernameFormField]!,
                );
        },
        onRecoverPassword: (val) => null,
      ),
    );
  }

  String? getFormError(SignupData _) =>
      _.name == null || _.password == null || _.additionalSignupData == null
          ? 'Email, password, and username cannot be null'
          : null;

  Future<String?> _onLoginEmail({
    required String email,
    required String password,
  }) async =>
      _handleAuthEvent(() => authCubit.loginEmail(email, password));

  Future<String?> _onSignUpEmail({
    required String email,
    required String password,
    required String username,
  }) async =>
      _handleAuthEvent(
        () => authCubit.signup(email, password, username),
      );

  Future<String?> _handleAuthEvent(void Function() event) async {
    try {
      final completer = Completer<String?>();

      late final StreamSubscription subscription;

      subscription = authCubit.stream.listen((state) {
        if (!completer.isCompleted) {
          if (state.error != null) {
            completer.complete(state.error!);
            subscription.cancel();
          } else if (state.authenticated) {
            completer.complete(null);
            subscription.cancel();
          }
        }
      });

      event();

      return await completer.future;
    } catch (e) {
      return e.toString();
    }
  }
}
