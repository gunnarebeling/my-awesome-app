import 'package:flutter/material.dart';

mixin SnackBars<T extends StatefulWidget> on State<T> {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(String message, [Color? backgroundColor]) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(message),
      ),
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showErrorSnackBar(Object? error) {
    return showSnackBar(
      error?.toString() ?? 'An unknown error occurred. Please try again later.',
      Colors.red,
    );
  }
}
