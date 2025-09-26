import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart' as web;

Widget? renderGoogleButton() => web.renderButton(
      configuration: web.GSIButtonConfiguration(
        type: web.GSIButtonType.standard,
        theme: web.GSIButtonTheme.filledBlue,
      ),
    );
